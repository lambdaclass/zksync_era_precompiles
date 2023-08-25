object "Playground" {
    code { }
    object "Playground_deployed" {
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

            function MONTGOMERY_TWO() -> m_two {
                m_two := 12701749756239638624677912564803064819576857758302891452024789069373997194042
            }

            function MONTGOMERY_THREE() -> m_three {
                m_three := 19052624634359457937016868847204597229365286637454337178037183604060995791063
            }

            // Group order of alt_bn128, see https://eips.ethereum.org/EIPS/eip-196
            function P() -> ret {
                ret := 21888242871839275222246405745257275088696311157297823662689037894645226208583
            }

            function R2_MOD_P() -> ret {
                ret := 3096616502983703923843567936837374451735540968419076528771170197431451843209
            }

            function R3_MOD_P() -> ret {
                ret := 14921786541159648185948152738563080959093619838510245177710943249661917737183
            }

            function N_PRIME() -> ret {
                ret := 111032442853175714102588374283752698368366046808579839647964533820976443843465
            }

            // CONSOLE.LOG Caller
            // It prints 'val' in the node console and it works using the 'mem'+0x40 memory sector
            function console_log(mem, val) -> {
                let log_address := 0x000000000000000000636F6e736F6c652e6c6f67
                // load the free memory pointer
                let freeMemPointer := mload(mem)
                // store the function selector of log(uint256) in memory
                mstore(freeMemPointer, 0xf82c50f1)
                // store the first argument of log(uint256) in the next memory slot
                mstore(add(freeMemPointer, 0x20), val)
                // call the console.log contract
                if iszero(staticcall(gas(),log_address,add(freeMemPointer, 28),add(freeMemPointer, 0x40),0x00,0x00)) {
                    revert(0,0)
                }
            }

            function submod(minuend, subtrahend, modulus) -> difference {
                difference := addmod(minuend, sub(modulus, subtrahend), modulus)
            }

            function binaryExtendedEuclideanAlgorithm(base) -> inv {
                // Precomputation of 1 << 255
                let mask := 57896044618658097711785492504343953926634992332820282019728792003956564819968
                let modulus := P()
                // modulus >> 255 == 0 -> modulus & 1 << 255 == 0
                let modulusHasSpareBits := iszero(and(modulus, mask))

                let u := base
                let v := modulus
                // Avoids unnecessary reduction step.
                let b := R2_MOD_P()
                let c := ZERO()

                for {} and(iszero(eq(u, ONE())), iszero(eq(v, ONE()))) {} {
                    for {} iszero(and(u, ONE())) {} {
                        u := shr(1, u)
                        let current_b := b
                        let current_b_is_odd := and(current_b, ONE())
                        if iszero(current_b_is_odd) {
                            b := shr(1, b)
                        }
                        if current_b_is_odd {
                            let new_b := add(b, modulus)
                            let carry := or(lt(new_b, b), lt(new_b, modulus))
                            b := shr(1, new_b)

                            if and(iszero(modulusHasSpareBits), carry) {
                                b := or(b, mask)
                            }
                        }
                    }

                    for {} iszero(and(v, ONE())) {} {
                        v := shr(1, v)
                        let current_c := c
                        let current_c_is_odd := and(current_c, ONE())
                        if iszero(current_c_is_odd) {
                            c := shr(1, c)
                        }
                        if current_c_is_odd {
                            let new_c := add(c, modulus)
                            let carry := or(lt(new_c, c), lt(new_c, modulus))
                            c := shr(1, new_c)

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

            function overflowingAdd(augend, addend) -> sum, overflowed {
                sum := add(augend, addend)
                overflowed := or(lt(sum, augend), lt(sum, addend))
            }

            function getHighestHalfOfMultiplication(multiplicand, multiplier) -> ret {
                ret := verbatim_2i_1o("mul_high", multiplicand, multiplier)
            }

            // https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithm
            function REDC(lowest_half_of_T, higher_half_of_T) -> S {
                let q := mul(lowest_half_of_T, N_PRIME())
                let a_high := add(higher_half_of_T, getHighestHalfOfMultiplication(q, P()))
                let a_low, overflowed := overflowingAdd(lowest_half_of_T, mul(q, P()))
                if overflowed {
                    a_high := add(a_high, ONE())
                }
                S := a_high
                if iszero(lt(a_high, P())) {
                    S := sub(a_high, P())
                }
            }

            // Transforming into the Montgomery form -> REDC((a mod N)(R2 mod N))
            function intoMontgomeryForm(a) -> ret {
                    let higher_half_of_a := getHighestHalfOfMultiplication(mod(a, P()), R2_MOD_P())
                    let lowest_half_of_a := mul(mod(a, P()), R2_MOD_P())
                    ret := REDC(lowest_half_of_a, higher_half_of_a)
            }

            // Transforming out of the Montgomery form -> REDC(a * R mod N)
            function outOfMontgomeryForm(m) -> ret {
                    let higher_half_of_m := ZERO()
                    let lowest_half_of_m := m 
                    ret := REDC(lowest_half_of_m, higher_half_of_m)
            }

            function montgomeryAdd(augend, addend) -> ret {
                ret := addmod(augend, addend, P())
            }

            function montgomerySub(minuend, subtrahend) -> ret {
                ret := montgomeryAdd(minuend, sub(P(), subtrahend))
            }

            // Multipling field elements in Montgomery form -> REDC((a * R mod N)(b * R mod N))
            function montgomeryMul(multiplicand, multiplier) -> ret {
                let higher_half_of_product := getHighestHalfOfMultiplication(multiplicand, multiplier)
                let lowest_half_of_product := mul(multiplicand, multiplier)
                ret := REDC(lowest_half_of_product, higher_half_of_product)
            }

            function montgomeryModExp(
                base,
                exponent
            ) -> pow {
                pow := MONTGOMERY_ONE()
                let aux_exponent := exponent
                for { } gt(aux_exponent, ZERO()) { } {
                    if mod(aux_exponent, TWO()) {
                        pow := montgomeryMul(pow, base)
                    }
                    aux_exponent := shr(1, aux_exponent)
                    base := montgomeryMul(base, base)
                }
            }

            function montgomeryModularInverse(a) -> invmod {
                invmod := binaryExtendedEuclideanAlgorithm(a)
            }

            function montgomeryDiv(dividend, divisor) -> quotient {
                quotient := montgomeryMul(dividend, montgomeryModularInverse(divisor))
            }

            // G1 -> Y^2 = X^3 + 3
			function pointIsOnG1(x, y) -> ret {
				let ySquared := mulmod(y, y, P())
				let xSquared := mulmod(x, x, P())
				let xQubed := mulmod(xSquared, x, P())
				let xQubedPlusThree := addmod(xQubed, THREE(), P())

				ret := eq(ySquared, xQubedPlusThree)
			}

            // G2 -> Y^2 = X^3 + 3/(i+9)
			//    -> (iya + yb)^2 = (ixa + xb)^3 + 3/(i+9)
            //    -> i(2*ay*by) + (yb^2 - ya^2) = i(3*bx^2*ax - ax^3 - 3/82) + (xb - 3*bx*ax^2 + 27/82)
			function pointIsOnG2(ax, bx, ay, by) -> ret {
                let axSquared := montgomeryMul(ax, ax)
                let bxSquared := montgomeryMul(bx, bx)
                let aySquared := montgomeryMul(ay, ay)
                let bySquared := montgomeryMul(bx, bx)
                let ayby := montgomeryMul(ay, by)

                // Precomputation of 27/82 = 27*82^-1
                let twentySevenOverEightyTwo := 0x00
                // Precomputation of 3/82 = 3*82^-1
                let threeOverEightyTwo := 0x00

                // 2*ay*by
                let aLeft := addmod(ayby, ayby, P())
                // by^2 - ay^2
                let bLeft := submod(bySquared, aySquared, P())

                let tripledBxSquared := addmod(bxSquared, addmod(bxSquared, bxSquared, P()), P())
                // aRight = 3*bx^2*ax - ax^3 - 3/82
                //        = ax*(3*bx*bx - ax*ax - 3/82)
                //        = ax*((bx*bx + bx*bx + bx*bx) - ax*ax - 3/82)
                //        = ax*((bxSquared + bxSquared + bxSquared) - aSquared) - 3/82
                let aRight := submod(montgomeryMul(ax, submod(tripledBxSquared, axSquared, P())), threeOverEightyTwo, P())
                let tripledAxSquared := addmod(axSquared, addmod(axSquared, axSquared, P()), P())
                // bRight = bx^3 - 3*bx*ax^2 + 27/82
                //        = bx*(bx*bx - 3*ax*ax + 27/82)
                //        = bx*(bSquared - (aSquared + aSquared + aSquared)) + 27/82
                let bRight := addmod(montgomeryMul(bx, submod(bxSquared, tripledAxSquared, P())), twentySevenOverEightyTwo, P())

                let left := eq(aLeft, bLeft)
                let right := eq(aRight, bRight)

                ret := and(left, right)
			}

            function affinePointIsInfinity(x, y) -> ret {
                ret := and(iszero(x), iszero(y))
            }

            function projectivePointIsInfinity(z) -> ret {
                ret := iszero(z)
            }

            function projectiveFromAffine(xp, yp) -> xr, yr, zr {
                switch affinePointIsInfinity(xp, yp)
                case 0 {
                    xr := xp
                    yr := yp
                    zr := MONTGOMERY_ONE()
                }
                case 1 {
                    xr := ZERO()
                    yr := ZERO()
                    zr := ZERO()
                }
            }

            function projectiveIntoAffine(xp, yp, zp) -> xr, yr {
                switch zp
                case 0 {
                    xr := ZERO()
                    yr := ZERO()
                }
                // MONTGOMERY_ONE(), but compiler expects a literal.
                case 6350874878119819312338956282401532409788428879151445726012394534686998597021 {
                    xr := montgomeryDiv(xp, zp)
                    yr := montgomeryDiv(yp, zp)
                }
            }

            function projectiveDouble(xp, yp, zp) -> xr, yr, zr {
                let x_squared := montgomeryMul(xp, xp)
                let t := montgomeryAdd(x_squared, montgomeryAdd(x_squared, x_squared))
                let yz := montgomeryMul(yp, zp)
                let u := montgomeryAdd(yz, yz)
                let uxy := montgomeryMul(u, montgomeryMul(xp, yp))
                let v := montgomeryAdd(uxy, uxy)
                let w := montgomerySub(montgomeryMul(t, t), montgomeryAdd(v, v))

                xr := montgomeryMul(u, w)
                let uy := montgomeryMul(u, yp)
                let uy_squared := montgomeryMul(uy, uy)
                yr := montgomerySub(montgomeryMul(t, montgomerySub(v, w)), montgomeryAdd(uy_squared, uy_squared))
                zr := montgomeryMul(u, montgomeryMul(u, u))
            }

            function projectiveAdd(xp, yp, zp, xq, yq, zq) -> xr, yr, zr {
                let pIsInfinity := projectivePointIsInfinity(zp)
                let qIsInfinity := projectivePointIsInfinity(zq)
                if and(pIsInfinity, zq) {
                    xr := xq
                    yr := yq
                    zr := zq
                }
                if and(zp, qIsInfinity) {
                    xr := xp
                    yr := yp
                    zr := zp
                }
                switch and(eq(xp, xq), eq(yp, yq))
                case 0 {
                    let t0 := yp
                    let t1 := yq
                    let t := montgomerySub(t0, t1)
                    let u0 := montgomeryMul(xp, zq)
                    let u1 := xq
                    let u := montgomerySub(u0, u1)
                    let u2 := montgomeryMul(u, u)
                    let u3 := montgomeryMul(u2, u)
                    let w := montgomerySub(montgomeryMul(t, t), montgomeryMul(u2, montgomeryAdd(u0, u1)))
    
                    xr := montgomeryMul(u, w)
                    yr := montgomerySub(montgomeryMul(t, montgomerySub(montgomeryMul(u0, u2), w)), montgomeryMul(t0, u3))
                    zr := u3
                }
                case 1 {
                    switch and(pIsInfinity, qIsInfinity) 
                    case 0 {
                        xr, yr, zr := projectiveDouble(xp, yp, zp)
                    }
                    case 1 {
                        xr := ZERO()
                        yr := ZERO()
                        zr := ZERO()
                    }
                }            
            }

            function projectiveMul(xp, yp, zp, scalar) -> xr, yr, zr {
                xr := ZERO()
                yr := ZERO()
                zr := ZERO()
                let xq := xp
                let yq := yp
                let zq := zp
                let s := scalar
            
                switch scalar
                case 0 {}
                case 1 {
                    xr := xp
                    yr := yp
                    zr := zp
                }
                case 2 {
                    xr, yr, zr := projectiveDouble(xp, yp, zp)
                }
                default {
                    for {} gt(s, ZERO()) {} {
                        if and(s, ONE()) {
                            xr, yr, zr := projectiveAdd(xr, yr, zr, xq, yq, zq)
                        }
                        xq, yq, zq := projectiveDouble(xq, yq, zq)
                        s := shr(1, s)
                    }
                }
            }

            ////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////

            // let g1_x := calldataload(0)
            // let g1_y := calldataload(32)
            // let g2_ix := calldataload(64)
            // let g2_x := calldataload(96)
            // let g2_iy := calldataload(128)
            // let g2_y := calldataload(160)

            // if iszero(pointIsOnG1(g1_x, g1_y)) {
            //     // burnGas()
            // }

            // console_log(0x600, g1_x)
            // console_log(0x600, g1_y)
            // console_log(0x600, g2_ix)
            // console_log(0x600, g2_x)
            // console_log(0x600, g2_iy)
            // console_log(0x600, g2_y)

            let xp := MONTGOMERY_ONE()
            let yp := MONTGOMERY_TWO()
            console_log(0x100, xp)
            console_log(0x100, yp)
            let xr, yr, zr := projectiveFromAffine(xp, yp)
            console_log(0x100, xr)
            console_log(0x100, yr)
            console_log(0x100, zr)
            xp, yp := projectiveIntoAffine(xr, yr, zr)
            console_log(0x100, xp)
            console_log(0x100, yp)

            let xq, yq, zq := projectiveMul(xr, yr, zr, ZERO())
            console_log(0x100, xq)
            console_log(0x100, yq)
            console_log(0x100, zq)

            xq, yq, zq := projectiveMul(xr, yr, zr, ONE())
            console_log(0x100, xq)
            console_log(0x100, yq)
            console_log(0x100, zq)

            xq, yq, zq := projectiveMul(xr, yr, zr, TWO())
            console_log(0x100, xq)
            console_log(0x100, yq)
            console_log(0x100, zq)

            xq, yq, zq := projectiveDouble(xr, yr, zr)
            console_log(0x100, xq)
            console_log(0x100, yq)
            console_log(0x100, zq)

            xq, yq, zq := projectiveAdd(xr, yr, zr, xr, yr, zr)
            console_log(0x100, xq)
            console_log(0x100, yq)
            console_log(0x100, zq)
        }
    }
}
