object "EcMul" {
	code { }
	object "EcMul_deployed" {
		code {
            ////////////////////////////////////////////////////////////////
            //                      CONSTANTS
            ////////////////////////////////////////////////////////////////

            function ZERO() -> zero {
                zero := 0x00
            }

            function ONE() -> one {
                one := 0x01
            }

            function TWO() -> two {
                two := 0x02
            }

            function THREE() -> three {
                three := 0x03
            }

            function MONTGOMERY_ONE() -> m_one {
                m_one := 6350874878119819312338956282401532409788428879151445726012394534686998597021
            }

            // Group order of alt_bn128, see https://eips.ethereum.org/EIPS/eip-196
            function ALT_BN128_GROUP_ORDER() -> ret {
                ret := 21888242871839275222246405745257275088696311157297823662689037894645226208583
            }

            function ALT_BN128_GROUP_ORDER_MINUS_ONE() -> ret {
                ret := 21888242871839275222246405745257275088696311157297823662689037894645226208582
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
                let ySquared := mulmod(y, y, ALT_BN128_GROUP_ORDER())
                let xSquared := mulmod(x, x, ALT_BN128_GROUP_ORDER())
                let xQubed := mulmod(xSquared, x, ALT_BN128_GROUP_ORDER())
                let xQubedPlusThree := addmod(xQubed, THREE(), ALT_BN128_GROUP_ORDER())

                ret := eq(ySquared, xQubedPlusThree)
            }

            function isInfinity(x, y) -> ret {
                ret := and(iszero(x), iszero(y))
            }

            function isOnGroupOrder(num) -> ret {
                ret := lt(num, ALT_BN128_GROUP_ORDER_MINUS_ONE())
            }

            function lsbIsOne(x) -> ret {
                ret := and(x, ONE())
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
                        let current := b
                        switch and(current, ONE())
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
                        let current := c
                        switch and(current, ONE())
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
                let m := mul(lowestHalfOfT, N_PRIME())
                let hi := add(higherHalfOfT, getHighestHalfOfMultiplication(m, ALT_BN128_GROUP_ORDER()))
                let lo, overflowed := overflowingAdd(lowestHalfOfT, mul(m, ALT_BN128_GROUP_ORDER()))
                if overflowed {
                    hi := add(hi, ONE())
                }
                S := hi
                if iszero(lt(hi, ALT_BN128_GROUP_ORDER())) {
                    S := sub(hi, ALT_BN128_GROUP_ORDER())
                }
            }

            // Transforming into the Montgomery form -> REDC((a mod N)(R2 mod N))
            function intoMontgomeryForm(a) -> ret {
                let hi := getHighestHalfOfMultiplication(mod(a, ALT_BN128_GROUP_ORDER()), R2_MOD_ALT_BN128_GROUP_ORDER())
                let lo := mul(mod(a, ALT_BN128_GROUP_ORDER()), R2_MOD_ALT_BN128_GROUP_ORDER())
                ret := REDC(lo, hi)
            }

            // Transforming out of the Montgomery form -> REDC(a * R mod N)
            function outOfMontgomeryForm(m) -> ret {
                let hi := ZERO()
                let lo := m
                ret := REDC(lo, hi)
            }

            // Multipling field elements in Montgomery form -> REDC((a * R mod N)(b * R mod N))
            function montgomeryMul(multiplicand, multiplier) -> ret {
                let hi := getHighestHalfOfMultiplication(multiplicand, multiplier)
                let lo := mul(multiplicand, multiplier)
                ret := REDC(lo, hi)
            }

            function montgomeryModExp(base, exponent) -> pow {
                pow := MONTGOMERY_ONE()
                let aux := exponent
                for { } gt(aux, ZERO()) { } {
                        if mod(aux, 2) {
                            pow := montgomeryMul(pow, base)
                        }
                        aux := shr(1, aux)
                        base := montgomeryMul(base, base)
                }
            }

            function montgomeryModularInverse(a) -> invmod {
                invmod := binaryExtendedEuclideanAlgorithm(a)
            }

            function montgomeryDiv(dividend, divisor) -> quotient {
                quotient := montgomeryMul(dividend, montgomeryModularInverse(divisor))
            }

            function montgomeryDouble(x, y) -> newX, newY {
                switch isInfinity(x, y)
                case 0 {
                    // (3 * x^2 + a) / (2 * y)
                    let xSquared := montgomeryMul(x, x)
                    let slope := montgomeryDiv(addmod(xSquared, addmod(xSquared, xSquared, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER()), addmod(y, y, ALT_BN128_GROUP_ORDER()))
                    // x = slope^2 - 2 * x
                    newX := submod(montgomeryMul(slope, slope), addmod(x, x, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                    // y = slope * (x - x) - y
                    newY := submod(montgomeryMul(slope, submod(x, newX, ALT_BN128_GROUP_ORDER())), y, ALT_BN128_GROUP_ORDER())
                }
                case 1 {
                    newX := ZERO()
                    newY := ZERO()
                }
            }

            ////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////

            // Retrieve the coordinates from the calldata
            let x := calldataload(0)
            let y := calldataload(32)
            let scalar := calldataload(64)

            if isInfinity(x, y) {
                // Infinity * scalar = Infinity
                mstore(0, ZERO())
                mstore(32, ZERO())
                return(0, 64)
            }

            // Ensure that the coordinates are between 0 and the group order.
            if or(iszero(isOnGroupOrder(x)), iszero(isOnGroupOrder(y))) {
                burnGas()
                revert(0, 0)
            }

            // Ensure that the point is in the curve (Y^2 = X^3 + 3).
            if iszero(pointIsInCurve(x, y)) {
                burnGas()
                revert(0, 0)
            }

            if eq(scalar, ZERO()) {
                // P * 0 = Infinity
                mstore(0, ZERO())
                mstore(32, ZERO())
                return(0, 64)
            }
            if eq(scalar, ONE()) {
                // P * 1 = P
                mstore(0, x)
                mstore(32, y)
                return(0, 64)
            }

            x := intoMontgomeryForm(x)
            y := intoMontgomeryForm(y)

            if eq(scalar, TWO()) {
                let x2, y2 := montgomeryDouble(x, y)

                x2 := outOfMontgomeryForm(x2)
                y2 := outOfMontgomeryForm(y2)

                mstore(0, x2)
                mstore(32, y2)
                return(0, 64)
            }

            let x2 := x
            let y2 := y
            let xRes := ZERO()
            let yRes := ZERO()
            for {} scalar {} {
                if lsbIsOne(scalar) {
                    if and(isInfinity(xRes, yRes), isInfinity(x2, y2)) {
                        // Infinity + Infinity = Infinity
                        xRes := ZERO()
                        yRes := ZERO()

                        x2, y2 := montgomeryDouble(x2, y2)
                        // Check next bit
                        scalar := shr(1, scalar)
                        break
                    }
                    if and(isInfinity(xRes, yRes), iszero(isInfinity(x2, y2))) {
                        // Infinity + P = P
                        xRes := x2
                        yRes := y2

                        x2, y2 := montgomeryDouble(x2, y2)
                        // Check next bit
                        scalar := shr(1, scalar)
                        continue
                    }
                    if and(iszero(isInfinity(xRes, yRes)), isInfinity(x2, y2)) {
                        // P + Infinity = P
                        break
                    }
                    if and(eq(xRes, x2), eq(submod(ZERO(), yRes, ALT_BN128_GROUP_ORDER()), y2)) {
                        // P + (-P) = Infinity
                        xRes := ZERO()
                        yRes := ZERO()

                        x2, y2 := montgomeryDouble(x2, y2)
                        // Check next bit
                        scalar := shr(1, scalar)
                        continue
                    }
                    if and(eq(xRes, x2), eq(yRes, y2)) {
                        // P + P = 2P
                        xRes, yRes := montgomeryDouble(xRes, yRes)

                        x2 := xRes
                        y2 := yRes
                        // Check next bit
                        scalar := shr(1, scalar)
                        continue
                    }

                    // P1 + P2 = P3

                    // (y2 - y1) / (x2 - x1)
                    let slope := montgomeryDiv(submod(y2, yRes, ALT_BN128_GROUP_ORDER()), submod(x2, xRes, ALT_BN128_GROUP_ORDER()))
                    // x3 = slope^2 - x1 - x2
                    let x3 := submod(montgomeryMul(slope, slope), addmod(xRes, x2, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                    // y3 = slope * (x1 - x3) - y1
                    let y3 := submod(montgomeryMul(slope, submod(xRes, x3, ALT_BN128_GROUP_ORDER())), yRes, ALT_BN128_GROUP_ORDER())

                    xRes := x3
                    yRes := y3
                }

                x2, y2 := montgomeryDouble(x2, y2)
                // Check next bit
                scalar := shr(1, scalar)
            }

            xRes := outOfMontgomeryForm(xRes)
            yRes := outOfMontgomeryForm(yRes)

            mstore(0, xRes)
            mstore(32, yRes)
            return(0, 64)
		}
	}
}
