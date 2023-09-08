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

            function FP6_ZERO() -> z00, z01, z10, z11, z20, z21 {
                z00 := 0
                z01 := 0
                z10 := 0
                z11 := 0
                z20 := 0
                z21 := 0
            }

            // CONSOLE.LOG Caller
            // It prints 'val' in the node console and it works using the 'mem'+0x40 memory sector
            function console_log(val) -> {
                let log_address := 0x000000000000000000636F6e736F6c652e6c6f67
                // load the free memory pointer
                let freeMemPointer := mload(0x600)
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
            //                      FP2 ARITHMETHICS
            ////////////////////////////////////////////////////////////////

            function fp2Add(a00, a01, b00, b01) -> c00, c01 {
                c00 := montgomeryAdd(a00, b00)
                c01 := montgomeryAdd(a01, b01)
            }

            function fp2Sub(a00, a01, b00, b01) -> c00, c01 {
                c00 := montgomerySub(a00, b00)
                c01 := montgomerySub(a01, b01)
            }

            function fp2ScalarMul(a00, a01, scalar) -> c00, c01 {
                c00 := montgomeryMul(a00, scalar)
                c01 := montgomeryMul(a01, scalar)
            }

            function fp2Mul(a00, a01, b00, b01) -> c00, c01 {
                c00 := montgomerySub(montgomeryMul(a00, b00), montgomeryMul(a01, b01))
                c01 := montgomeryAdd(montgomeryMul(a00, b01), montgomeryMul(a01, b00))
            }

            function fp2Inv(a00, a01) -> c00, c01 {
                let t0 := montgomeryMul(a00, a00)
                let t1 := montgomeryMul(a01, a01)
                t0 := montgomeryAdd(t0, t1)
                t1 := montgomeryModularInverse(t0)

                c00 := montgomeryMul(a00, t1)
                c01 := montgomerySub(ZERO(), montgomeryMul(a01, t1))
            }

            function mulByXi(a00, a01) -> c00, c01 {
                let t0, t1 := fp2ScalarMul(a00, a01, intoMontgomeryForm(8))
                c00 := montgomerySub(montgomeryAdd(t0, a00), a01)
                c01 := montgomeryAdd(montgomeryAdd(t1, a00), a01)
            }

            ////////////////////////////////////////////////////////////////
            //                      FP6 ARITHMETHICS
            ////////////////////////////////////////////////////////////////

            function fp6Add(a00, a01, a10, a11, a20, a21, b00, b01, b10, b11, b20, b21) -> c00, c01, c10, c11, c20, c21 {
                c00, c01 := fp2Add(a00, a01, b00, b01)
                c10, c11 := fp2Add(a10, a11, b10, b11)
                c20, c21 := fp2Add(a20, a21, b20, b21)
            }

            function fp6Sub(a00, a01, a10, a11, a20, a21, b00, b01, b10, b11, b20, b21) -> c00, c01, c10, c11, c20, c21 {
                c00, c01 := fp2Sub(a00, a01, b00, b01)
                c10, c11 := fp2Sub(a10, a11, b10, b11)
                c20, c21 := fp2Sub(a20, a21, b20, b21)
            }

            function mulByGamma(a00, a01, a10, a11, a20, a21) -> c00, c01, c10, c11, c20, c21 {
                c00, c01 := mulByXi(a20, a21)
                c10 := a00
                c11 := a01
                c20 := a10
                c21 := a11
            }

            function fp6Mul(a00, a01, a10, a11, a20, a21, b00, b01, b10, b11, b20, b21) -> c00, c01, c10, c11, c20, c21 {
                let t00, t01 := fp2Mul(a00, a01, b00, b01)
                let t10, t11 := fp2Mul(a10, a11, b10, b11)
                let t20, t21 := fp2Mul(a20, a21, b20, b21)

                let tmp0, temp1 := fp2Add(a10, a11, a20, a21)
                let tmp2, tmp3 := fp2Add(b10, b11, b20, b21)
                let tmp4, tmp5 := fp2Mul(tmp0, temp1, tmp2, tmp3)
                let tmp6, tmp7 := fp2Sub(tmp4, tmp5, t10, t11)
                let tmp8, tmp9 := fp2Sub(tmp6, tmp7, t20, t21)
                let tmp10, tmp11 := mulByXi(tmp8, tmp9)
                c00, c01 := fp2Add(tmp10, tmp11, t00, t01)

                tmp0, temp1 := fp2Add(a00, a01, a10, a11)
                tmp2, tmp3 := fp2Add(b00, b01, b10, b11)
                tmp4, tmp5 := fp2Mul(tmp0, temp1, tmp2, tmp3)
                tmp6, tmp7 := fp2Sub(tmp4, tmp5, t00, t01)
                tmp8, tmp9 := fp2Sub(tmp6, tmp7, t10, t11)
                tmp10, tmp11 := mulByXi(t20, t21)
                c10, c11 := fp2Add(tmp8, tmp9, tmp10, tmp11)

                tmp0, temp1 := fp2Add(a00, a01, a20, a21)
                tmp2, tmp3 := fp2Add(b00, b01, b20, b21)
                tmp4, tmp5 := fp2Mul(tmp0, temp1, tmp2, tmp3)
                tmp6, tmp7 := fp2Sub(tmp4, tmp5, t00, t01)
                tmp8, tmp9 := fp2Sub(tmp6, tmp7, t20, t21)
                c20, c21 := fp2Add(tmp8, tmp9, t10, t11)
            }

            function fp6MulByIndependentTerm(a00, a01, a10, a11, a20, a21, b00, b01) -> c00, c01, c10, c11, c20, c21 {
                c00, c01 := fp2Mul(a00, a01, b00, b01)
                c10, c11 := fp2Mul(a01, a10, b00, b01)
                c20, c21 := fp2Mul(a10, a11, b00, b01)
            }

            function fp6MulByIndependentAndLinearTerm(a00, a01, a10, a11, a20, a21, b00, b01, b10, b11) -> c00, c01, c10, c11, c20, c21 {
                let t00, t01 := fp2Mul(a00, a01, b00, b01)
                let t10, t11 := fp2Mul(a10, a11, b10, b11)

                let tmp00, tmp01 := fp2Add(a10, a11, a20, a21)
                tmp00, tmp01 := fp2Mul(tmp00, tmp01, b10, b11)
                tmp00, tmp01 := fp2Sub(tmp00, tmp01, t10, t11)
                tmp00, tmp01 := mulByXi(tmp00, tmp01)
                c00, c01 := fp2Add(t00, t01, tmp00, tmp01)

                tmp00, tmp01 := fp2Add(a00, a01, a10, a11)
                let tmp10, tmp11 := fp2Add(b00, b01, b10, b11)
                tmp00, tmp01 := fp2Mul(tmp00, tmp01, tmp10, tmp11)
                tmp00, tmp01 := fp2Sub(tmp00, tmp01, t00, t01)
                c10, c11 := fp2Sub(tmp00, tmp01, t10, t11)

                tmp00, tmp01 := fp2Mul(a20, a21, b00, b01)
                c20, c21 := fp2Add(tmp00, tmp01, t10, t11)
            }

            function fp6Square(a00, a01, a10, a11, a20, a21) -> c00, c01, c10, c11, c20, c21 {
                let tmp0, tmp1 := fp2Mul(a00, a01, a10, a11)
                tmp0, tmp1 := fp2Add(tmp0, tmp1, tmp0, tmp1)

                let tmp2, tmp3 := fp2Mul(a20, a21, a20, a21)
                let tmp4, tmp5 := mulByXi(tmp2, tmp3)
                c10, c11 := fp2Add(tmp4, tmp5, tmp0, tmp1)

                c20, c21 := fp2Sub(tmp0, tmp1, tmp2, tmp3)

                let tmp6, tmp7 := fp2Mul(a00, a01, a00, a01)
                let tmp8, tmp9 := fp2Sub(a00, a01, a10, a11)
                tmp0, tmp1 := fp2Add(tmp8, tmp9, a20, a21)
            
                let tmp10, tmp11 := fp2Mul(a00, a01, a20, a21)
                tmp2, tmp3 := fp2Add(tmp10, tmp11, tmp10, tmp11)
                tmp0, tmp1 := fp2Mul(tmp0, tmp1, tmp0, tmp1)

                let tmp12, tmp13 := mulByXi(tmp2, tmp3)
                c00, c01 := fp2Add(tmp12, tmp13, tmp6, tmp7)

                let tmp14, tmp15 := fp2Add(c20, c21, tmp0, tmp1)
                tmp14, tmp15 := fp2Add(tmp14, tmp15, tmp2, tmp3)
                c20, c21 := fp2Sub(tmp14, tmp15, tmp6, tmp7)
            
            }

            function fp6Inv(a00, a01, a10, a11, a20, a21) -> c00, c01, c10, c11, c20, c21 {
                let t00, t01 := fp2Mul(a00, a01, a00, a01)
                let t10, t11 := fp2Mul(a10, a11, a10, a11)
                let t20, t21 := fp2Mul(a20, a21, a20, a21)
                let t30, t31 := fp2Mul(a00, a01, a10, a11)
                let t40, t41 := fp2Mul(a00, a01, a20, a21)
                let t50, t51 := fp2Mul(a20, a21, a10, a11)
                let t50Xi, t51Xi := mulByXi(t50, t51)
                c00, c01 := fp2Sub(t00, t01, t50Xi, t51Xi)
                let t20Xi, t21Xi := mulByXi(t20, t21)
                c10, c11 := fp2Sub(t20Xi, t21Xi, t30, t31)
                c20, c21 := fp2Sub(t10, t11, t40, t41)
                let t60, t61 := fp2Mul(a00, a01, c00, c01)
                let a20Xi, a21Xi := mulByXi(a20, a21)
                let a20XiC10, a21XiC11 := fp2Mul(a20Xi, a21Xi, c10, c11)
                t60, t61 := fp2Add(t60, t61, a20XiC10, a21XiC11)
                let a10Xi, a11Xi := mulByXi(a10, a11)
                let a10XiC20, a11XiC21 := fp2Mul(a10Xi, a11Xi, c20, c21)
                t60, t61 := fp2Add(t60, t61, a10XiC20, a11XiC21)
                t60, t61 := fp2Inv(t60, t61)
                c00, c01 := fp2Mul(c00, c01, t60, t61)
                c10, c11 := fp2Mul(c10, c11, t60, t61)
                c20, c21 := fp2Mul(c20, c21, t60, t61)
            }

            ////////////////////////////////////////////////////////////////
            //                      FP12 ARITHMETHICS
            ////////////////////////////////////////////////////////////////

            function fp12Add(a000, a001, a010, a011, a020, a021, a100, a101, a110, a111, a120, a121, b000, b001, b010, b011, b020, b021, b100, b101, b110, b111, b120, b121) -> c000, c001, c010, c011, c020, c021, c100, c101, c110, c111, c120, c121 {
                c000, c001, c010, c011, c020, c021 := fp6Add(a000, a001, a010, a011, a020, a021, b000, b001, b010, b011, b020, b021)
                c100, c101, c110, c111, c120, c121 := fp6Add(a100, a101, a110, a111, a120, a121, b100, b101, b110, b111, b120, b121)
            }

            function fp12Sub(a000, a001, a010, a011, a020, a021, a100, a101, a110, a111, a120, a121, b000, b001, b010, b011, b020, b021, b100, b101, b110, b111, b120, b121) -> c000, c001, c010, c011, c020, c021, c100, c101, c110, c111, c120, c121 {
                c000, c001, c010, c011, c020, c021 := fp6Sub(a000, a001, a010, a011, a020, a021, b000, b001, b010, b011, b020, b021)
                c100, c101, c110, c111, c120, c121 := fp6Sub(a100, a101, a110, a111, a120, a121, b100, b101, b110, b111, b120, b121)
            }

            function fp12Mul(a000, a001, a010, a011, a020, a021, a100, a101, a110, a111, a120, a121, b000, b001, b010, b011, b020, b021, b100, b101, b110, b111, b120, b121) -> c000, c001, c010, c011, c020, c021, c100, c101, c110, c111, c120, c121 {
                let t000, t001, t010, t011, t020, t021 := fp6Mul(a000, a001, a010, a011, a020, a021, b000, b001, b010, b011, b020, b021)
                let t100, t101, t110, t111, t120, t121 := fp6Mul(a100, a101, a110, a111, a120, a121, b100, b101, b110, b111, b120, b121)
                let t200, t201, t210, t211, t220, t221 := mulByGamma(t100, t101, t110, t111, t120, t121)
                c000, c001, c010, c011, c020, c021 := fp6Add(t000, t001, t010, t011, t020, t021, t200, t201, t210, t211, t220, t221)
                let t300, t301, t310, t311, t320, t321 := fp6Add(a000, a001, a010, a011, a020, a021, a100, a101, a110, a111, a120, a121)
                let t400, t401, t410, t411, t420, t421 := fp6Add(b000, b001, b010, b011, b020, b021, b100, b101, b110, b111, b120, b121)
                c100, c101, c110, c111, c120, c121 := fp6Mul(t300, t301, t310, t311, t320, t321, t400, t401, t410, t411, t420, t421)
                c100, c101, c110, c111, c120, c121 := fp6Sub(c100, c101, c110, c111, c120, c121, t000, t001, t010, t011, t020, t021)
                c100, c101, c110, c111, c120, c121 := fp6Sub(c100, c101, c110, c111, c120, c121, t100, t101, t110, t111, t120, t121)
            }

            function fp12Square(a000, a001, a010, a011, a020, a021, a100, a101, a110, a111, a120, a121) -> c000, c001, c010, c011, c020, c021, c100, c101, c110, c111, c120, c121 {
                let t100, t101, t110, t111, t120, t121 := fp6Sub(a000, a001, a010, a011, a020, a021, a100, a101, a110, a111, a120, a121)
                let t200, t201, t210, t211, t220, t221 := mulByGamma(a100, a101, a110, a111, a120, a121)
                let t300, t301, t310, t311, t320, t321 := fp6Sub(a000, a001, a010, a011, a020, a021, t200, t201, t210, t211, t220, t221)
                let t400, t401, t410, t411, t420, t421 := fp6Mul(a000, a001, a010, a011, a020, a021, a100, a101, a110, a111, a120, a121)
                let t500, t501, t510, t511, t520, t521 := fp6Mul(t100, t101, t110, t111, t120, t121, t300, t301, t310, t311, t320, t321)
                let t600, t601, t610, t611, t620, t621 := fp6Add(t400, t401, t410, t411, t420, t421, t500, t501, t510, t511, t520, t521)
                c100, c101, c110, c111, c120, c121 := fp6Add(t400, t401, t410, t411, t420, t421, t400, t401, t410, t411, t420, t421)
                let t700, t701, t710, t711, t720, t721 := mulByGamma(t400, t401, t410, t411, t420, t421)
                c000, c001, c010, c011, c020, c021 := fp6Add(t600, t601, t610, t611, t620, t621, t700, t701, t710, t711, t720, t721)
            }

            function fp12Inv(a000, a001, a010, a011, a020, a021, a100, a101, a110, a111, a120, a121) -> c000, c001, c010, c011, c020, c021, c100, c101, c110, c111, c120, c121 {
                let t000, t001, t010, t011, t020, t021 := fp6Square(a000, a001, a010, a011, a020, a021)
                let t100, t101, t110, t111, t120, t121 := fp6Square(a100, a101, a110, a111, a120, a121)
                let t200, t201, t210, t211, t220, t221 := mulByGamma(t100, t101, t110, t111, t120, t121)
                t000, t001, t010, t011, t020, t021 := fp6Sub(t000, t001, t010, t011, t020, t021, t200, t201, t210, t211, t220, t221)
                t100, t101, t110, t111, t120, t121 := fp6Inv(t000, t001, t010, t011, t020, t021)
                c000, c001, c010, c011, c020, c021 := fp6Mul(a000, a001, a010, a011, a020, a021, t100, t101, t110, t111, t120, t121)
                let z00, z01, z10, z11, z20, z21 :=  FP6_ZERO()
                c100, c101, c110, c111, c120, c121 := fp6Mul(a100, a101, a110, a111, a120, a121,t100, t101, t110, t111, t120, t121)
                c100, c101, c110, c111, c120, c121 := fp6Sub(z00, z01, z10, z11, z20, z21, c100, c101, c110, c111, c120, c121)
            }

            function finalExponentiation(a000, a001, a010, a011, a020, a021, a100, a101, a110, a111, a120, a121) -> f000, f001, f010, f011, f020, f021, f100, f101, f110, f111, f120, f121 {
                f000 := a000
                f001 := a001
                f010 := a010
                f011 := a011
                f020 := a020
                f021 := a021
                f100 := a100
                f101 := a101
                f110 := a110
                f111 := a111
                f120 := a120
                f121 := a121

                let t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121 := fp12Conjugate(f000, f001, f010, f011, f020, f021, f100, f101, f110, f111, f120, f121)
                f000, f001, f010, f011, f020, f021, f100, f101, f110, f111, f120, f121 := fp12Inv(f000, f001, f010, f011, f020, f021, f100, f101, f110, f111, f120, f121)
                t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121 := fp12Mul(t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121, f000, f001, f010, f011, f020, f021, f100, f101, f110, f111, f120, f121)
                let t1000, t1001, t1010, t1011, t1020, t1021, t1100, t1101, t1110, t1111, t1120, t1121 := frobeniusSquare(t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121)
                f000, f001, f010, f011, f020, f021, f100, f101, f110, f111, f120, f121 := fp12Mul(t1000, t1001, t1010, t1011, t1020, t1021, t1100, t1101, t1110, t1111, t1120, t1121, t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121)

                t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121 := fp2Expt(f000, f001, f010, f011, f020, f021, f100, f101, f110, f111, f120, f121)
                t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121 := fp12Conjugate(t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121)
                t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121 := cyloctimicSquare(t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121)
                t1000, t1001, t1010, t1011, t1020, t1021, t1100, t1101, t1110, t1111, t1120, t1121 := cyloctimicSquare(t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121)
                t1000, t1001, t1010, t1011, t1020, t1021, t1100, t1101, t1110, t1111, t1120, t1121 := fp12Mul(t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121, t1000, t1001, t1010, t1011, t1020, t1021, t1100, t1101, t1110, t1111, t1120, t1121)
                let t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121 := fp12Expt(t1000, t1001, t1010, t1011, t1020, t1021, t1100, t1101, t1110, t1111, t1120, t1121)
                t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121 := fp12Conjugate(t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121)
                let t3000, t3001, t3010, t3011, t3020, t3021, t3100, t3101, t3110, t3111, t3120, t3121 := fp12Conjugate(t1000, t1001, t1010, t1011, t1020, t1021, t1100, t1101, t1110, t1111, t1120, t1121)
                t1000, t1001, t1010, t1011, t1020, t1021, t1100, t1101, t1110, t1111, t1120, t1121 := fp12Mul(t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121, t3000, t3001, t3010, t3011, t3020, t3021, t3100, t3101, t3110, t3111, t3120, t3121)
                t3000, t3001, t3010, t3011, t3020, t3021, t3100, t3101, t3110, t3111, t3120, t3121 := cyloctimicSquare(t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121)
                let t4000, t4001, t4010, t4011, t4020, t4021, t4100, t4101, t4110, t4111, t4120, t4121 := fp12Expt(t3000, t3001, t3010, t3011, t3020, t3021, t3100, t3101, t3110, t3111, t3120, t3121)
                t4000, t4001, t4010, t4011, t4020, t4021, t4100, t4101, t4110, t4111, t4120, t4121 := fp12Mul(t4000, t4001, t4010, t4011, t4020, t4021, t4100, t4101, t4110, t4111, t4120, t4121, t1000, t1001, t1010, t1011, t1020, t1021, t1100, t1101, t1110, t1111, t1120, t1121)
                t3000, t3001, t3010, t3011, t3020, t3021, t3100, t3101, t3110, t3111, t3120, t3121 := fp12Mul(t4000, t4001, t4010, t4011, t4020, t4021, t4100, t4101, t4110, t4111, t4120, t4121, t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121)
                t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121 := fp12Mul(t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121, t4000, t4001, t4010, t4011, t4020, t4021, t4100, t4101, t4110, t4111, t4120, t4121)
                t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121 := fp12Mul(t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121, f000, f001, f010, f011, f020, f021, f100, f101, f110, f111, f120, f121)
                t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121 := frobenius(t3000, t3001, t3010, t3011, t3020, t3021, t3100, t3101, t3110, t3111, t3120, t3121)
                t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121 := fp12Mul(t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121, t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121)
                t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121 := frobeniusSquare(t4000, t4001, t4010, t4011, t4020, t4021, t4100, t4101, t4110, t4111, t4120, t4121)
                t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121 := fp12Mul(t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121, t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121)
                t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121 := fp12Conjugate(f000, f001, f010, f011, f020, f021, f100, f101, f110, f111, f120, f121)
                t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121 := fp2Mul(t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121, t3000, t3001, t3010, t3011, t3020, t3021, t3100, t3101, t3110, t3111, t3120, t3121)
                t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121 := frobeniusCube(t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121)
                f000, f001, f010, f011, f020, f021, f100, f101, f110, f111, f120, f121 := fp12Mul(t2000, t2001, t2010, t2011, t2020, t2021, t2100, t2101, t2110, t2111, t2120, t2121, t0000, t0001, t0010, t0011, t0020, t0021, t0100, t0101, t0110, t0111, t0120, t0121)
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

            // // FP6 TESTS:

            // let one := MONTGOMERY_ONE()
            // let two := MONTGOMERY_TWO()

            // let fp2_a0 := one
            // let fp2_a1 := two
            // let fp2_b0 := two
            // let fp2_b1 := two

            // let fp6_a00 := one
            // let fp6_a01 := two
            // let fp6_a10 := one
            // let fp6_a11 := two
            // let fp6_a20 := one
            // let fp6_a21 := two

            // let fp6_b00 := two
            // let fp6_b01 := two
            // let fp6_b10 := two
            // let fp6_b11 := two
            // let fp6_b20 := two
            // let fp6_b21 := two

            
            // let c00, c01 := fp2Add(fp2_a0, fp2_a1, fp2_b0, fp2_b1)
            // console_log(outOfMontgomeryForm(c00)) // 3
            // console_log(outOfMontgomeryForm(c01)) // 4

            // c00, c01 := fp2ScalarMul(fp2_a0, fp2_a1, two)
            // console_log(outOfMontgomeryForm(c00)) // 2
            // console_log(outOfMontgomeryForm(c01)) // 4

            // c00, c01 := fp2Mul(fp2_a0, fp2_a1, fp2_b0, fp2_b1)
            // console_log(outOfMontgomeryForm(montgomerySub(0, c00))) // 2
            // console_log(outOfMontgomeryForm(c01)) // 6

            // c00, c01 := fp2Sub(fp2_b0, fp2_b1, fp2_a0, fp2_a1)
            // console_log(outOfMontgomeryForm(c00)) // 1
            // console_log(outOfMontgomeryForm(c01)) // 0

            // let c00_inv, c01_inv := fp2Inv(fp2_a0, fp2_a1)
            // c00, c01 := fp2Mul(fp2_a0, fp2_a1, c00_inv, c01_inv)
            // console_log(outOfMontgomeryForm(c00)) // 1
            // console_log(outOfMontgomeryForm(c01)) // 0

            // let c00, c01, c10, c11, c20, c21 := fp6Add(fp6_a00, fp6_a01, fp6_a10, fp6_a11, fp6_a20, fp6_a21, fp6_b00, fp6_b01, fp6_b10, fp6_b11, fp6_b20, fp6_b21)
            // console_log(outOfMontgomeryForm(c00)) // 3
            // console_log(outOfMontgomeryForm(c01)) // 4 
            // console_log(outOfMontgomeryForm(c10)) // 3
            // console_log(outOfMontgomeryForm(c11)) // 4
            // console_log(outOfMontgomeryForm(c20)) // 3 
            // console_log(outOfMontgomeryForm(c21)) // 4

            // let fp6_b00 := one
            // let fp6_b01 := two
            // let fp6_b10 := one
            // let fp6_b11 := one
            // let fp6_b20 := one
            // let fp6_b21 := 0


            // c00, c01, c10, c11, c20, c21 := fp6Sub(fp6_a00, fp6_a01, fp6_a10, fp6_a11, fp6_a20, fp6_a21, fp6_b00, fp6_b01, fp6_b10, fp6_b11, fp6_b20, fp6_b21)
            // console_log(outOfMontgomeryForm(c00)) // 0
            // console_log(outOfMontgomeryForm(c01)) // 0 
            // console_log(outOfMontgomeryForm(c10)) // 0
            // console_log(outOfMontgomeryForm(c11)) // 1
            // console_log(outOfMontgomeryForm(c20)) // 0 
            // console_log(outOfMontgomeryForm(c21)) // 2

            // let c00_aux, c01_aux, c10_aux, c11_aux, c20_aux, c21_aux := fp6Mul(fp6_a00, fp6_a01, fp6_a10, fp6_a11, fp6_a20, fp6_a21, MONTGOMERY_TWO(), 0, 0, 0, 0, 0)
            // c00, c01, c10, c11, c20, c21 := fp6Add(fp6_a00, fp6_a01, fp6_a10, fp6_a11, fp6_a20, fp6_a21, fp6_a00, fp6_a01, fp6_a10, fp6_a11, fp6_a20, fp6_a21)
            // console_log(outOfMontgomeryForm(c00_aux))
            // console_log(outOfMontgomeryForm(c00))
            // console_log(outOfMontgomeryForm(c01_aux))
            // console_log(outOfMontgomeryForm(c01)) 
            // console_log(outOfMontgomeryForm(c10_aux))
            // console_log(outOfMontgomeryForm(c10))
            // console_log(outOfMontgomeryForm(c11_aux))
            // console_log(outOfMontgomeryForm(c11))
            // console_log(outOfMontgomeryForm(c20_aux))
            // console_log(outOfMontgomeryForm(c20)) 
            // console_log(outOfMontgomeryForm(c21_aux))
            // console_log(outOfMontgomeryForm(c21)) 

            // let c00, c01, c10, c11, c20, c21 := fp6Mul(fp6_a00, fp6_a01, fp6_a10, fp6_a11, fp6_a20, fp6_a21, fp6_a00, fp6_a01, fp6_a10, fp6_a11, fp6_a20, fp6_a21)
            // let c00_sq, c01_sq, c10_sq, c11_sq, c20_sq, c21_sq := fp6Square(fp6_a00, fp6_a01, fp6_a10, fp6_a11, fp6_a20, fp6_a21)
            // console_log(outOfMontgomeryForm(c00_sq))
            // console_log(outOfMontgomeryForm(c00))
            // console_log(outOfMontgomeryForm(c01_sq))
            // console_log(outOfMontgomeryForm(c01))
            // console_log(outOfMontgomeryForm(c10_sq))
            // console_log(outOfMontgomeryForm(c10))
            // console_log(outOfMontgomeryForm(c11_sq))
            // console_log(outOfMontgomeryForm(c11))
            // console_log(outOfMontgomeryForm(c20_sq))
            // console_log(outOfMontgomeryForm(c20))
            // console_log(outOfMontgomeryForm(c21_sq))
            // console_log(outOfMontgomeryForm(c21))

            // let fp6_a00_inv, fp6_a01_inv, fp6_a10_inv, fp6_a11_inv, fp6_a20_inv, fp6_a21_inv := fp6Inv(fp6_a00, fp6_a01, fp6_a10, fp6_a11, fp6_a20, fp6_a21)
            // c00, c01, c10, c11, c20, c21 := fp6Mul(fp6_a00, fp6_a01, fp6_a10, fp6_a11, fp6_a20, fp6_a21, fp6_a00_inv, fp6_a01_inv, fp6_a10_inv, fp6_a11_inv, fp6_a20_inv, fp6_a21_inv)
            // console_log(outOfMontgomeryForm(c00)) // 1
            // console_log(outOfMontgomeryForm(c01)) // 0
            // console_log(outOfMontgomeryForm(c10)) // 0
            // console_log(outOfMontgomeryForm(c11)) // 0
            // console_log(outOfMontgomeryForm(c20)) // 0
            // console_log(outOfMontgomeryForm(c21)) // 0

            // // FP12 TESTS:

            let one := MONTGOMERY_ONE()
            let two := MONTGOMERY_TWO()

            // // ADD

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Add(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
            // console_log(outOfMontgomeryForm(t000)) // 0
            // console_log(outOfMontgomeryForm(t001)) // 0
            // console_log(outOfMontgomeryForm(t010)) // 0
            // console_log(outOfMontgomeryForm(t011)) // 0
            // console_log(outOfMontgomeryForm(t020)) // 0
            // console_log(outOfMontgomeryForm(t021)) // 0
            // console_log(outOfMontgomeryForm(t100)) // 0
            // console_log(outOfMontgomeryForm(t101)) // 0
            // console_log(outOfMontgomeryForm(t110)) // 0
            // console_log(outOfMontgomeryForm(t111)) // 0
            // console_log(outOfMontgomeryForm(t120)) // 0
            // console_log(outOfMontgomeryForm(t121)) // 0

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Add(0,0,0,0,0,0,0,0,0,0,0,0,one,one,one,one,one,one,one,one,one,one,one,one)
            // console_log(outOfMontgomeryForm(t000)) // 1
            // console_log(outOfMontgomeryForm(t001)) // 1
            // console_log(outOfMontgomeryForm(t010)) // 1
            // console_log(outOfMontgomeryForm(t011)) // 1
            // console_log(outOfMontgomeryForm(t020)) // 1
            // console_log(outOfMontgomeryForm(t021)) // 1
            // console_log(outOfMontgomeryForm(t100)) // 1
            // console_log(outOfMontgomeryForm(t101)) // 1
            // console_log(outOfMontgomeryForm(t110)) // 1
            // console_log(outOfMontgomeryForm(t111)) // 1
            // console_log(outOfMontgomeryForm(t120)) // 1
            // console_log(outOfMontgomeryForm(t121)) // 1

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Add(one,one,one,one,one,one,one,one,one,one,one,one,0,0,0,0,0,0,0,0,0,0,0,0)
            // console_log(outOfMontgomeryForm(t000)) // 1
            // console_log(outOfMontgomeryForm(t001)) // 1
            // console_log(outOfMontgomeryForm(t010)) // 1
            // console_log(outOfMontgomeryForm(t011)) // 1
            // console_log(outOfMontgomeryForm(t020)) // 1
            // console_log(outOfMontgomeryForm(t021)) // 1
            // console_log(outOfMontgomeryForm(t100)) // 1
            // console_log(outOfMontgomeryForm(t101)) // 1
            // console_log(outOfMontgomeryForm(t110)) // 1
            // console_log(outOfMontgomeryForm(t111)) // 1
            // console_log(outOfMontgomeryForm(t120)) // 1
            // console_log(outOfMontgomeryForm(t121)) // 1

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Add(one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one)
            // console_log(outOfMontgomeryForm(t000)) // 2
            // console_log(outOfMontgomeryForm(t001)) // 2
            // console_log(outOfMontgomeryForm(t010)) // 2
            // console_log(outOfMontgomeryForm(t011)) // 2
            // console_log(outOfMontgomeryForm(t020)) // 2
            // console_log(outOfMontgomeryForm(t021)) // 2
            // console_log(outOfMontgomeryForm(t100)) // 2
            // console_log(outOfMontgomeryForm(t101)) // 2
            // console_log(outOfMontgomeryForm(t110)) // 2
            // console_log(outOfMontgomeryForm(t111)) // 2
            // console_log(outOfMontgomeryForm(t120)) // 2
            // console_log(outOfMontgomeryForm(t121)) // 2

            // // SUB

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Sub(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
            // console_log(outOfMontgomeryForm(t000)) // 0
            // console_log(outOfMontgomeryForm(t001)) // 0
            // console_log(outOfMontgomeryForm(t010)) // 0
            // console_log(outOfMontgomeryForm(t011)) // 0
            // console_log(outOfMontgomeryForm(t020)) // 0
            // console_log(outOfMontgomeryForm(t021)) // 0
            // console_log(outOfMontgomeryForm(t100)) // 0
            // console_log(outOfMontgomeryForm(t101)) // 0
            // console_log(outOfMontgomeryForm(t110)) // 0
            // console_log(outOfMontgomeryForm(t111)) // 0
            // console_log(outOfMontgomeryForm(t120)) // 0
            // console_log(outOfMontgomeryForm(t121)) // 0

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Sub(two,two,two,two,two,two,two,two,two,two,two,two,one,one,one,one,one,one,one,one,one,one,one,one)
            // console_log(outOfMontgomeryForm(t000)) // 1
            // console_log(outOfMontgomeryForm(t001)) // 1
            // console_log(outOfMontgomeryForm(t010)) // 1
            // console_log(outOfMontgomeryForm(t011)) // 1
            // console_log(outOfMontgomeryForm(t020)) // 1
            // console_log(outOfMontgomeryForm(t021)) // 1
            // console_log(outOfMontgomeryForm(t100)) // 1
            // console_log(outOfMontgomeryForm(t101)) // 1
            // console_log(outOfMontgomeryForm(t110)) // 1
            // console_log(outOfMontgomeryForm(t111)) // 1
            // console_log(outOfMontgomeryForm(t120)) // 1
            // console_log(outOfMontgomeryForm(t121)) // 1

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Sub(one,one,one,one,one,one,one,one,one,one,one,one,0,0,0,0,0,0,0,0,0,0,0,0)
            // console_log(outOfMontgomeryForm(t000)) // 1
            // console_log(outOfMontgomeryForm(t001)) // 1
            // console_log(outOfMontgomeryForm(t010)) // 1
            // console_log(outOfMontgomeryForm(t011)) // 1
            // console_log(outOfMontgomeryForm(t020)) // 1
            // console_log(outOfMontgomeryForm(t021)) // 1
            // console_log(outOfMontgomeryForm(t100)) // 1
            // console_log(outOfMontgomeryForm(t101)) // 1
            // console_log(outOfMontgomeryForm(t110)) // 1
            // console_log(outOfMontgomeryForm(t111)) // 1
            // console_log(outOfMontgomeryForm(t120)) // 1
            // console_log(outOfMontgomeryForm(t121)) // 1

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Sub(one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one)
            // console_log(outOfMontgomeryForm(t000)) // 0
            // console_log(outOfMontgomeryForm(t001)) // 0
            // console_log(outOfMontgomeryForm(t010)) // 0
            // console_log(outOfMontgomeryForm(t011)) // 0
            // console_log(outOfMontgomeryForm(t020)) // 0
            // console_log(outOfMontgomeryForm(t021)) // 0
            // console_log(outOfMontgomeryForm(t100)) // 0
            // console_log(outOfMontgomeryForm(t101)) // 0
            // console_log(outOfMontgomeryForm(t110)) // 0
            // console_log(outOfMontgomeryForm(t111)) // 0
            // console_log(outOfMontgomeryForm(t120)) // 0
            // console_log(outOfMontgomeryForm(t121)) // 0

            // // MUL BY 0

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Mul(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
            // console_log(outOfMontgomeryForm(t000)) // 0
            // console_log(outOfMontgomeryForm(t001)) // 0
            // console_log(outOfMontgomeryForm(t010)) // 0
            // console_log(outOfMontgomeryForm(t011)) // 0
            // console_log(outOfMontgomeryForm(t020)) // 0
            // console_log(outOfMontgomeryForm(t021)) // 0
            // console_log(outOfMontgomeryForm(t100)) // 0
            // console_log(outOfMontgomeryForm(t101)) // 0
            // console_log(outOfMontgomeryForm(t110)) // 0
            // console_log(outOfMontgomeryForm(t111)) // 0
            // console_log(outOfMontgomeryForm(t120)) // 0
            // console_log(outOfMontgomeryForm(t121)) // 0

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Mul(one,one,one,one,one,one,one,one,one,one,one,one,0,0,0,0,0,0,0,0,0,0,0,0)
            // console_log(outOfMontgomeryForm(t000)) // 0
            // console_log(outOfMontgomeryForm(t001)) // 0
            // console_log(outOfMontgomeryForm(t010)) // 0
            // console_log(outOfMontgomeryForm(t011)) // 0
            // console_log(outOfMontgomeryForm(t020)) // 0
            // console_log(outOfMontgomeryForm(t021)) // 0
            // console_log(outOfMontgomeryForm(t100)) // 0
            // console_log(outOfMontgomeryForm(t101)) // 0
            // console_log(outOfMontgomeryForm(t110)) // 0
            // console_log(outOfMontgomeryForm(t111)) // 0
            // console_log(outOfMontgomeryForm(t120)) // 0
            // console_log(outOfMontgomeryForm(t121)) // 0

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Mul(0,0,0,0,0,0,0,0,0,0,0,0,two,two,two,two,two,two,two,two,two,two,two,two)
            // console_log(outOfMontgomeryForm(t000)) // 0
            // console_log(outOfMontgomeryForm(t001)) // 0
            // console_log(outOfMontgomeryForm(t010)) // 0
            // console_log(outOfMontgomeryForm(t011)) // 0
            // console_log(outOfMontgomeryForm(t020)) // 0
            // console_log(outOfMontgomeryForm(t021)) // 0
            // console_log(outOfMontgomeryForm(t100)) // 0
            // console_log(outOfMontgomeryForm(t101)) // 0
            // console_log(outOfMontgomeryForm(t110)) // 0
            // console_log(outOfMontgomeryForm(t111)) // 0
            // console_log(outOfMontgomeryForm(t120)) // 0
            // console_log(outOfMontgomeryForm(t121)) // 0

            // // MUL BY 1

            // t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Mul(one,one,one,one,one,one,one,one,one,one,one,one,one,0,0,0,0,0,0,0,0,0,0,0)
            // console_log(outOfMontgomeryForm(t000)) // 1
            // console_log(outOfMontgomeryForm(t001)) // 1
            // console_log(outOfMontgomeryForm(t010)) // 1
            // console_log(outOfMontgomeryForm(t011)) // 1
            // console_log(outOfMontgomeryForm(t020)) // 1
            // console_log(outOfMontgomeryForm(t021)) // 1
            // console_log(outOfMontgomeryForm(t100)) // 1
            // console_log(outOfMontgomeryForm(t101)) // 1
            // console_log(outOfMontgomeryForm(t110)) // 1
            // console_log(outOfMontgomeryForm(t111)) // 1
            // console_log(outOfMontgomeryForm(t120)) // 1
            // console_log(outOfMontgomeryForm(t121)) // 1

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Mul(one,0,0,0,0,0,0,0,0,0,0,0,two,two,two,two,two,two,two,two,two,two,two,two)
            // console_log(outOfMontgomeryForm(t000)) // 2
            // console_log(outOfMontgomeryForm(t001)) // 2
            // console_log(outOfMontgomeryForm(t010)) // 2
            // console_log(outOfMontgomeryForm(t011)) // 2
            // console_log(outOfMontgomeryForm(t020)) // 2
            // console_log(outOfMontgomeryForm(t021)) // 2
            // console_log(outOfMontgomeryForm(t100)) // 2
            // console_log(outOfMontgomeryForm(t101)) // 2
            // console_log(outOfMontgomeryForm(t110)) // 2
            // console_log(outOfMontgomeryForm(t111)) // 2
            // console_log(outOfMontgomeryForm(t120)) // 2
            // console_log(outOfMontgomeryForm(t121)) // 2

            // // MUL BY 2

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Mul(one,one,one,one,one,one,one,one,one,one,one,one,two,0,0,0,0,0,0,0,0,0,0,0)
            // console_log(outOfMontgomeryForm(t000)) // 2
            // console_log(outOfMontgomeryForm(t001)) // 2
            // console_log(outOfMontgomeryForm(t010)) // 2
            // console_log(outOfMontgomeryForm(t011)) // 2
            // console_log(outOfMontgomeryForm(t020)) // 2
            // console_log(outOfMontgomeryForm(t021)) // 2
            // console_log(outOfMontgomeryForm(t100)) // 2
            // console_log(outOfMontgomeryForm(t101)) // 2
            // console_log(outOfMontgomeryForm(t110)) // 2
            // console_log(outOfMontgomeryForm(t111)) // 2
            // console_log(outOfMontgomeryForm(t120)) // 2
            // console_log(outOfMontgomeryForm(t121)) // 2

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Mul(two,0,0,0,0,0,0,0,0,0,0,0,two,two,two,two,two,two,two,two,two,two,two,two)
            // console_log(outOfMontgomeryForm(t000)) // 4
            // console_log(outOfMontgomeryForm(t001)) // 4
            // console_log(outOfMontgomeryForm(t010)) // 4
            // console_log(outOfMontgomeryForm(t011)) // 4
            // console_log(outOfMontgomeryForm(t020)) // 4
            // console_log(outOfMontgomeryForm(t021)) // 4
            // console_log(outOfMontgomeryForm(t100)) // 4
            // console_log(outOfMontgomeryForm(t101)) // 4
            // console_log(outOfMontgomeryForm(t110)) // 4
            // console_log(outOfMontgomeryForm(t111)) // 4
            // console_log(outOfMontgomeryForm(t120)) // 4
            // console_log(outOfMontgomeryForm(t121)) // 4

            // // SQUARE OF 0 AND 1

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Square(0,0,0,0,0,0,0,0,0,0,0,0)
            // console_log(outOfMontgomeryForm(t000)) // 0
            // console_log(outOfMontgomeryForm(t001)) // 0
            // console_log(outOfMontgomeryForm(t010)) // 0
            // console_log(outOfMontgomeryForm(t011)) // 0
            // console_log(outOfMontgomeryForm(t020)) // 0
            // console_log(outOfMontgomeryForm(t021)) // 0
            // console_log(outOfMontgomeryForm(t100)) // 0
            // console_log(outOfMontgomeryForm(t101)) // 0
            // console_log(outOfMontgomeryForm(t110)) // 0
            // console_log(outOfMontgomeryForm(t111)) // 0
            // console_log(outOfMontgomeryForm(t120)) // 0
            // console_log(outOfMontgomeryForm(t121)) // 0

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Square(one,0,0,0,0,0,0,0,0,0,0,0)
            // console_log(outOfMontgomeryForm(t000)) // 1
            // console_log(outOfMontgomeryForm(t001)) // 0
            // console_log(outOfMontgomeryForm(t010)) // 0
            // console_log(outOfMontgomeryForm(t011)) // 0
            // console_log(outOfMontgomeryForm(t020)) // 0
            // console_log(outOfMontgomeryForm(t021)) // 0
            // console_log(outOfMontgomeryForm(t100)) // 0
            // console_log(outOfMontgomeryForm(t101)) // 0
            // console_log(outOfMontgomeryForm(t110)) // 0
            // console_log(outOfMontgomeryForm(t111)) // 0
            // console_log(outOfMontgomeryForm(t120)) // 0
            // console_log(outOfMontgomeryForm(t121)) // 0

            // // MUL AND SQUARE

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Square(two,two,two,two,two,two,two,two,two,two,two,two)
            // let t200, t201, t210, t211, t220, t221, t300, t301, t310, t311, t320, t321 := fp12Mul(two,two,two,two,two,two,two,two,two,two,two,two,two,two,two,two,two,two,two,two,two,two,two,two)
            // console_log(outOfMontgomeryForm(t000)) // Same as below
            // console_log(outOfMontgomeryForm(t200))
            // console_log(outOfMontgomeryForm(t001)) // Same as below
            // console_log(outOfMontgomeryForm(t201))
            // console_log(outOfMontgomeryForm(t010)) // Same as below
            // console_log(outOfMontgomeryForm(t210))
            // console_log(outOfMontgomeryForm(t011)) // Same as below
            // console_log(outOfMontgomeryForm(t211))
            // console_log(outOfMontgomeryForm(t020)) // Same as below
            // console_log(outOfMontgomeryForm(t220))
            // console_log(outOfMontgomeryForm(t021)) // Same as below
            // console_log(outOfMontgomeryForm(t221))
            // console_log(outOfMontgomeryForm(t100)) // Same as below
            // console_log(outOfMontgomeryForm(t300))
            // console_log(outOfMontgomeryForm(t101)) // Same as below
            // console_log(outOfMontgomeryForm(t301))
            // console_log(outOfMontgomeryForm(t110)) // Same as below
            // console_log(outOfMontgomeryForm(t310))
            // console_log(outOfMontgomeryForm(t111)) // Same as below
            // console_log(outOfMontgomeryForm(t311))
            // console_log(outOfMontgomeryForm(t120)) // Same as below
            // console_log(outOfMontgomeryForm(t320))
            // console_log(outOfMontgomeryForm(t121)) // Same as below
            // console_log(outOfMontgomeryForm(t321))

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Square(one,one,one,one,one,one,one,one,one,one,one,one)
            // let t200, t201, t210, t211, t220, t221, t300, t301, t310, t311, t320, t321 := fp12Mul(one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one,one)
            // console_log(outOfMontgomeryForm(t000)) // Same as below
            // console_log(outOfMontgomeryForm(t200))
            // console_log(outOfMontgomeryForm(t001)) // Same as below
            // console_log(outOfMontgomeryForm(t201))
            // console_log(outOfMontgomeryForm(t010)) // Same as below
            // console_log(outOfMontgomeryForm(t210))
            // console_log(outOfMontgomeryForm(t011)) // Same as below
            // console_log(outOfMontgomeryForm(t211))
            // console_log(outOfMontgomeryForm(t020)) // Same as below
            // console_log(outOfMontgomeryForm(t220))
            // console_log(outOfMontgomeryForm(t021)) // Same as below
            // console_log(outOfMontgomeryForm(t221))
            // console_log(outOfMontgomeryForm(t100)) // Same as below
            // console_log(outOfMontgomeryForm(t300))
            // console_log(outOfMontgomeryForm(t101)) // Same as below
            // console_log(outOfMontgomeryForm(t301))
            // console_log(outOfMontgomeryForm(t110)) // Same as below
            // console_log(outOfMontgomeryForm(t310))
            // console_log(outOfMontgomeryForm(t111)) // Same as below
            // console_log(outOfMontgomeryForm(t311))
            // console_log(outOfMontgomeryForm(t120)) // Same as below
            // console_log(outOfMontgomeryForm(t320))
            // console_log(outOfMontgomeryForm(t121)) // Same as below
            // console_log(outOfMontgomeryForm(t321))

            // // MUL BY INVERSE

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Inv(one,0,0,0,0,0,0,0,0,0,0,0)
            // console_log(outOfMontgomeryForm(t000)) // 1
            // console_log(outOfMontgomeryForm(t001)) // 0
            // console_log(outOfMontgomeryForm(t010)) // 0
            // console_log(outOfMontgomeryForm(t011)) // 0
            // console_log(outOfMontgomeryForm(t020)) // 0
            // console_log(outOfMontgomeryForm(t021)) // 0
            // console_log(outOfMontgomeryForm(t100)) // 0
            // console_log(outOfMontgomeryForm(t101)) // 0
            // console_log(outOfMontgomeryForm(t110)) // 0
            // console_log(outOfMontgomeryForm(t111)) // 0
            // console_log(outOfMontgomeryForm(t120)) // 0
            // console_log(outOfMontgomeryForm(t121)) // 0

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Inv(one,one,one,one,one,one,one,one,one,one,one,one)
            // t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Mul(t000,t001,t010,t011,t020,t021,t100,t101,t110,t111,t120,t121,one,one,one,one,one,one,one,one,one,one,one,one)
            // console_log(outOfMontgomeryForm(t000)) // 1
            // console_log(outOfMontgomeryForm(t001)) // 0
            // console_log(outOfMontgomeryForm(t010)) // 0
            // console_log(outOfMontgomeryForm(t011)) // 0
            // console_log(outOfMontgomeryForm(t020)) // 0
            // console_log(outOfMontgomeryForm(t021)) // 0
            // console_log(outOfMontgomeryForm(t100)) // 0
            // console_log(outOfMontgomeryForm(t101)) // 0
            // console_log(outOfMontgomeryForm(t110)) // 0
            // console_log(outOfMontgomeryForm(t111)) // 0
            // console_log(outOfMontgomeryForm(t120)) // 0
            // console_log(outOfMontgomeryForm(t121)) // 0

            // let t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Inv(two,two,two,two,two,two,two,two,two,two,two,two)
            // t000, t001, t010, t011, t020, t021, t100, t101, t110, t111, t120, t121 := fp12Mul(two,two,two,two,two,two,two,two,two,two,two,two,t000,t001,t010,t011,t020,t021,t100,t101,t110,t111,t120,t121)
            // console_log(outOfMontgomeryForm(t000)) // 1
            // console_log(outOfMontgomeryForm(t001)) // 0
            // console_log(outOfMontgomeryForm(t010)) // 0
            // console_log(outOfMontgomeryForm(t011)) // 0
            // console_log(outOfMontgomeryForm(t020)) // 0
            // console_log(outOfMontgomeryForm(t021)) // 0
            // console_log(outOfMontgomeryForm(t100)) // 0
            // console_log(outOfMontgomeryForm(t101)) // 0
            // console_log(outOfMontgomeryForm(t110)) // 0
            // console_log(outOfMontgomeryForm(t111)) // 0
            // console_log(outOfMontgomeryForm(t120)) // 0
            // console_log(outOfMontgomeryForm(t121)) // 0
        }
    }
}
