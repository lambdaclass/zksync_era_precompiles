object "EcMul" {
    code { }
    object "EcMul_deployed" {
        code {
            ////////////////////////////////////////////////////////////////
            //                      CONSTANTS
            ////////////////////////////////////////////////////////////////

            /// @notice Constant function for value one in Montgomery form.
            /// @dev This value was precomputed using Python.
            /// @return m_one The value one in Montgomery form.
            function MONTGOMERY_ONE() -> m_one {
                m_one := 6350874878119819312338956282401532409788428879151445726012394534686998597021
            }

            /// @notice Constant function for value three in Montgomery form.
            /// @dev This value was precomputed using Python.
            /// @return m_three The value three in Montgomery form.
            function MONTGOMERY_THREE() -> m_three {
                m_three := 19052624634359457937016868847204597229365286637454337178037183604060995791063
            }

            function MONTGOMERY_GLV_BASIS() -> v10, v11, v20, v21, det, b1, b2 {
                v10 := 9467151881811383727216712387251582584038710124949150773810224174953673958495
                v11 := 7832780885517429488914881362264053307162815318423880121458870703782468606792
                v20 := 17299932767328813216131593749515635891201525443373030895269094878736142565287
                v21 := 9467151881811383727216712387251582584038710124949150773810224174953673958495
                det := 17171738990013410148209280487843271955783777084671648589027996831129432963265
                b1 := 1999550452416974871140046113947404043388591104517078921953891555888361342916
                b2 := 2348897689843608674094128271148469530883240042839830706128860949317525936861
            }

            function DIV_LATTICE_DETERMINANT() -> ret {
                ret := 512
            }

            /// @notice Constant function for value 3*b (i.e. 9) in Montgomery form.
            /// @dev This value was precomputed using Python.
            /// @return m_b3 The value 9 in Montgomery form.
            function MONTGOMERY_B3() -> m_b3 {
                m_b3 := 13381388159399823366557795051099241510703237597767364208733475022892534956023
            
            function MONTGOMERY_THIRD_ROOT() -> ret {
                ret := 20006444479023397533370224967097343182639219473961804911780625968796493078869
            }

            /// @notice Constant function for the alt_bn128 field order.
            /// @dev See https://eips.ethereum.org/EIPS/eip-196 for further details.
            /// @return ret The alt_bn128 field order.
            function P() -> ret {
                ret := 21888242871839275222246405745257275088696311157297823662689037894645226208583
            }

            /// @notice Constant function for the pre-computation of R^2 % N for the Montgomery REDC algorithm.
            /// @dev R^2 is the Montgomery residue of the value 2^512.
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further detals.
            /// @dev This value was precomputed using Python.
            /// @return ret The value R^2 modulus the curve field order.
            function R2_MOD_P() -> ret {
                ret := 3096616502983703923843567936837374451735540968419076528771170197431451843209
            }

            /// @notice Constant function for the pre-computation of N' for the Montgomery REDC algorithm.
            /// @dev N' is a value such that NN' = -1 mod R, with N being the curve field order.
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further detals.
            /// @dev This value was precomputed using Python.
            /// @return ret The value N'.
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

            /// @notice Burns remaining gas until revert.
            /// @dev This function is used to burn gas in the case of a failed precompile call.
            function burnGas() {
                // Precompiles that do not have a circuit counterpart
                // will burn the provided gas by calling this function.
                precompileCall(0, gas())
            }

            /// @notice Retrieves the highest half of the multiplication result.
            /// @param multiplicand The value to multiply.
            /// @param multiplier The multiplier.
            /// @return ret The highest half of the multiplication result.
            function getHighestHalfOfMultiplication(multiplicand, multiplier) -> ret {
                ret := verbatim_2i_1o("mul_high", multiplicand, multiplier)
            }

            /// @notice Computes an addition and checks for overflow.
            /// @param augend The value to add to.
            /// @param addend The value to add.
            /// @return sum The sum of the two values.
            /// @return overflowed True if the addition overflowed, false otherwise.
            function overflowingAdd(augend, addend) -> sum, overflowed {
                sum := add(augend, addend)
                overflowed := lt(sum, augend)
            }

            /// @notice Checks if the LSB of a number is 1.
            /// @param x The number to check.
            /// @return ret True if the LSB is 1, false otherwise.
            function lsbIsOne(x) -> ret {
                ret := and(x, 1)
            }

            function binaryExtendedEuclideanAlgorithm(base) -> inv {
                let modulus := P()
                let u := base
                let v := modulus
                // Avoids unnecessary reduction step.
                let b := R2_MOD_P()
                let c := 0

                for {} and(iszero(eq(u, 1)), iszero(eq(v, 1))) {} {
                    for {} iszero(and(u, 1)) {} {
                        u := shr(1, u)
                        let current := b
                        switch and(current, 1)
                        case 0 {
                            b := shr(1, b)
                        }
                        case 1 {
                            b := shr(1, add(b, modulus))
                        }
                    }

                    for {} iszero(and(v, 1)) {} {
                        v := shr(1, v)
                        let current := c
                        switch and(current, 1)
                        case 0 {
                            c := shr(1, c)
                        }
                        case 1 {
                            c := shr(1, add(c, modulus))
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

                switch eq(u, 1)
                case 0 {
                    inv := c
                }
                case 1 {
                    inv := b
                }
            }

            /// @notice Implementation of the Montgomery reduction algorithm (a.k.a. REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithm
            /// @param lowestHalfOfT The lowest half of the value T.
            /// @param higherHalfOfT The higher half of the value T.
            /// @return S The result of the Montgomery reduction.
            function REDC(lowestHalfOfT, higherHalfOfT) -> S {
                let m := mul(lowestHalfOfT, N_PRIME())
                let hi := add(higherHalfOfT, getHighestHalfOfMultiplication(m, P()))
                let lo, overflowed := overflowingAdd(lowestHalfOfT, mul(m, P()))
                if overflowed {
                    hi := add(hi, 1)
                }
                S := hi
                if iszero(lt(hi, P())) {
                    S := sub(hi, P())
                }
            }

            /// @notice Encodes a field element into the Montgomery form using the Montgomery reduction algorithm (REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithmfor further details on transforming a field element into the Montgomery form.
            /// @param a The field element to encode.
            /// @return ret The field element in Montgomery form.
            function intoMontgomeryForm(a) -> ret {
                let hi := getHighestHalfOfMultiplication(a, R2_MOD_P())
                let lo := mul(a, R2_MOD_P())
                ret := REDC(lo, hi)
            }

            /// @notice Decodes a field element out of the Montgomery form using the Montgomery reduction algorithm (REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithm for further details on transforming a field element out of the Montgomery form.
            /// @param m The field element in Montgomery form to decode.
            /// @return ret The decoded field element.
            function outOfMontgomeryForm(m) -> ret {
                let hi := 0
                let lo := m
                ret := REDC(lo, hi)
            }

            function montgomeryAdd(augend, addend) -> ret {
                ret := addmod(augend, addend, P())
            }

            function montgomerySub(minuend, subtrahend) -> ret {
                ret := montgomeryAdd(minuend, sub(P(), subtrahend))
            }

            /// @notice Computes the Montgomery multiplication using the Montgomery reduction algorithm (REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithm for further details on the Montgomery multiplication.
            /// @param multiplicand The multiplicand in Montgomery form.
            /// @param multiplier The multiplier in Montgomery form.
            /// @return ret The result of the Montgomery multiplication.
            function montgomeryMul(multiplicand, multiplier) -> ret {
                let hi := getHighestHalfOfMultiplication(multiplicand, multiplier)
                let lo := mul(multiplicand, multiplier)
                ret := REDC(lo, hi)
            }

            /// @notice Computes the Montgomery modular inverse skipping the Montgomery reduction step.
            /// @dev The Montgomery reduction step is skept because a modification in the binary extended Euclidean algorithm is used to compute the modular inverse.
            /// @dev See the function `binaryExtendedEuclideanAlgorithm` for further details.
            /// @param a The field element in Montgomery form to compute the modular inverse of.
            /// @return invmod The result of the Montgomery modular inverse (in Montgomery form).
            function montgomeryModularInverse(a) -> invmod {
                invmod := binaryExtendedEuclideanAlgorithm(a)
            }

            /// @notice Checks if a coordinate is on the curve field order.
            /// @dev A coordinate is on the curve field order if it is on the range [0, curveFieldOrder).
            /// @param coordinate The coordinate to check.
            /// @return ret True if the coordinate is in the range, false otherwise.
            function coordinateIsOnFieldOrder(coordinate) -> ret {
                ret := lt(coordinate, P())
            }

            /// @notice Checks if affine coordinates are on the curve field order.
            /// @dev Affine coordinates are on the curve field order if both coordinates are on the range [0, curveFieldOrder).
            /// @param x The x coordinate to check.
            /// @param y The y coordinate to check.
            /// @return ret True if the coordinates are in the range, false otherwise.
            function affinePointCoordinatesAreOnFieldOrder(x, y) -> ret {
                ret := and(coordinateIsOnFieldOrder(x), coordinateIsOnFieldOrder(y))
            }

            /// @notice Checks if projective coordinates are on the curve field order.
            /// @dev Projective coordinates are on the curve field order if the coordinates are on the range [0, curveFieldOrder) and the z coordinate is not zero.
            /// @param x The x coordinate to check.
            /// @param y The y coordinate to check.
            /// @param z The z coordinate to check.
            /// @return ret True if the coordinates are in the range, false otherwise.
            function projectivePointCoordinatesAreOnFieldOrder(x, y, z) -> ret {
                let _x, _y := projectiveIntoAffine(x, y, z)
                ret := and(z, affinePointCoordinatesAreOnFieldOrder(_x, _y))
            }

            // @notice Checks if a point in affine coordinates in Montgomery form is on the curve.
            // @dev The curve in question is the alt_bn128 curve.
            // @dev The Short Weierstrass equation of the curve is y^2 = x^3 + 3.
            // @param x The x coordinate of the point in Montgomery form.
            // @param y The y coordinate of the point in Montgomery form.
            // @return ret True if the point is on the curve, false otherwise.
			function affinePointIsOnCurve(x, y) -> ret {
                let ySquared := montgomeryMul(y, y)
                let xSquared := montgomeryMul(x, x)
                let xQubed := montgomeryMul(xSquared, x)
                let xQubedPlusThree := montgomeryAdd(xQubed, MONTGOMERY_THREE())

                ret := eq(ySquared, xQubedPlusThree)
			}

            /// @notice Checks if a point in affine coordinates is the point at infinity.
            /// @dev The point at infinity is defined as the point (0, 0).
            /// @dev See https://eips.ethereum.org/EIPS/eip-196 for further details.
            /// @param x The x coordinate of the point in Montgomery form.
            /// @param y The y coordinate of the point in Montgomery form.
            /// @return ret True if the point is the point at infinity, false otherwise.
            function affinePointIsInfinity(x, y) -> ret {
                ret := and(iszero(x), iszero(y))
            }

            /// @notice Checks if a point in projective coordinates in Montgomery form is the point at infinity.
            /// @dev The point at infinity is defined as the point (0, 0, 0).
            /// @param x The x coordinate of the point in Montgomery form.
            /// @param y The y coordinate of the point in Montgomery form.
            /// @param z The z coordinate of the point in Montgomery form.
            /// @return ret True if the point is the point at infinity, false otherwise.
            function projectivePointIsInfinity(x, y, z) -> ret {
                ret := iszero(z)
            }

            /// @notice Converts a point in affine coordinates to projective coordinates in Montgomery form.
            /// @dev The point at infinity is defined as the point (0, 0, 0).
            /// @dev For performance reasons, the point is assumed to be previously checked to be on the 
            /// @dev curve and not the point at infinity.
            /// @param xp The x coordinate of the point P in affine coordinates in Montgomery form.
            /// @param yp The y coordinate of the point P in affine coordinates in Montgomery form.
            /// @return xr The x coordinate of the point P in projective coordinates in Montgomery form.
            /// @return yr The y coordinate of the point P in projective coordinates in Montgomery form.
            /// @return zr The z coordinate of the point P in projective coordinates in Montgomery form.
            function projectiveFromAffine(xp, yp) -> xr, yr, zr {
                xr := xp
                yr := yp
                zr := MONTGOMERY_ONE()
            }

            /// @notice Converts a point in projective coordinates to affine coordinates in Montgomery form.
            /// @dev See https://www.nayuki.io/page/elliptic-curve-point-addition-in-projective-coordinates for further details.
            /// @dev Reverts if the point is not on the curve.
            /// @param xp The x coordinate of the point P in projective coordinates in Montgomery form.
            /// @param yp The y coordinate of the point P in projective coordinates in Montgomery form.
            /// @param zp The z coordinate of the point P in projective coordinates in Montgomery form.
            /// @return xr The x coordinate of the point P in affine coordinates in Montgomery form.
            /// @return yr The y coordinate of the point P in affine coordinates in Montgomery form.
            function projectiveIntoAffine(xp, yp, zp) -> xr, yr {
                switch zp
                case 0 {
                    xr := 0
                    yr := 0
                }
                default {
                    let zp_inv := montgomeryModularInverse(zp)
                    xr := montgomeryMul(xp, zp_inv)
                    yr := montgomeryMul(yp, zp_inv)
                }
            }

            /// @notice Doubles a point in projective coordinates in Montgomery form.
            /// @dev See Algorithm 9 in https://eprint.iacr.org/2015/1060.pdf for further details.
            /// @dev The point is assumed to be on the curve.
            /// @dev It works correctly for the point at infinity.
            /// @param xp The x coordinate of the point P in projective coordinates in Montgomery form.
            /// @param yp The y coordinate of the point P in projective coordinates in Montgomery form.
            /// @param zp The z coordinate of the point P in projective coordinates in Montgomery form.
            /// @return xr The x coordinate of the point 2P in projective coordinates in Montgomery form.
            /// @return yr The y coordinate of the point 2P in projective coordinates in Montgomery form.
            /// @return zr The z coordinate of the point 2P in projective coordinates in Montgomery form.
            function projectiveDouble(xp, yp, zp) -> xr, yr, zr {
                let t0 := montgomeryMul(yp, yp)
                zr := montgomeryAdd(t0, t0)
                zr := montgomeryAdd(zr, zr)
                zr := montgomeryAdd(zr, zr)
                let t1 := montgomeryMul(yp, zp)
                let t2 := montgomeryMul(zp, zp)
                t2 := montgomeryMul(MONTGOMERY_B3(), t2)
                xr := montgomeryMul(t2, zr)
                yr := montgomeryAdd(t0, t2)
                zr := montgomeryMul(t1, zr)
                t1 := montgomeryAdd(t2, t2)
                t2 := montgomeryAdd(t1, t2)
                t0 := montgomerySub(t0, t2)
                yr := montgomeryMul(t0, yr)
                yr := montgomeryAdd(xr, yr)
                t1 := montgomeryMul(xp, yp)
                xr := montgomeryMul(t0, t1)
                xr := montgomeryAdd(xr, xr)
            }

            function phi(xp, yp, zp) -> xr, yr, zr {
                xr := montgomeryMul(xp, MONTGOMERY_THIRD_ROOT())
                yr := yp
                zr := zp
            }

            function splitScalar(scalar, v10, v11, v20, v21, det, b1, b2) -> v0, v1 {
                let k1 := montgomeryMul(scalar, b1)
                let k2 := montgomeryMul(scalar, b2)
                k2 := montgomerySub(0, k2)
                // n := 2 * ((l.Det.BitLen()+32)>>6)<<6)
                let n := DIV_LATTICE_DETERMINANT()
                k1 := shr(n, k1)
                k2 := shr(n, k2)
                v0, v1 := getVector(v10, v11, v20, v21, k1, k2)
                v0 := montgomerySub(scalar, v0)
                v1 := montgomerySub(0, v1)
            }

            function getVector(v10, v11, v20, v21, k1, k2) -> v0, v1 {
                let tmp := montgomeryMul(k2, v20)
                v0 := montgomeryMul(v20, k1)
                v0 := montgomeryAdd(v0, tmp)
                tmp := montgomeryMul(k2, v21)
                v1 := montgomeryMul(k1, v11)
                v1 := montgomeryAdd(v1, tmp)
            }

            function addProjective(xq, yq, zq, xp, yp, zp) -> xr, yr, zr {
                let flag := 0
                let qIsInfinity := projectivePointIsInfinity(xq, yq, zq)
                let pIsInfinity := projectivePointIsInfinity(xp, yp, zp)
                if and(and(pIsInfinity, qIsInfinity), iszero(flag)) {
                    // Infinity + Infinity = Infinity
                    xr := 0
                    yr := MONTGOMERY_ONE()
                    zr := 0
                    flag := 1
                }
                if and(and(pIsInfinity, iszero(qIsInfinity)), iszero(flag)) {
                    // Infinity + P = P
                    xr := xq
                    yr := yq
                    zr := zq
                    flag := 1
                }
                if and(and(iszero(pIsInfinity), qIsInfinity), iszero(flag)) {
                    // P + Infinity = P
                    xr := xp
                    yr := yp
                    zr := zp
                    flag := 1
                }
                if and(and(and(eq(xp, xq), eq(montgomerySub(0, yp), yq)), eq(zp, zq)), iszero(flag)) {
                    // P + (-P) = Infinity
                    xr := 0
                    yr := 0
                    zr := 0
                    flag := 1
                }
                if and(and(and(eq(xp, xq), eq(yp, yq)), eq(zp, zq)), iszero(flag)) {
                    // P + P = 2P
                    xr, yr, zr := projectiveDouble(xp, yp, zp)
                    flag := 1
                }

                // P1 + P2 = P3
                if iszero(flag) {
                    let t0 := montgomeryMul(yq, zp)
                    let t1 := montgomeryMul(zp, zq)
                    let t := montgomerySub(t0, t1)
                    let u0 := montgomeryMul(xq, zp)
                    let u1 := montgomeryMul(xp, zq)
                    let u := montgomerySub(u0, u1)
                    let u2 := montgomeryMul(u, u)
                    let u3 := montgomeryMul(u2, u)
                    let v := montgomeryMul(zq, zp)
                    let w := montgomerySub(montgomeryMul(montgomeryMul(t, t), v), montgomeryMul(u2, montgomeryAdd(u0, u1)))
    
                    xr := montgomeryMul(u, w)
                    yr := montgomerySub(montgomeryMul(t, montgomerySub(montgomeryMul(u0, u2), w)), montgomeryMul(t0, u3))
                    zr := montgomeryMul(u3, v)
                }
            }

            

            ////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////

            // Retrieve the coordinates from the calldata
            let x := calldataload(0)
            let y := calldataload(32)
            if iszero(affinePointCoordinatesAreOnFieldOrder(x, y)) {
                burnGas()
            }
            let scalar := calldataload(64)

            if affinePointIsInfinity(x, y) {
                // Infinity * scalar = Infinity
                return(0x00, 0x40)
            }

            let m_x := intoMontgomeryForm(x)
            let m_y := intoMontgomeryForm(y)

            // Ensure that the point is in the curve (Y^2 = X^3 + 3).
            if iszero(affinePointIsOnCurve(m_x, m_y)) {
                burnGas()
            }

            if eq(scalar, 0) {
                // P * 0 = Infinity
                return(0x00, 0x40)
            }
            if eq(scalar, 1) {
                // P * 1 = P
                mstore(0x00, x)
                mstore(0x20, y)
                return(0x00, 0x40)
            }

            let xp, yp, zp := projectiveFromAffine(m_x, m_y)

            if eq(scalar, 2) {
                let xr, yr, zr := projectiveDouble(xp, yp, zp)
                
                xr, yr := projectiveIntoAffine(xr, yr, zr)
                xr := outOfMontgomeryForm(xr)
                yr := outOfMontgomeryForm(yr)

                mstore(0x00, xr)
                mstore(0x20, yr)
                return(0x00, 0x40)
            }

            let xr := 0
            let yr := MONTGOMERY_ONE()
            let zr := 0

            let t00 := xp
            let t01 := yp 
            let t02 := zp
            let t30, t31, t32 := phi(xp, yp, zp) 

            let v10, v11, v20, v21, det, b1, b2 := MONTGOMERY_GLV_BASIS()
            let k0, k1 := splitScalar(scalar, v10, v11, v20, v21, det, b1, b2)

            // TODO: check sign of k0 and k1?

            let t10, t11, t12 := projectiveDouble(t00, t01, t02)
            let t20, t21, t22 := addProjective(t10, t11, t12, t00, t00, t00)
            let t40, t41, t42 := addProjective(t30, t31, t32, t00, t00, t00)
            let t50, t51, t52 := addProjective(t30, t31, t32, t10, t11, t12)
            let t60, t61, t62 := addProjective(t20, t21, t22, t30, t31, t32)
            let t70, t71, t72 := projectiveDouble(t30, t31, t32)
            let t80, t81, t82 := addProjective(t70, t71, t72, t00, t01, t02)
            let t90, t91, t92 := addProjective(t70, t71, t72, t10, t11, t12)
            let t100, t101, t102 := addProjective(t70, t71, t72, t20, t21, t22)
            let t110, t111, t112 := addProjective(t70, t71, t72, t30, t31, t32)
            let t120, t121, t122 := addProjective(t110, t111, t112, t00, t01, t02)
            let t130, t131, t132 := addProjective(t110, t111, t112, t10, t11, t12)
            let t140, t141, t142 := addProjective(t110, t111, t112, t20, t21, t22)

            mstore(0, xr)
            mstore(32, yr)
            return(0, 64)
        }
    }
}
}
