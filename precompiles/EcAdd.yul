object "EcAdd" {
	code { }
	object "EcAdd_deployed" {
		code {
            ////////////////////////////////////////////////////////////////
            //                      CONSTANTS
            ////////////////////////////////////////////////////////////////

            function ZERO() -> zero {
                zero := 0x0
            }

            function ONE() -> one {
                one := 0x1
            }

            // Group order of alt_bn128, see https://eips.ethereum.org/EIPS/eip-196
            function ALT_BN128_GROUP_ORDER() -> ret {
                ret := 21888242871839275222246405745257275088696311157297823662689037894645226208583
            }

            function R2_MOD_ALT_BN128_GROUP_ORDER() -> ret {
                ret := 3096616502983703923843567936837374451735540968419076528771170197431451843209
            }

            function N_PRIME() -> ret {
                ret := 111032442853175714102588374283752698368366046808579839647964533820976443843465
            }

            // ////////////////////////////////////////////////////////////////
            //                      HELPER FUNCTIONS
            // ////////////////////////////////////////////////////////////////

            /// @dev Executes the `precompileCall` opcode.
            function precompileCall(precompileParams, gasToBurn) -> ret {
                // Compiler simulation for calling `precompileCall` opcode
                ret := verbatim_2i_1o("precompile", precompileParams, gasToBurn)
            }

            function burnGas() {
                // Precompiles that do not have a circuit counterpart
                // will burn the provided gas by calling this function.
                precompileCall(0, gas())
            }

            function getHighestHalfOfMultiplication(multiplicand, multiplier) -> ret {
                ret := verbatim_2i_1o("mul_high", multiplicand, multiplier)
            }

            function submod(minuend, subtrahend, modulus) -> difference {
                difference := addmod(minuend, sub(modulus, subtrahend), modulus)
            }

            function overflowingAdd(augend, addend) -> sum, overflowed {
                sum := add(augend, addend)
                overflowed := or(lt(sum, augend), lt(sum, addend))
            }

            // Returns 1 if (x, y) is in the curve, 0 otherwise
            function pointIsInCurve(x, y) -> ret {
                let y_squared := mulmod(y, y, ALT_BN128_GROUP_ORDER())
                let x_squared := mulmod(x, x, ALT_BN128_GROUP_ORDER())
                let x_qubed := mulmod(x_squared, x, ALT_BN128_GROUP_ORDER())
                let x_qubed_plus_three := addmod(x_qubed, 3, ALT_BN128_GROUP_ORDER())

                ret := eq(y_squared, x_qubed_plus_three)
            }

            function isInfinity(x, y) -> ret {
                ret := and(eq(x, ZERO()), eq(y, ZERO()))
            }

            function isOnGroupOrder(num) -> ret {
                ret := lt(num, sub(ALT_BN128_GROUP_ORDER(), ONE()))
            }

            function binaryExtendedEuclideanAlgorithm(base) -> inv {
                // Precomputation of 1 << 255
                let mask := 57896044618658097711785492504343953926634992332820282019728792003956564819968
                let modulus := ALT_BN128_GROUP_ORDER()
                // modulus >> 255 == 0 -> modulus & 1 << 255 == 0
                let modulusHasSpareBits := iszero(and(modulus, mask))

                let u := base
                let v := modulus
                // Avoids unnecessary reduction step.
                let b := R2_MOD_ALT_BN128_GROUP_ORDER()
                let c := ZERO()

                for {} and(iszero(eq(u, ONE())), iszero(eq(v, ONE()))) {} {
                    for {} iszero(and(u, ONE())) {} {
                        u := shr(1, u)
                        let currentB := b
                        switch and(currentB, ONE())
                        case 0 {
                            b := shr(1, b)
                        }
                        case 1 {
                            let newB := add(b, modulus)
                            let carry := or(lt(newB, b), lt(newB, modulus))
                            b := shr(1, newB)

                            if and(iszero(modulusHasSpareBits), carry) {
                                b := or(b, mask)
                            }
                        }
                    }

                    for {} iszero(and(v, ONE())) {} {
                        v := shr(1, v)
                        let currentC := c
                        switch and(currentC, ONE())
                        case 0 {
                            c := shr(1, c)
                        }
                        case 1 {
                            let newC := add(c, modulus)
                            let carry := or(lt(newC, c), lt(newC, modulus))
                            c := shr(1, newC)

                            if and(iszero(modulusHasSpareBits), carry) {
                                c := or(c, mask)
                            }
                        }
                    }

                    switch gt(v, u)
                    case 0 {
                        u := sub(u, v)
                        if lt(b, c) {
                            b := add(b, modulus)
                        }
                        b := sub(b, c)
                    }
                    case 1 {
                        v := sub(v, u)
                        if lt(c, b) {
                            c := add(c, modulus)
                        }
                        c := sub(c, b)
                    }
                }

                switch eq(u, ONE())
                case 0 {
                    inv := c
                }
                case 1 {
                    inv := b
                }
            }

            // https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithm
            function REDC(lowestHalfOfT, higherHalfOfT) -> S {
                let q := mul(lowestHalfOfT, N_PRIME())
                let aHigh := add(higherHalfOfT, getHighestHalfOfMultiplication(q, ALT_BN128_GROUP_ORDER()))
                let aLow, overflowed := overflowingAdd(lowestHalfOfT, mul(q, ALT_BN128_GROUP_ORDER()))
                if overflowed {
                    aHigh := add(aHigh, ONE())
                }
                S := aHigh
                if iszero(lt(aHigh, ALT_BN128_GROUP_ORDER())) {
                    S := sub(aHigh, ALT_BN128_GROUP_ORDER())
                }
            }

            // Transforming into the Montgomery form -> REDC((a mod N)(R2 mod N))
            function intoMontgomeryForm(a) -> ret {
                let higherHalf := getHighestHalfOfMultiplication(mod(a, ALT_BN128_GROUP_ORDER()), R2_MOD_ALT_BN128_GROUP_ORDER())
                let lowestHalf := mul(mod(a, ALT_BN128_GROUP_ORDER()), R2_MOD_ALT_BN128_GROUP_ORDER())
                ret := REDC(lowestHalf, higherHalf)
            }

            // Transforming out of the Montgomery form -> REDC(a * R mod N)
            function outOfMontgomeryForm(m) -> ret {
                let higherHalfOf := ZERO()
                let lowestHalf := m
                ret := REDC(lowestHalf, higherHalfOf)
            }

            // Multipling field elements in Montgomery form -> REDC((a * R mod N)(b * R mod N))
            function montgomeryMul(multiplicand, multiplier) -> ret {
                let higherHalfOfProduct := getHighestHalfOfMultiplication(multiplicand, multiplier)
                let lowestHalfOfProduct := mul(multiplicand, multiplier)
                ret := REDC(lowestHalfOfProduct, higherHalfOfProduct)
            }

            function montgomeryModularInverse(a) -> invmod {
                invmod := binaryExtendedEuclideanAlgorithm(a)
            }

            function montgomeryDiv(dividend, divisor) -> quotient {
                quotient := montgomeryMul(dividend, montgomeryModularInverse(divisor))
            }

            ////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////

            // Retrieve the coordinates from the calldata
            let x1 := calldataload(0)
            let y1 := calldataload(32)
            let x2 := calldataload(64)
            let y2 := calldataload(96)

            let p1IsInfinity := isInfinity(x1, y1)
            let p2IsInfinity := isInfinity(x2, y2)

            if and(p1IsInfinity, p2IsInfinity) {
                // Infinity + Infinity = Infinity
                mstore(0, ZERO())
                mstore(32, ZERO())
                return(0, 64)
            }
            if and(p1IsInfinity, iszero(p2IsInfinity)) {
                // Infinity + P = P

                // Ensure that the coordinates are between 0 and the group order.
                if or(iszero(isOnGroupOrder(x2)), iszero(isOnGroupOrder(y2))) {
                    burnGas()
                    revert(0, 0)
                }

                // Ensure that the point is in the curve (Y^2 = X^3 + 3).
                if iszero(pointIsInCurve(x2, y2)) {
                    burnGas()
                    revert(0, 0)
                }

                mstore(0, x2)
                mstore(32, y2)
                return(0, 64)
            }
            if and(iszero(p1IsInfinity), p2IsInfinity) {
                // P + Infinity = P

                // Ensure that the coordinates are between 0 and the group order.
                if or(iszero(isOnGroupOrder(x1)), iszero(isOnGroupOrder(y1))) {
                    burnGas()
                    revert(0, 0)
                }

                // Ensure that the point is in the curve (Y^2 = X^3 + 3).
                if iszero(pointIsInCurve(x1, y1)) {
                    burnGas()
                    revert(0, 0)
                }

                mstore(0, x1)
                mstore(32, y1)
                return(0, 64)
            }

            // Ensure that the coordinates are between 0 and the group order.
            if or(iszero(isOnGroupOrder(x1)), iszero(isOnGroupOrder(y1))) {
                burnGas()
                revert(0, 0)
            }

            // Ensure that the coordinates are between 0 and the group order.
            if or(iszero(isOnGroupOrder(x2)), iszero(isOnGroupOrder(y2))) {
                burnGas()
                revert(0, 0)
            }

            // Ensure that the points are in the curve (Y^2 = X^3 + 3).
            if or(iszero(pointIsInCurve(x1, y1)), iszero(pointIsInCurve(x2, y2))) {
                burnGas()
                revert(0, 0)
            }

            // There's no need for transforming into Montgomery form
            // for this case.
            if and(eq(x1, x2), eq(submod(0, y1, ALT_BN128_GROUP_ORDER()), y2)) {
                // P + (-P) = Infinity

                mstore(0, ZERO())
                mstore(32, ZERO())
                return(0, 64)
            }
            // There's no need for transforming into Montgomery form
            // for this case.
            if and(eq(x1, x2), and(iszero(eq(y1, y2)), iszero(eq(y1, submod(0, y2, ALT_BN128_GROUP_ORDER()))))) {
                burnGas()
                revert(0, 0)
            }

            if and(eq(x1, x2), eq(y1, y2)) {
                // P + P = 2P

                let x := intoMontgomeryForm(x1)
                let y := intoMontgomeryForm(y1)

                // (3 * x1^2 + a) / (2 * y1)
                let x1_squared := montgomeryMul(x, x)
                let slope := montgomeryDiv(addmod(x1_squared, addmod(x1_squared, x1_squared, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER()), addmod(y, y, ALT_BN128_GROUP_ORDER()))
                // x3 = slope^2 - 2 * x1
                let x3 := submod(montgomeryMul(slope, slope), addmod(x, x, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                // y3 = slope * (x1 - x3) - y1
                let y3 := submod(montgomeryMul(slope, submod(x, x3, ALT_BN128_GROUP_ORDER())), y, ALT_BN128_GROUP_ORDER())

                x3 := outOfMontgomeryForm(x3)
                y3 := outOfMontgomeryForm(y3)

                mstore(0, x3)
                mstore(32, y3)
                return(0, 64)
            }

            // P1 + P2 = P3

            x1 := intoMontgomeryForm(x1)
            y1 := intoMontgomeryForm(y1)
            x2 := intoMontgomeryForm(x2)
            y2 := intoMontgomeryForm(y2)

            // (y2 - y1) / (x2 - x1)
            let slope := montgomeryDiv(submod(y2, y1, ALT_BN128_GROUP_ORDER()), submod(x2, x1, ALT_BN128_GROUP_ORDER()))
            // x3 = slope^2 - x1 - x2
            let x3 := submod(montgomeryMul(slope, slope), addmod(x1, x2, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
            // y3 = slope * (x1 - x3) - y1
            let y3 := submod(montgomeryMul(slope, submod(x1, x3, ALT_BN128_GROUP_ORDER())), y1, ALT_BN128_GROUP_ORDER())

            x3 := outOfMontgomeryForm(x3)
            y3 := outOfMontgomeryForm(y3)

            mstore(0, x3)
            mstore(32, y3)
            return(0, 64)
		}
	}
}
