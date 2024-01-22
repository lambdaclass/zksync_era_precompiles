object "EcAddG2" {
    code { }
    object "EcAddG2_deployed" {
        code {
            // CONSTANTS

            /// @notice Constant function for the alt_bn128 group order.
            /// @dev See https://eips.ethereum.org/EIPS/eip-196 for further details.
            /// @return ret The alt_bn128 group order.
            function P() -> ret {
                ret := 21888242871839275222246405745257275088696311157297823662689037894645226208583
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

            /// @notice Constant function for the zero element in the twisted cuve on affine representation.
            /// @return z00, z01, z10, z11, z20, z21 The values of infinity point on affine representation.
            function G2_INFINITY() -> z00, z01, z02, z10, z11, z12 {
                z00 := 0
                z01 := 0
                z02 := 0
                z10 := 0
                z11 := 0
                z12 := 0
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
			}add

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

            ////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////

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

                // Ensure that the coordinates are between 0 and the field order.
                if iszero(and(g2CoordinateIsOnFieldOrder(b_x0, b_x1), g2CoordinateIsOnFieldOrder(b_x0, b_x1))) {
                    burnGas()
                }

                let b_x0_mont := intoMontgomeryForm(b_x0)
                let b_x1_mont := intoMontgomeryForm(b_x1)
                let b_y0_mont := intoMontgomeryForm(b_y0)
                let b_y1_mont := intoMontgomeryForm(b_y1)

                // Ensure that the point is in the curve (Y^2 = X^3 + 3).
                if iszero(g2AffinePointIsOnCurve(b_x0_mont, b_x1_mont, b_y0_mont, b_y1_mont)) {
                    burnGas()
                }

                // We just need to go into the Montgomery form to perform the
                // computations in pointIsInCurve, but we do not need to come back.

                mstore(0, b_x0)
                mstore(32, b_x1)
                mstore(64, b_y0)
                mstore(96, b_y1)
                return(0, 128)
            }

            if bIsInfinity {
                // A + Infinity = A

                // Ensure that the coordinates are between 0 and the field order.
                if iszero(and(g2CoordinateIsOnFieldOrder(a_x0, a_x1), g2CoordinateIsOnFieldOrder(a_x1, a_y1))) {
                    burnGas()
                }

                let a_x0_mont := intoMontgomeryForm(a_x0)
                let a_x1_mont := intoMontgomeryForm(a_x1)
                let a_y0_mont := intoMontgomeryForm(a_y0)
                let a_y1_mont := intoMontgomeryForm(a_y1)

                // Ensure that the point is in the curve (Y^2 = X^3 + 3).
                if iszero(g2AffinePointIsOnCurve(a_x0_mont, a_x1_mont, a_y0_mont, a_y1_mont)) {
                    burnGas()
                }

                // We just need to go into the Montgomery form to perform the
                // computations in pointIsInCurve, but we do not need to come back.

                mstore(0, a_x0)
                mstore(32, a_x1)
                mstore(64, a_y0)
                mstore(96, a_y1)
                return(0, 128)
            }

            // Ensure that the coordinates are between 0 and the field order.
            if iszero(and(g2CoordinateIsOnFieldOrder(a_x0, a_x1), g2CoordinateIsOnFieldOrder(a_x1, a_y1))) {
                burnGas()
            }
            if iszero(and(g2CoordinateIsOnFieldOrder(b_x0, b_x1), g2CoordinateIsOnFieldOrder(b_x1, b_y1))) {
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



            return(0, 64)
        }
    }
}
