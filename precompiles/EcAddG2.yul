object "EcAddG2" {
    code { }
    object "EcAddG2_deployed" {
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

            function console_log(val) -> {
                let log_address := 0x000000000000000000636F6e736F6c652e6c6f67
                // A big memory address to store the function selector.
                let freeMemPointer := 0x600
                // store the function selector of log(uint256) in memory
                mstore(freeMemPointer, 0xf82c50f1) // mem[0] = 0xf8...
                // store the first argument of log(uint256) in the next memory slot
                mstore(add(freeMemPointer, 0x20), val)
                // call the console.log contract
                if iszero(staticcall(gas(),log_address,add(freeMemPointer, 28),add(freeMemPointer, 0x40),0x00,0x00)) {
                    revert(0,0)
                }
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
            function g2JacobianAdd(a_x0, a_x1, a_y0, a_y1, a_z0, a_z1, b_x0, b_x1, b_y0, b_y1, b_z0, b_z1) -> c00, c01, c10, c11, c20, c21 {
                let aux0, aux1 := fp2Mul(a_z0, a_z1, a_z0, a_z1)
                let aux2, aux3 := fp2Mul(b_z0, b_z1, b_z0, b_z1)
                let u0, u1 := fp2Mul(a_x0, a_x1, aux2, aux3)
                let u2, u3 := fp2Mul(b_x0, b_x1, aux0, aux1)
                let t0, t1 := fp2Mul(b_z0, b_z1, aux2, aux3)
                let s0, s1 := fp2Mul(a_y0, a_y1, t0, t1)
                let t2, t3 := fp2Mul(a_z0, a_z1, aux0, aux1)
                let s2, s3 := fp2Mul(b_y0, b_y1, t2, t3)
                let h0, h1 := fp2Sub(u2, u3, u0, u1)
                let t4, t5 := fp2Add(h0, h1, h0, h1)
                let i0, i1 := fp2Mul(t4, t5, t4, t5)
                let j0, j1 := fp2Mul(h0, h1, i0, i1)
                let t6, t7 := fp2Sub(s2, s3, s0, s1)
                let r0, r1 := fp2Add(t6, t7, t6, t7)
                let v0, v1 := fp2Mul(u0, u1, i0, i1)
                let t8, t9 := fp2Mul(r0, r1, r0, r1)
                let t10, t11 := fp2Add(v0, v1, v0, v1)
                let t12, t13 := fp2Sub(t8, t9, j0, j1)
                c00, c01 := fp2Sub(t12, t13, t10, t11)
                let t14, t15 := fp2Sub(v0, v1, c00, c01)
                let t16, t17 := fp2Mul(s0, s1, j0, j1)
                let t18, t19 := fp2Add(t16, t17, t16, t17)
                let t20, t21 := fp2Mul(r0, r1, t14, t15)
                c10, c11 := fp2Sub(t20, t21, t18, t19)
                let t22, t23 := fp2Add(a_z0, a_z1, b_z0, b_z1)
                let t24, t25 := fp2Mul(t22, t23, t22, t23)
                let t26, t27 := fp2Sub(t24, t25, aux0, aux1)
                let t28, t29 := fp2Sub(t26, t27, aux2, aux3)
                c20, c21 := fp2Mul(t28, t29, h0, h1)
            }

            /// @notice Double a g2 point represented in jacobian coordinates.
            /// @dev The coordinates must be encoded in Montgomery form.
            /// @param a_x0, a_x1 The x coordinate of the point.
            /// @param a_y0, a_y1 The y coordinate of the point.
            /// @param a_z0, a_z1 The z coordinate of the point.
            /// @return c00, c01, c10, c11, c20, c21 The coordinates of the doubled point.
            function g2JacobianDouble(a_x0, a_x1, a_y0, a_y1, a_z0, a_z1) -> c00, c01, c10, c11, c20, c21 {
                let a00, a01 := fp2Mul(a_x0, a_x1, a_x0, a_x1)
                let b00, b01 := fp2Mul(a_y0, a_y1, a_y0, a_y1)
                let c00, c01 := fp2Mul(b00, b01, b00, b01)
                let t00, t01 := fp2Add(a_x0, a_x1, b00, b01)
                let t10, t11 := fp2Mul(t00, t01, t00, t01)
                let t20, t21 := fp2Sub(t10, t11, a00, a01)
                let t30, t31 := fp2Sub(t20, t21, c00, c01)
                let d00, d01 := fp2Add(t30, t31, t30, t31)
                let e00, e01 := fp2Add(a00, a01, a00, a01)
                e00, e01 := fp2Add(e00, e01, a00, a01)
                let f00, f01 := fp2Mul(e00, e01, e00, e01)
                let t40, t41 := fp2Add(d00, d01, d00, d01)
                c00, c01 := fp2Sub(f00, f01, t40, t41)
                let t50, t51 := fp2Sub(d00, d01, c00, c01)
                let t60, t61 := fp2Add(c00, c01, c00, c01)
                t60, t61 := fp2Add(t60, t61, t60, t61)
                t60, t61 := fp2Add(t60, t61, t60, t61)
                let t70, t71 := fp2Mul(e00, e01, t50, t51)
                c10, c11 := fp2Sub(t70, t71, t60, t61)
                let t80, t81 := fp2Mul(a_y0, a_y1, a_z0, a_z1)
                c20, c21 := fp2Add(t80, t81, t80, t81)
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
            let a_x0 := calldataload(0)
            let a_x1 := calldataload(32)
            let a_y0 := calldataload(64)
            let a_y1 := calldataload(96)

            let b_x0 := calldataload(128)
            let b_x1 := calldataload(160)
            let b_y0 := calldataload(192)
            let b_y1 := calldataload(224)

            // Check if points are infinite
            let aIsInfinity := g2AffinePointIsInfinity(a_x0, a_x1, a_y0, a_y1)
            let bIsInfinity := g2AffinePointIsInfinity(b_x0, b_x1, b_y0, b_y1)

            if and(aIsInfinity, bIsInfinity) {
                // Infinity + Infinity = Infinity
                mstore(0, 0)
                mstore(32, 0)
                mstore(64, 0)
                mstore(96, 0)
                return(0, 128)
            }

            if aIsInfinity {
                // Infinity + B = B

                // Ensure that the coordinates are between 0 and the field order
                if iszero(and(g2CoordinateIsOnFieldOrder(b_x0, b_x1), g2CoordinateIsOnFieldOrder(b_y0, b_y1))) {
                    burnGas()
                }

                let b_x0_mont := intoMontgomeryForm(b_x0)
                let b_x1_mont := intoMontgomeryForm(b_x1)
                let b_y0_mont := intoMontgomeryForm(b_y0)
                let b_y1_mont := intoMontgomeryForm(b_y1)

                // Ensure that the point is in the curve
                if iszero(g2AffinePointIsOnCurve(b_x0_mont, b_x1_mont, b_y0_mont, b_y1_mont)) {
                    burnGas()
                }

                mstore(0, b_x0)
                mstore(32, b_x1)
                mstore(64, b_y0)
                mstore(96, b_y1)
                return(0, 128)
            }

            if bIsInfinity {
                // A + Infinity = A

                // Ensure that the coordinates are between 0 and the field order
                if iszero(and(g2CoordinateIsOnFieldOrder(a_x0, a_x1), g2CoordinateIsOnFieldOrder(a_y0, a_y1))) {
                    burnGas()
                }

                let a_x0_mont := intoMontgomeryForm(a_x0)
                let a_x1_mont := intoMontgomeryForm(a_x1)
                let a_y0_mont := intoMontgomeryForm(a_y0)
                let a_y1_mont := intoMontgomeryForm(a_y1)

                // Ensure that the point is in the curve
                if iszero(g2AffinePointIsOnCurve(a_x0_mont, a_x1_mont, a_y0_mont, a_y1_mont)) {
                    burnGas()
                }

                mstore(0, a_x0)
                mstore(32, a_x1)
                mstore(64, a_y0)
                mstore(96, a_y1)
                return(0, 128)
            }

            // Ensure that the coordinates are between 0 and the field order
            if iszero(and(g2CoordinateIsOnFieldOrder(a_x0, a_x1), g2CoordinateIsOnFieldOrder(a_y0, a_y1))) {
                burnGas()
            }
            if iszero(and(g2CoordinateIsOnFieldOrder(b_x0, b_x1), g2CoordinateIsOnFieldOrder(b_y0, b_y1))) {
                burnGas()
            }

            // TODO: ADD OPTIMIZATIONS FOR A = (-B) AND FOR A = B

            let a_x0_mont := intoMontgomeryForm(a_x0)
            let a_x1_mont := intoMontgomeryForm(a_x1)
            let a_y0_mont := intoMontgomeryForm(a_y0)
            let a_y1_mont := intoMontgomeryForm(a_y1)

            let b_x0_mont := intoMontgomeryForm(b_x0)
            let b_x1_mont := intoMontgomeryForm(b_x1)
            let b_y0_mont := intoMontgomeryForm(b_y0)
            let b_y1_mont := intoMontgomeryForm(b_y1)

            // Ensure that the points are in the curve
            if iszero(g2AffinePointIsOnCurve(a_x0_mont, a_x1_mont, a_y0_mont, a_y1_mont)) {
                console_log(0xACA)
                burnGas()
            }
            if iszero(g2AffinePointIsOnCurve(b_x0_mont, b_x1_mont, b_y0_mont, b_y1_mont)) {
                console_log(0xBEBE)
                burnGas()
            }

            let c00, c01, c10, c11, c20, c21 := g2JacobianAdd(a_x0_mont, a_x1_mont, a_y0_mont, a_y1_mont, MONTGOMERY_ONE(), 0, b_x0_mont, b_x1_mont, b_y0_mont, b_y1_mont, MONTGOMERY_ONE(), 0)

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
