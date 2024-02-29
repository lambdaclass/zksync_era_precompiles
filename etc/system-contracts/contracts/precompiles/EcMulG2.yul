object "EcMulG2" {
    code { }
    object "EcMulG2_deployed" {
        code {
            // CONSTANTS

            /// @notice Constant function for value one in Montgomery form.
            /// @dev This value was precomputed using Python.
            /// @return m_one The value one in Montgomery form.
            function MONTGOMERY_ONE() -> m_one {
                m_one := 6350874878119819312338956282401532409788428879151445726012394534686998597021
            }

            /// @notice Constant function for the pre-computation of R^2 % N for the Montgomery REDC algorithm.
            /// @dev R^2 is the Montgomery residue of the value 2^512.
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further detals.
            /// @dev This value was precomputed using Python.
            /// @return ret The value R^2 modulus the curve group order.
            function R2_MOD_P() -> ret {
                ret := 3096616502983703923843567936837374451735540968419076528771170197431451843209
            }

            /// @notice Constant function for the alt_bn128 group order.
            /// @dev See https://eips.ethereum.org/EIPS/eip-196 for further details.
            /// @return ret The alt_bn128 group order.
            function P() -> ret {
                ret := 21888242871839275222246405745257275088696311157297823662689037894645226208583
            }

            /// @notice Constant function for the pre-computation of N' for the Montgomery REDC algorithm.
            /// @dev N' is a value such that NN' = -1 mod R, with N being the curve group order.
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further detals.
            /// @dev This value was precomputed using Python.
            /// @return ret The value N'.
            function N_PRIME() -> ret {
                ret := 111032442853175714102588374283752698368366046808579839647964533820976443843465
            }

            /// @notice constant function for the coeffitients of the sextic twist of the BN256 curve.
            /// @dev E': y' ** 2 = x' ** 3 + 3 / (3 + u)
            /// @dev the curve E' is defined over Fp2 elements.
            /// @dev See https://hackmd.io/@jpw/bn254#Twists for further details.
            /// @return coefficients of the sextic twist of the BN256 curve
            function MONTGOMERY_TWISTED_CURVE_COEFFS() -> z0, z1 {
                z0 := 16772280239760917788496391897731603718812008455956943122563801666366297604776
                z1 := 568440292453150825972223760836185707764922522371208948902804025364325400423
            }

            // HELPER FUNCTIONS

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

            /// @notice Calculate the bit length of a number.
            /// @param x The number to calculate the bit length of.
            /// @return ret The bit length of the number.
            function bitLen(x) -> ret {
                ret := 0
                for {} x {} {
                    ret := add(ret, 1)
                    x := shr(1, x)
                }
            }

            /// @notice Checks if the bit of a number at a given index is 1.
            /// @dev The index is counted from the right, starting at 0.
            /// @param index The index of the bit to check.
            /// @param n The number to check the bit of.
            /// @return ret The value of the bit at the given index.
            function checkBit(index, n) -> ret {
                ret := and(shr(index, n), 1)
            }

           // MONTGOMERY

            /// @notice Computes the inverse in Montgomery Form of a number in Montgomery Form.
            /// @dev Reference: https://github.com/lambdaclass/lambdaworks/blob/main/math/src/field/fields/montgomery_backed_prime_fields.rs#L169
            /// @dev Let `base` be a number in Montgomery Form, then base = a*R mod P() being `a` the base number (not in Montgomery Form)
            /// @dev Let `inv` be the inverse of a number `a` in Montgomery Form, then inv = a^(-1)*R mod P()
            /// @dev The original binary extended euclidean algorithms takes a number a and returns a^(-1) mod N
            /// @dev In our case N is P(), and we'd like the input and output to be in Montgomery Form (a*R mod P() 
            /// @dev and a^(-1)*R mod P() respectively).
            /// @dev If we just pass the input as a number in Montgomery Form the result would be a^(-1)*R^(-1) mod P(),
            /// @dev but we want it to be a^(-1)*R mod P().
            /// @dev For that, we take advantage of the algorithm's linearity and multiply the result by R^2 mod P()
            /// @dev to get R^2*a^(-1)*R^(-1) mod P() = a^(-1)*R mod P() as the desired result in Montgomery Form.
            /// @dev `inv` takes the value of `b` or `c` being the result sometimes `b` and sometimes `c`. In paper
            /// @dev multiplying `b` or `c` by R^2 mod P() results on starting their values as b = R2_MOD_P() and c = 0.
            /// @param base A number `a` in Montgomery Form, then base = a*R mod P().
            /// @return inv The inverse of a number `a` in Montgomery Form, then inv = a^(-1)*R mod P().
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

            /// @notice Computes an addition and checks for overflow.
            /// @param augend The value to add to.
            /// @param addend The value to add.
            /// @return sum The sum of the two values.
            /// @return overflowed True if the addition overflowed, false otherwise.
            function overflowingAdd(augend, addend) -> sum, overflowed {
                sum := add(augend, addend)
                overflowed := lt(sum, augend)
            }

            /// @notice Retrieves the highest half of the multiplication result.
            /// @param multiplicand The value to multiply.
            /// @param multiplier The multiplier.
            /// @return ret The highest half of the multiplication result.
            function getHighestHalfOfMultiplication(multiplicand, multiplier) -> ret {
                ret := verbatim_2i_1o("mul_high", multiplicand, multiplier)
            }

            /// @notice Implementation of the Montgomery reduction algorithm (a.k.a. REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm
            /// @param lowestHalfOfT The lowest half of the value T.
            /// @param higherHalfOfT The higher half of the value T.
            /// @return S The result of the Montgomery reduction.
            function REDC(lowest_half_of_T, higher_half_of_T) -> S {
                let q := mul(lowest_half_of_T, N_PRIME())
                let a_high := add(higher_half_of_T, getHighestHalfOfMultiplication(q, P()))
                let a_low, overflowed := overflowingAdd(lowest_half_of_T, mul(q, P()))
                if overflowed {
                    a_high := add(a_high, 1)
                }
                S := a_high
                if iszero(lt(a_high, P())) {
                    S := sub(a_high, P())
                }
            }

            /// @notice Encodes a field element into the Montgomery form using the Montgomery reduction algorithm (REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further details on transforming a field element into the Montgomery form.
            /// @param a The field element to encode.
            /// @return ret The field element in Montgomery form.
            function intoMontgomeryForm(a) -> ret {
                let hi := getHighestHalfOfMultiplication(a, R2_MOD_P())
                let lo := mul(a, R2_MOD_P())
                ret := REDC(lo, hi)
            }

            /// @notice Decodes a field element out of the Montgomery form using the Montgomery reduction algorithm (REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further details on transforming a field element out of the Montgomery form.
            /// @param m The field element in Montgomery form to decode.
            /// @return ret The decoded field element.
            function outOfMontgomeryForm(m) -> ret {
                    let higher_half_of_m := 0
                    let lowest_half_of_m := m 
                    ret := REDC(lowest_half_of_m, higher_half_of_m)
            }

            /// @notice Computes the Montgomery addition.
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further details on the Montgomery multiplication.
            /// @param augend The augend in Montgomery form.
            /// @param addend The addend in Montgomery form.
            /// @return ret The result of the Montgomery addition.
            function montgomeryAdd(augend, addend) -> ret {
                ret := add(augend, addend)
                if iszero(lt(ret, P())) {
                    ret := sub(ret, P())
                }
            }

            /// @notice Computes the Montgomery subtraction.
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further details on the Montgomery multiplication.
            /// @param minuend The minuend in Montgomery form.
            /// @param subtrahend The subtrahend in Montgomery form.
            /// @return ret The result of the Montgomery addition.
            function montgomerySub(minuend, subtrahend) -> ret {
                ret := montgomeryAdd(minuend, sub(P(), subtrahend))
            }

            /// @notice Computes the Montgomery multiplication using the Montgomery reduction algorithm (REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further details on the Montgomery multiplication.
            /// @param multiplicand The multiplicand in Montgomery form.
            /// @param multiplier The multiplier in Montgomery form.
            /// @return ret The result of the Montgomery multiplication.
            function montgomeryMul(multiplicand, multiplier) -> ret {
                let higher_half_of_product := getHighestHalfOfMultiplication(multiplicand, multiplier)
                let lowest_half_of_product := mul(multiplicand, multiplier)
                ret := REDC(lowest_half_of_product, higher_half_of_product)
            }

            /// @notice Computes the Montgomery modular inverse skipping the Montgomery reduction step.
            /// @dev The Montgomery reduction step is skept because a modification in the binary extended Euclidean algorithm is used to compute the modular inverse.
            /// @dev See the function `binaryExtendedEuclideanAlgorithm` for further details.
            /// @param a The field element in Montgomery form to compute the modular inverse of.
            /// @return invmod The result of the Montgomery modular inverse (in Montgomery form).
            function montgomeryModularInverse(a) -> invmod {
                invmod := binaryExtendedEuclideanAlgorithm(a)
            }

            // G2 ARITHMETICS

            /// @notice Checks if a coordinate is on the curve group order.
            /// @dev A coordinate is on the curve group order if it is on the range [0, curveFieldOrder).
            /// @param coordinate The coordinate to check.
            /// @return ret True if the coordinate is in the range, false otherwise.
            function g2CoordinateIsOnFieldOrder(x0, x1) -> ret {
                ret := and(lt(x0, P()), lt(x1, P()))
            }

            /// @notice Checks if a G2 point in affine coordinates is the point at infinity.
            /// @dev The coordinates are encoded in Montgomery form.
            /// @dev in Affine coordinates the point represents the infinity if both coordinates are 0.
            /// @param x0, x1 The x coordinate to check.
            /// @param y0, y1 The y coordinate to check.
            /// @return ret True if the point is the point at infinity, false otherwise.
            function g2AffinePointIsInfinity(x0, x1, y0, y1) -> ret {
                ret := iszero(or(or(x0, x1), or(y0, y1)))
            }

            /// @notice Checks if a G2 point in affine coordinates belongs to the twisted curve.
            /// @dev The coordinates are encoded in Montgomery form.
            /// @dev in Affine coordinates the point belongs to the curve if it satisfies the equation: y^3 = x^2 + 3/(9+u).
            /// @dev See https://hackmd.io/@jpw/bn254#Twists for further details.
            /// @param x0, x1 The x coordinate to check.
            /// @param y0, y1 The y coordinate to check.
            /// @return ret True if the point is in the curve, false otherwise.
            function g2AffinePointIsOnCurve(x0, x1, y0, y1) -> ret {
                let a0, a1 := MONTGOMERY_TWISTED_CURVE_COEFFS()
                let b0, b1 := fp2Mul(x0, x1, x0, x1)
                b0, b1 := fp2Mul(b0, b1, x0, x1)
                b0, b1 := fp2Add(b0, b1, a0, a1)
                let c0, c1 := fp2Mul(y0, y1, y0, y1)
                ret := and(eq(b0, c0), eq(b1, c1))
			}

            /// @notice Add two g2 points represented in jacobian coordinates.
            /// @dev The coordinates must be encoded in Montgomery form.
            /// @param a_x0, a_x1 The x coordinate of the first point.
            /// @param a_y0, a_y1 The y coordinate of the first point.
            /// @param a_z0, a_z1 The z coordinate of the first point.
            /// @param b_x0, b_x1 The x coordinate of the second point.
            /// @param b_y0, b_y1 The y coordinate of the second point.
            /// @param b_z0, b_z1 The z coordinate of the second point.
            /// @return c00, c01, c10, c11, c20, c21 The coordinates of the added points.
            function g2JacobianAdd(xq0, xq1, yq0, yq1, zq0, zq1, xr0, xr1, yr0, yr1, zr0, zr1) -> c00, c01, c10, c11, c20, c21 {
                // Check for infinity in projective coordinates is the same as jacobian
                let qIsInfinity := g2ProjectivePointIsInfinity(xq0, xq1, yq0, yq1, zq0, zq1)
                let rIsInfinity := g2ProjectivePointIsInfinity(xr0, xr1, yr0, yr1, zr0, zr1)
                if and(rIsInfinity, qIsInfinity) {
                    // Infinity + Infinity = Infinity
                    leave
                }
                if rIsInfinity {
                    // Infinity + P = P
                    c00 := xq0
                    c01 := xq1
                    c10 := yq0
                    c11 := yq1
                    c20 := zq0
                    c21 := zq1
                    leave
                }
                if qIsInfinity {
                    // P + Infinity = P
                    c00 := xr0
                    c01 := xr1
                    c10 := yr0
                    c11 := yr1
                    c20 := zr0
                    c21 := zr1
                    leave
                }

                // Z1Z1 = Z1^2
                let zqzq0, zqzq1 := fp2Mul(zq0, zq1, zq0, zq1)
                // Z2Z2 = Z2^2
                let zrzr0, zrzr1 := fp2Mul(zr0, zr1, zr0, zr1)
                // U1 = X1*Z2Z2
                let u0, u1 := fp2Mul(xq0, xq1, zrzr0, zrzr1)
                // U2 = X2*Z1Z1
                let u2, u3 := fp2Mul(xr0, xr1, zqzq0, zqzq1)
                // t0 = Z2*Z2Z2
                let t0, t1 := fp2Mul(zr0, zr1, zrzr0, zrzr1)
                // S1 = Y1*t0
                let s0, s1 := fp2Mul(yq0, yq1, t0, t1)
                // t1 = Z1*Z1Z1
                let t2, t3 := fp2Mul(zq0, zq1, zqzq0, zqzq1)
                // S2 = Y2*t1
                let s2, s3 := fp2Mul(yr0, yr1, t2, t3)
                // H = U2-U1
                let h0, h1 := fp2Sub(u2, u3, u0, u1)
                // t2 = 2*H
                let t4, t5 := fp2Add(h0, h1, h0, h1)
                // I = t2^2
                let i0, i1 := fp2Mul(t4, t5, t4, t5)
                // J = H*I
                let j0, j1 := fp2Mul(h0, h1, i0, i1)
                // t3 = S2-S1
                let t6, t7 := fp2Sub(s2, s3, s0, s1)
                // r = 2*t3
                let r0, r1 := fp2Add(t6, t7, t6, t7)
                // V = U1*I
                let v0, v1 := fp2Mul(u0, u1, i0, i1)
                // t4 = r^2
                let t8, t9 := fp2Mul(r0, r1, r0, r1)
                // t5 = 2*V
                let t10, t11 := fp2Add(v0, v1, v0, v1)
                // t6 = t4-J
                let t12, t13 := fp2Sub(t8, t9, j0, j1)
                // X3 = t6-t5
                c00, c01 := fp2Sub(t12, t13, t10, t11)
                // t7 = V-X3
                let t14, t15 := fp2Sub(v0, v1, c00, c01)
                // t8 = S1*J
                let t16, t17 := fp2Mul(s0, s1, j0, j1)
                // t9 = 2*t8
                let t18, t19 := fp2Add(t16, t17, t16, t17)
                // t10 = r*t7
                let t20, t21 := fp2Mul(r0, r1, t14, t15)
                // Y3 = t10-t9
                c10, c11 := fp2Sub(t20, t21, t18, t19)
                // t11 = Z1+Z2
                let t22, t23 := fp2Add(zq0, zq1, zr0, zr1)
                // t12 = t11^2
                let t24, t25 := fp2Mul(t22, t23, t22, t23)
                // t13 = t12-Z1Z1
                let t26, t27 := fp2Sub(t24, t25, zqzq0, zqzq1)
                // t14 = t13-Z2Z2
                let t28, t29 := fp2Sub(t26, t27, zrzr0, zrzr1)
                // Z3 = t14*H
                c20, c21 := fp2Mul(t28, t29, h0, h1)
            }

            /// @notice Double a g2 point represented in jacobian coordinates.
            /// @dev The coordinates must be encoded in Montgomery form.
            /// @param a_x0, a_x1 The x coordinate of the point.
            /// @param a_y0, a_y1 The y coordinate of the point.
            /// @param a_z0, a_z1 The z coordinate of the point.
            /// @return c00, c01, c10, c11, c20, c21 The coordinates of the doubled point.
            function g2JacobianDouble(xp0, xp1, yp0, yp1, zp0, zp1) -> xr0, xr1, yr0, yr1, zr0, zr1 {
                let a00, a01 := fp2Mul(xp0, xp1, xp0, xp1)
                let b00, b01 := fp2Mul(yp0, yp1, yp0, yp1)
                let c00, c01 := fp2Mul(b00, b01, b00, b01)
                let t00, t01 := fp2Add(xp0, xp1, b00, b01)
                let t10, t11 := fp2Mul(t00, t01, t00, t01)
                let t20, t21 := fp2Sub(t10, t11, a00, a01)
                let t30, t31 := fp2Sub(t20, t21, c00, c01)
                let d00, d01 := fp2Add(t30, t31, t30, t31)
                let e00, e01 := fp2Add(a00, a01, a00, a01)
                e00, e01 := fp2Add(e00, e01, a00, a01)
                let f00, f01 := fp2Mul(e00, e01, e00, e01)
                let t40, t41 := fp2Add(d00, d01, d00, d01)
                xr0, xr1 := fp2Sub(f00, f01, t40, t41)
                let t50, t51 := fp2Sub(d00, d01, xr0, xr1)
                let t60, t61 := fp2Add(c00, c01, c00, c01)
                t60, t61 := fp2Add(t60, t61, t60, t61)
                t60, t61 := fp2Add(t60, t61, t60, t61)
                let t70, t71 := fp2Mul(e00, e01, t50, t51)
                yr0, yr1 := fp2Sub(t70, t71, t60, t61)
                let t80, t81 := fp2Mul(yp0, yp1, zp0, zp1)
                zr0, zr1 := fp2Add(t80, t81, t80, t81)
            }


            /// @notice Computes the affine coordinates from Jacobian.
            /// @param x0, x1 The coefficients of the x coordinate.
            /// @param y0, y1 The coefficients of the y coordinate.
            /// @param z0, z1 The coefficients of the z coordinate.
            /// @return c00, c01, c10, c11 The coefficients of the point in affine coordinates.
            function g2OutOfJacobian(x0, x1, y0, y1, z0, z1) -> c00, c01, c10, c11 {
                let z0Square, z1Square := fp2Mul(z0, z1, z0, z1)
                let z0Cube, z1Cube := fp2Mul(z0Square, z1Square, z0, z1)
                let t0, t1 := fp2Inv(z0Square, z1Square)
                let t2, t3 := fp2Inv(z0Cube, z1Cube)
                c00, c01 := fp2Mul(x0, x1, t0, t1)
                c10, c11 := fp2Mul(y0, y1, t2, t3)
            }

            /// @notice Checks if a G2 point in projective coordinates is the point at infinity.
            /// @dev The coordinates are encoded in Montgomery form.
            /// @dev A projective point is at infinity if the z coordinate is (0, 0).
            /// @param x0, x1 The x coordinate of the point.
            /// @param y0, y1 The y coordinate of the point.
            /// @param z0, z1 The z coordinate of the point.
            /// @return ret True if the point is the point at infinity, false otherwise.
            function g2ProjectivePointIsInfinity(x0, x1, y0, y1, z0, z1) -> ret {
                ret := iszero(or(z0, z1))
            }

            // FP2 ARITHMETHICS

            /// @notice Computes the sum of two Fp2 elements.
            /// @dev Algorithm 5 in: https://eprint.iacr.org/2010/354.pdf.
            /// @param a00, a01 The coefficients of the A element to sum.
            /// @param b00, b01 The coefficients of the B element to sum.
            /// @return c00, c01 The coefficients of the element C = A + B.
            function fp2Add(a00, a01, b00, b01) -> c00, c01 {
                c00 := montgomeryAdd(a00, b00)
                c01 := montgomeryAdd(a01, b01)
            }

            /// @notice Computes the subtraction of two Fp2 elements.
            /// @dev Algorithm 6 in: https://eprint.iacr.org/2010/354.pdf.
            /// @param a00, a01 The coefficients of the minuend A.
            /// @param b00, b01 The coefficients of the subtrahend B.
            /// @return c00, c01 The coefficients of the element C = A - B.
            function fp2Sub(a00, a01, b00, b01) -> c00, c01 {
                c00 := montgomerySub(a00, b00)
                c01 := montgomerySub(a01, b01)
            }

            /// @notice Computes the multiplication between a Fp2 element a Fp element.
            /// @dev Algorithm 7 in: https://eprint.iacr.org/2010/354.pdf.
            /// @param a00, a01 The coefficients of the Fp2 element A.
            /// @param scalar The value of the Fp element k.
            /// @return c00, c01 The coefficients of the element C = k * A.
            function fp2ScalarMul(a00, a01, scalar) -> c00, c01 {
                c00 := montgomeryMul(a00, scalar)
                c01 := montgomeryMul(a01, scalar)
            }

            /// @notice Computes the multiplication between two Fp2 elements.
            /// @dev Algorithm 7 in: https://eprint.iacr.org/2010/354.pdf.
            /// @param a00, a01 The coefficients of the Fp2 element A.
            /// @param a00, a01 The coefficients of the Fp2 element B.
            /// @return c00, c01 The coefficients of the element C = A * B.
            function fp2Mul(a00, a01, b00, b01) -> c00, c01 {
                c00 := montgomerySub(montgomeryMul(a00, b00), montgomeryMul(a01, b01))
                c01 := montgomeryAdd(montgomeryMul(a00, b01), montgomeryMul(a01, b00))
            }

            /// @notice Computes the negative of a Fp2 elements.
            /// @param a00, a01 The coefficients of the Fp2 element A.
            /// @return c00, c01 The coefficients of the element C = -A.
            function fp2Neg(a00, a01) -> c00, c01 {
                c00, c01 := fp2Sub(0, 0, a00, a01)
            }

            /// @notice Computes the inverse of a Fp2 element.
            /// @dev Algorithm 8 in: https://eprint.iacr.org/2010/354.pdf.
            /// @param a00, a01 The coefficients of the Fp2 element A.
            /// @return c00, c01 The coefficients of the element C = A^(-1).
            function fp2Inv(a00, a01) -> c00, c01 {
                let t0 := montgomeryMul(a00, a00)
                let t1 := montgomeryMul(a01, a01)
                t0 := montgomeryAdd(t0, t1)
                t1 := montgomeryModularInverse(t0)
                c00 := montgomeryMul(a00, t1)
                c01 := montgomerySub(0, montgomeryMul(a01, t1))
            }

            // FALLBACK

            // Retrieve the coordinates from the calldata
            let aX0 := calldataload(0)
            let aX1 := calldataload(32)
            let aY0 := calldataload(64)
            let aY1 := calldataload(96)

            if iszero(and(g2CoordinateIsOnFieldOrder(aX0, aX1), g2CoordinateIsOnFieldOrder(aY0, aY1))) {
                burnGas()
            }

            if g2AffinePointIsInfinity(aX0, aX1, aY0, aY1) {
                // Infinity * scalar = Infinity
                mstore(0, 0)
                mstore(32, 0)
                mstore(64, 0)
                mstore(96, 0)
                return(0, 128)
            }

            let aX0Mont := intoMontgomeryForm(aX0)
            let aX1Mont := intoMontgomeryForm(aX1)
            let aY0Mont := intoMontgomeryForm(aY0)
            let aY1Mont := intoMontgomeryForm(aY1)

            // Ensure that the point is in the curve.
            if iszero(g2AffinePointIsOnCurve(aX0Mont, aX1Mont, aY0Mont, aY1Mont)) {
                burnGas()
            }

            // Retrieve scalar from the calldata
            let scalar := calldataload(128)

            if eq(scalar, 0) {
                // P * 0 = Infinity
                mstore(0, 0)
                mstore(32, 0)
                mstore(64, 0)
                mstore(96, 0)
                return(0, 128)
            }
            if eq(scalar, 1) {
                // P * 1 = P
                mstore(0, aX0)
                mstore(32, aX1)
                mstore(64, aY0)
                mstore(96, aY1)
                return(0, 128)
            }

            if eq(scalar, 2) {
                let c00, c01, c10, c11, c20, c21 := g2JacobianDouble(aX0Mont, aX1Mont, aY0Mont, aY1Mont, MONTGOMERY_ONE(), 0)

                c00, c01, c10, c11 := g2OutOfJacobian(c00, c01, c10, c11, c20, c21)

                c00 := outOfMontgomeryForm(c00)
                c01 := outOfMontgomeryForm(c01)
                c10 := outOfMontgomeryForm(c10)
                c11 := outOfMontgomeryForm(c11)

                mstore(0, c00)
                mstore(32, c01)
                mstore(64, c10)
                mstore(96, c11)
                return(0, 128)
            }

            let scalarBitIndex := bitLen(scalar)
            
            let c00 := 0
            let c01 := 0
            let c10 := MONTGOMERY_ONE()
            let c11 := 0
            let c20 := 0
            let c21 := 0

            for {} scalarBitIndex {} {
                scalarBitIndex := sub(scalarBitIndex, 1)
                c00, c01, c10, c11, c20, c21 := g2JacobianDouble(c00, c01, c10, c11, c20, c21)
                let bitindex := checkBit(scalarBitIndex, scalar)
                if bitindex {
                    c00, c01, c10, c11, c20, c21 := g2JacobianAdd(aX0Mont, aX1Mont, aY0Mont, aY1Mont, MONTGOMERY_ONE(), 0, c00, c01, c10, c11, c20, c21)
                }
            }

            c00, c01, c10, c11 := g2OutOfJacobian(c00, c01, c10, c11, c20, c21)

            c00 := outOfMontgomeryForm(c00)
            c01 := outOfMontgomeryForm(c01)
            c10 := outOfMontgomeryForm(c10)
            c11 := outOfMontgomeryForm(c11)

            
            mstore(0, c00)
            mstore(32, c01)
            mstore(64, c10)
            mstore(96, c11)
            return(0, 128)
        }
    }
}
