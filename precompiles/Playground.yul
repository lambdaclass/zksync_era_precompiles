object "EcPairing" {
	code { }
	object "EcPairing_deployed" {
		code {
            // CONSTANTS

            // CONSOLE.LOG Caller
            // It prints 'val' in the node console and it works using the 'mem'+0x40 memory sector
            function console_log(val) -> {
                let log_address := 0x000000000000000000636F6e736F6c652e6c6f67
                // load the free memory pointer
                let freeMemPointer := 0x600
                // store the function selector of log(uint256) in memory
                mstore(freeMemPointer, 0xf82c50f1)
                // store the first argument of log(uint256) in the next memory slot
                mstore(add(freeMemPointer, 0x20), val)
                // call the console.log contract
                if iszero(staticcall(gas(),log_address,add(freeMemPointer, 28),add(freeMemPointer, 0x40),0x00,0x00)) {
                    revert(0,0)
                }
            }

            /// @notice Constant function for value zero.
            /// @return zero The value zero.
            function ZERO() -> zero {
                zero := 0x00
            }

            /// @notice Constant function for value one.
            /// @return one The value one.
            function ONE() -> one {
                one := 0x01
            }

            /// @notice Constant function for value two.
            /// @return two The value two.
            function TWO() -> two {
                two := 0x02
            }

            /// @notice Constant function for value three.
            /// @return three The value three.
            function THREE() -> three {
                three := 0x03
            }

            function X_GEN() -> ret {
                ret := 4965661367192848881
            }

            /// @notice Constant function for value one in Montgomery form.
            /// @dev This value was precomputed using Python.
            /// @return m_one The value one in Montgomery form.
            function MONTGOMERY_ONE() -> m_one {
                m_one := 6350874878119819312338956282401532409788428879151445726012394534686998597021
            }

            /// @notice Constant function for value two in Montgomery form.
            /// @dev This value was precomputed using Python.
            /// @return m_two The value two in Montgomery form.
            function MONTGOMERY_TWO() -> m_two {
                m_two := 12701749756239638624677912564803064819576857758302891452024789069373997194042
            }

            /// @notice Constant function for value three in Montgomery form.
            /// @dev This value was precomputed using Python.
            /// @return m_three The value three in Montgomery form.
            function MONTGOMERY_THREE() -> m_three {
                m_three := 19052624634359457937016868847204597229365286637454337178037183604060995791063
            }

            /// @notice Constant function for the inverse of two on the alt_bn128 group in Montgomery form.
            /// @dev This value was precomputed using Python.
            /// @return two_inv The value of the inverse of two on the alt_bn128 group in Montgomery form.
            function MONTGOMERY_TWO_INV() -> two_inv {
                two_inv := 14119558874979547267292681013829403749242370018224634694350716214666112402802
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

            /// @notice Constant function for the alt_bn128 group order.
            /// @dev See https://eips.ethereum.org/EIPS/eip-196 for further details.
            /// @return ret The alt_bn128 group order.
            function P() -> ret {
                ret := 21888242871839275222246405745257275088696311157297823662689037894645226208583
            }

            /// @notice Constant function for the pre-computation of R^2 % N for the Montgomery REDC algorithm.
            /// @dev R^2 is the Montgomery residue of the value 2^512.
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further detals.
            /// @dev This value was precomputed using Python.
            /// @return ret The value R^2 modulus the curve group order.
            function R2_MOD_P() -> ret {
                ret := 3096616502983703923843567936837374451735540968419076528771170197431451843209
            }

            /// @notice Constant function for the pre-computation of R^3 % N for the Montgomery REDC algorithm.
            /// @dev This value was precomputed using Python.
            /// @return ret The value R^3 modulus the curve group order.
            function R3_MOD_P() -> ret {
                ret := 14921786541159648185948152738563080959093619838510245177710943249661917737183
            }

            /// @notice Constant function for the pre-computation of N' for the Montgomery REDC algorithm.
            /// @dev N' is a value such that NN' = -1 mod R, with N being the curve group order.
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further detals.
            /// @dev This value was precomputed using Python.
            /// @return ret The value N'.
            function N_PRIME() -> ret {
                ret := 111032442853175714102588374283752698368366046808579839647964533820976443843465
            }

            /// @notice Constant function for decimal representation of the NAF for the Millers Loop.
            /// @dev Millers loop uses to iterate the NAF representation of the value t = 6x^2 + 1. Where x = 4965661367192848881 is a parameter of the BN 256 curve.
            /// @dev For details of the x parameter: https://hackmd.io/@jpw/bn254#Barreto-Naehrig-curves.
            /// @dev A NAF representation uses values: -1, 0 and 1. https://en.wikipedia.org/wiki/Non-adjacent_form.
            /// @dev For iterating between this values we represent the 0 as 001, the 1 as 010 and the -1 as 100.
            /// @dev Then we concatenate all and represent the result as a decimal. E.g. [0,-1,0,1] -> 001 100 001 010 -> 778
            /// @dev In each step of the iteration we just need to compute the operation AND between the number and 1, 2 and 4 to check the original value.
            /// @dev Finally we shift 3 bits to the right to get the next value.
            /// @dev For this implementation, the first two iterations of the Miller loop are skipped, so the last two digits of the NAF representation of t are not used.
            /// @dev This value was precomputed using Python.
            /// @return ret The value of the decimal representation of the NAF.
            function NAF_REPRESENTATIVE() ->  ret {
                ret := 112285798093791963372401816628038344551273221779706221137
            }

            function ENDOMORPHISM_COEFFS() -> u0, u1, v0, v1 {
                u0 := 11461073415658098971834280704587444395456423268720245247603935854280982113072
                u1 := 17373957475705492831721812124331982823197004514106338927670775596783233550167
                v0 := 16829996427371746075450799880956928810557034522864196246648550205375670302249
                v1 := 20140510615310063345578764457068708762835443761990824243702724480509675468743
            } 

            /// @notice Constant function for the zero element in Fp6 representation.
            /// @return z00, z01, z10, z11, z20, z21 The values of zero in Fp6.
            function FP6_ZERO() -> z00, z01, z10, z11, z20, z21 {
                z00 := 0
                z01 := 0
                z10 := 0
                z11 := 0
                z20 := 0
                z21 := 0
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

            /// @notice Constant function for element one in Fp12 representation.
            /// @return the values of one in Fp12.
            function FP12_ONE() -> z000, z001, z010, z011, z100, z101, z110, z111, z200, z201, z210, z211 {
                z000 := MONTGOMERY_ONE()
                z001 := 0
                z010 := 0
                z011 := 0
                z100 := 0
                z101 := 0
                z110 := 0
                z111 := 0
                z200 := 0
                z201 := 0
                z210 := 0
                z211 := 0
            }

            /// @notice Constant function for the lenght of the input of a single pair of points to compute the pairing.
            /// @return ret The lenght of a pair of points input.
            function PAIR_LENGTH() -> ret {
                ret := 0xc0
            }

			// HELPER FUNCTIONS

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

            /// @notice Checks if the LSB of a number is 1.
            /// @param x The number to check.
            /// @return ret True if the LSB is 1, false otherwise.
            function lsbIsOne(x) -> ret {
                ret := and(x, ONE())
            }

            // MONTGOMERY

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

            function montgomeryModularInverse(a) -> invmod {
                invmod := binaryExtendedEuclideanAlgorithm(a)
            }

			// CURVE ARITHMETICS

            /// @notice Checks if a coordinate is on the curve group order.
            /// @dev A coordinate is on the curve group order if it is on the range [0, curveGroupOrder).
            /// @param coordinate The coordinate to check.
            /// @return ret True if the coordinate is in the range, false otherwise.
            function coordinateIsOnGroupOrder(coordinate) -> ret {
                ret := lt(coordinate, P())
            }

            // G2

            function g2ProjectiveIntoAffine(xp0, xp1, yp0, yp1, zp0, zp1) -> xr0, xr1, yr0, yr1 {
				let z0, z1 := fp2Inv(zp0, zp1)
				xr0, xr1 := fp2Mul(xp0, xp1, zp0, zp1)
				yr0, yr1 := fp2Mul(yp0, yp1, zp0, zp1)
			}

			/// @notice Converts a G2 point in affine coordinates to projective coordinates.
			/// @dev Both input and output coordinates are encoded in Montgomery form.
            /// @dev If x and y differ from 0, just add z = (1,0).
            /// @dev If x and y are equal to 0, then P is the infinity point, and z = (0,0).
            /// @param xp0, xp1 The x coordinate to trasnform.
            /// @param yp0, yp1 The y coordinate to transform.
            /// @return xr0, xr1, yr0, yr1, zr0, zr1 The projectives coordinates of the given G2 point.
			function g2ProjectiveFromAffine(xp0, xp1, yp0, yp1) -> xr0, xr1, yr0, yr1, zr0, zr1 {
				xr0 := xp0
				xr1 := xp1
				yr0 := yp0
				yr1 := yp1
				zr0 := MONTGOMERY_ONE()
				zr1 := ZERO()
				if and(eq(xp0, ZERO()), eq(xp1, ZERO())) {
					if and(eq(yp0, ZERO()), eq(yp1, ZERO())) {
						xr0 := MONTGOMERY_ONE()
						// xr1 is already ZERO()
						yr0 := MONTGOMERY_ONE()
						// yr1 is already ZERO()
						zr0 := ZERO()
						// zr1 is already ZERO()
					}
				}
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
                // FIXME: this check should be outside of the function
                if g2AffinePointIsInfinity(x0, x1, y0, y1) {
                    ret := 1
                }
                if iszero(g2AffinePointIsInfinity(x0, x1, y0, y1)) {
                    let a0, a1 := MONTGOMERY_TWISTED_CURVE_COEFFS()
                    let b0, b1 := fp2Mul(x0, x1, x0, x1)
                    b0, b1 := fp2Mul(b0, b1, x0, x1)
                    b0, b1 := fp2Add(b0, b1, a0, a1)
                    let c0, c1 := fp2Mul(y0, y1, y0, y1)
                    ret := and(eq(b0, c0), eq(b1, c1))
                }
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

            // Neg function for G2 in affine coordinates
            function g2AffineNeg(x0, x1, y0, y1) -> nx0, nx1, ny0, ny1 {
                nx0 := x0
                nx1 := x1
                ny0, ny1 := fp2Neg(y0, y1)
            }

            // Neg function for G2 in projective coordinates
            function g2ProjectiveNeg(x0, x1, y0, y1, z0, z1) -> nx0, nx1, ny0, ny1, nz0, nz1 {
                nx0 := x0
                nx1 := x1
                ny0, ny1 := fp2Neg(y0, y1)
                nz0 := z0
                nz1 := z1
            }

            function g2Eq(xp0, xp1, yp0, yp1, zp0, zp1, xq0, xq1, yq0, yq1, zq0, zq1) -> ret {
                switch and(iszero(or(zp0, zp1)), iszero(or(zq0, zq1)))
                    case 1 {
                        ret := 1
                    }
                    default {
                        let xr0, xr1, yr0, yr1 := g2ProjectiveIntoAffine(xp0, xp1, yp0, yp1, zp0, zp1)
                        let xs0, xs1, ys0, ys1 := g2ProjectiveIntoAffine(xq0, xq1, yq0, yq1, zq0, zq1)
                        ret := and(eq(xr0, xs0), eq(xr1, xs1))
                        ret := and(eq(yr0, ys0), eq(yr1, ys1))
                    }
            }

            function psi(xp0, xp1, yp0, yp1, zp0, zp1) -> xr0, xr1, yr0, yr1, zr0, zr1 {
                let u0, u1, v0, v1 := ENDOMORPHISM_COEFFS()

                xr0, xr1 := fp2Conjugate(xp0, xp1)
                xr0, xr1 := fp2Mul(xr0, xr1, u0, u1)

                yr0, yr1 := fp2Conjugate(yp0, yp1)
                yr0, yr1 := fp2Mul(yr0, yr1, v0, v1)

                zr0, zr1 := fp2Conjugate(zp0, zp1)
            }

            // IsInSubGroup returns true if p is on the r-torsion, false otherwise.
            function g2IsInSubGroup(xp0, xp1, yp0, yp1, zp0, zp1) -> ret {
                let a00, a01, a10, a11, a20, a21 := g2ScalarMul(xp0, xp1, yp0, yp1, zp0, zp1, X_GEN())
                let b00, b01, b10, b11, b20, b21 := psi(a00, a01, a10, a11, a20, a21)
                a00, a01, a10, a11, a20, a21 := g2Add(xp0, xp1, yp0, yp1, zp0, zp1, a00, a01, a10, a11, a20, a21)
                let c00, c01, c10, c11, c20, c21 := psi(b00, b01, b10, b11, b20, b21)
                let d00, d01, d10, d11, d20, d21 := g2Add(b00, b01, b10, b11, b20, b21, c00, c01, c10, c11, c20, c21)
                d00, d01, d10, d11, d20, d21 := g2Add(a00, a01, a10, a11, a20, a21, d00, d01, d10, d11, d20, d21)
                c00, c01, c10, c11, c20, c21 := psi(c00, c01, c10, c11, c20, c21)
                c00, c01, c10, c11, c20, c21 := g2Add(c00, c01, c10, c11, c20, c21, c00, c01, c10, c11, c20, c21)
                c00, c01, c10, c11, c20, c21 := g2Sub(c00, c01, c10, c11, c20, c21, d00, d01, d10, d11, d20, d21)

                ret := and(g2AffinePointIsOnCurve(c00, c01, c10, c11), g2ProjectivePointIsInfinity(c00, c01, c10, c11, c20, c21))
            }

            function g2ProjectiveDouble(xp0, xp1, yp0, yp1, zp0, zp1) -> xr0, xr1, yr0, yr1, zr0, zr1 {
                let x_squared0, x_squared1 := fp2Mul(xp0, xp1, xp0, xp1)
                let temp00, temp01 := fp2Add(x_squared0, x_squared1, x_squared0, x_squared1)
                let t0, t1 := fp2Add(x_squared0, x_squared1, temp00, temp01)
                let yz0, yz1 := fp2Mul(yp0, yp1, zp0, zp1)
                let u0, u1 := fp2Add(yz0, yz1, yz0, yz1)
                let temp10, temp11 := fp2Mul(xp0, xp1, yp0, yp1)
                let uxy0, uxy1 := fp2Mul(u0, u1, temp10, temp11)
                let v0, v1 := fp2Add(uxy0, uxy1, uxy0, uxy1)
                let temp20, temp21 := fp2Mul(t0, t1, t0, t1)
                let temp30, temp31 := fp2Add(v0, v1, v0, v1)
                let w0, w1 := fp2Sub(temp20, temp21, temp30, temp31)

                xr0, xr1 := fp2Mul(u0, u1, w0, w1)
                let uy0, uy1 := fp2Mul(u0, u1, yp0, yp1)
                let uy_squared0, uy_squared1 := fp2Mul(uy0, uy1, uy0, uy1)
                let temp40, temp41 := fp2Sub(v0, v1, w0, w1)
                let temp50, temp51 := fp2Mul(t0, t1, temp40, temp41)
                let temp60, temp61 := fp2Add(uy_squared0, uy_squared1, uy_squared0, uy_squared1)
                yr0, yr1 := fp2Sub(temp50, temp51, temp60, temp61)
                let temp70, temp71 := fp2Mul(u0, u1, u0, u1)
                zr0, zr1 := fp2Mul(u0, u1, temp70, temp71)
            }

            function g2Add(xq0, xq1, yq0, yq1, zq0, zq1, xr0, xr1, yr0, yr1, zr0, zr1) -> c00, c01, c10, c11, c20, c21 {
                let qIsInfinity := g2ProjectivePointIsInfinity(xq0, xq1, yq0, yq1, zq0, zq1)
                let rIsInfinity := g2ProjectivePointIsInfinity(xr0, xr1, yr0, yr1, zr0, zr1)
                if and(rIsInfinity, qIsInfinity) {
                    // Infinity + Infinity = Infinity
                    leave
                }
                if and(rIsInfinity, iszero(qIsInfinity)) {
                    // Infinity + P = P
                    c00 := xq0
                    c01 := xq1
                    c10 := yq0
                    c11 := yq1
                    c20 := zq0
                    c21 := zq1
                    leave
                }
                if and(iszero(rIsInfinity), qIsInfinity) {
                    // P + Infinity = P
                    c00 := xr0
                    c01 := xr1
                    c10 := yr0
                    c11 := yr1
                    c20 := zr0
                    c21 := zr1
                    leave
                }
                if g2Eq(xr0, xr1, montgomerySub(0, yr0), montgomerySub(0, yr1), zr0, zr1, xq0, xq1, yq0, yq1, zq0, zq1) {
                    // P + (-P) = Infinity
                    c00 := 0
                    c01 := 0
                    c10 := 0
                    c11 := 0
                    c20 := 0
                    c21 := 0
                    leave
                }
                // FIXME: This condition is not addapted for fp2
                if g2Eq(xr0, xr1, xq0, xq1, yr0, yr1, yq0, yq1, zr0, zr1, zq0, zq1) {
                    // P + P = 2P
                    c00, c01, c10, c11, c20, c21 := g2ProjectiveDouble(xr0, xr1, yr0, yr1, zr0, zr1)
                    leave
                }
                    // P1 + P2 = P3
            
                    let t00, t01 := fp2Mul(yq0, yq1, zr0, zr1)
                    let t10, t11 := fp2Mul(yr0, yr1, zq0, zq1)
                    let t0, t1 := fp2Sub(t00, t01, t10, t11)
                    let u00, u01 := fp2Mul(xq0, zq1, zr0, zr1)
                    let u10, u11 := fp2Mul(xr0, xr1, zq0, zq1)
                    let u0, u1 := fp2Sub(u00, u01, u10, u11)
                    let u20, u21 := fp2Mul(u0, u1, u0, u1)
                    let u30, u31 := fp2Mul(u20, u21, u0, u1)
                    let v0, v1 := fp2Mul(zq0, zq1, zr0, zr1)

                    let temp00, temp01 := fp2Add(u00, u01, u10, u11)
                    let temp10, temp11 := fp2Mul(u20, u21, temp00, temp01)
                    let temp20, temp21 := fp2Mul(t0, t1, t0, t1)
                    let temp30, temp31 := fp2Mul(temp20, temp21, v0, v1)
                    let w0, w1 := fp2Sub(temp30, temp31, temp10, temp11)
            
                    c00, c01 := fp2Mul(u0, u1, w0, w1)
                            
                    temp00, temp01 := fp2Mul(u00, u01, u20, u21)
                    temp10, temp11 := fp2Sub(temp00, temp01, w0, w1)
                    temp20, temp21 := fp2Mul(t00, t01, u30, u31)
                    temp30, temp31 := fp2Mul(t0, t1, temp10, temp11)
                    c10, c11 := fp2Sub(temp30, temp31, temp20, temp21)

                    c20, c21 := fp2Mul(u30, u31, v0, v1)
                }
            }

            function g2Sub(xq0, xq1, yq0, yq1, zq0, zq1, xr0, xr1, yr0, yr1, zr0, zr1) -> c00, c01, c10, c11, c20, c21 {
                let a00, a01, a10, a11, a20, a21 := g2ProjectiveNeg(xr0, xr1, yr0, yr1, zr0, zr1)
                c00, c01, c10, c11, c20, c21 := g2Add(xq0, xq1, yq0, yq1, zq0, zq1, a00, a01, a10, a11, a20, a21)
            }

            function g2ScalarMul(xp0, xp1, yp0, yp1, zp0, zp1, scalar) -> xr0, xr1, yr0, yr1, zr0, zr1 {
                switch scalar
                case 0x02 {
                    xr0, xr1, yr0, yr1, zr0, zr1 := g2ProjectiveDouble(xp0, xp1, yp0, yp1, zp0, yp1)
                }
                default {
                    let xq0 := xp0
                    let xq1 := xp1
                    let yq0 := yp0
                    let yq1 := yp1
                    let zq0 := zp0
                    let zq1 := zp1
                    xr0 := MONTGOMERY_ONE()
                    xr1 := 0
                    yr0 := MONTGOMERY_ONE()
                    yr1 := 0
                    zr0 := 0
                    zr1 := 0
                    for {} scalar {} {

                        if lsbIsOne(scalar) {
                            let qIsInfinity := g2ProjectivePointIsInfinity(xq0, xq1, yq0, yq1, zq0, zq1)
                            let rIsInfinity := g2ProjectivePointIsInfinity(xr0, xr1, yr0, yr1, zr0, zr1)
                            if and(rIsInfinity, qIsInfinity) {
                                // Infinity + Infinity = Infinity
                                break
                            }
                            if and(rIsInfinity, iszero(qIsInfinity)) {
                                // Infinity + P = P
                                xr0 := xq0
                                xr1 := xq1
                                yr0 := yq0
                                yr1 := yq1
                                zr0 := zq0
                                zr1 := zq1
        
                                xq0, xq1, yq0, yq1, zq0, zq1 := g2ProjectiveDouble(xq0, xq1, yq0, yq1, zq0, zq1)
                                // Check next bit
                                scalar := shr(1, scalar)
                                continue
                            }
                            if and(iszero(rIsInfinity), qIsInfinity) {
                                // P + Infinity = P
                                break
                            }
                            // We could've used the neg function for G2 but we would need auxiliar variables for the negation
                            if g2Eq(xr0, xr1, montgomerySub(0, yr0), montgomerySub(0, yr1), zr0, zr1, xq0, xq1, yq0, yq1, zq0, zq1) {
                                // P + (-P) = Infinity
                                xr0 := 0
                                xr1 := 0
                                yr0 := 0
                                yr1 := 0
                                zr0 := 0
                                zr1 := 0
        
                                xq0, xq1, yq0, yq1, zq0, zq1 := g2ProjectiveDouble(xq0, xq1, yq0, yq1, zq0, zq1)
                                // Check next bit
                                scalar := shr(1, scalar)
                                continue
                            }
                            // FIXME: This condition is not addapted for fp2
                            if g2Eq(xr0, xr1, xq0, xq1, yr0, yr1, yq0, yq1, zr0, zr1, zq0, zq1) {
                                // P + P = 2P
                                xr0, xr1, yr0, yr1, zr0, zr1 := g2ProjectiveDouble(xr0, xr1, yr0, yr1, zr0, zr1)
        
                                xq0 := xr0
                                xq1 := xr1
                                yq0 := yr0
                                yq1 := yr1
                                zq0 := zr0
                                zq1 := zr1
                                // Check next bit
                                scalar := shr(1, scalar)
                                continue
                            }
        
                            // P1 + P2 = P3
        
                            let t00, t01 := fp2Mul(yq0, yq1, zr0, zr1)
                            let t10, t11 := fp2Mul(yr0, yr1, zq0, zq1)
                            let t0, t1 := fp2Sub(t00, t01, t10, t11)
                            let u00, u01 := fp2Mul(xq0, zq1, zr0, zr1)
                            let u10, u11 := fp2Mul(xr0, xr1, zq0, zq1)
                            let u0, u1 := fp2Sub(u00, u01, u10, u11)
                            let u20, u21 := fp2Mul(u0, u1, u0, u1)
                            let u30, u31 := fp2Mul(u20, u21, u0, u1)
                            let v0, v1 := fp2Mul(zq0, zq1, zr0, zr1)

                            let temp00, temp01 := fp2Add(u00, u01, u10, u11)
                            let temp10, temp11 := fp2Mul(u20, u21, temp00, temp01)
                            let temp20, temp21 := fp2Mul(t0, t1, t0, t1)
                            let temp30, temp31 := fp2Mul(temp20, temp21, v0, v1)
                            let w0, w1 := fp2Sub(temp30, temp31, temp10, temp11)
            
                            xr0, xr1 := fp2Mul(u0, u1, w0, w1)
                            
                            temp00, temp01 := fp2Mul(u00, u01, u20, u21)
                            temp10, temp11 := fp2Sub(temp00, temp01, w0, w1)
                            temp20, temp21 := fp2Mul(t00, t01, u30, u31)
                            temp30, temp31 := fp2Mul(t0, t1, temp10, temp11)
                            yr0, yr1 := fp2Sub(temp30, temp31, temp20, temp21)

                            zr0, zr1 := fp2Mul(u30, u31, v0, v1)
                        }
        
                        xq0, xq1, yq0, yq1, zq0, zq1 := g2ProjectiveDouble(xq0, xq1, yq0, yq1, zq0, zq1)
                        // Check next bit
                        scalar := shr(1, scalar)
                    }
                }
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
                c00, c01 := fp2Sub(ZERO(), ZERO(), a00, a01)
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
                c01 := montgomerySub(ZERO(), montgomeryMul(a01, t1))
            }

            /// @notice Computes the conjugation of a Fp2 element.
            /// @param a00, a01 The coefficients of the Fp2 element A.
            /// @return c00, c01 The coefficients of the element C = A'.
            function fp2Conjugate(a00, a01) -> c00, c01 {
                c00 := a00
                c01 := montgomerySub(ZERO(), a01)
            }

            // FALLBACK
            
            // POINT NOT IN SUBGROUP
            // 0000000000000000000000000000000000000000000000000000000000000000
            // 0000000000000000000000000000000000000000000000000000000000000000

            // 0000000000000000000000000000000000000000000000000000000000000000
            // 0000000000000000000000000000000000000000000000000000000000000008

            // 00d3270b7da683f988d3889abcdad9776ecd45abaca689f1118c3fd33404b439
            // 2588360d269af2cd3e0803839ea274c2b8f062a6308e8da85fd774c26f1bcb87

            // POINT IN SUBGROUP
            // 0000000000000000000000000000000000000000000000000000000000000001
            // 0000000000000000000000000000000000000000000000000000000000000002

            // 198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2
            // 1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed
            // 090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b
            // 12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa
            
            let g2_y0 := intoMontgomeryForm(0)
            let g2_x0 := intoMontgomeryForm(8)

            let g2_y1 := intoMontgomeryForm(0x00d3270b7da683f988d3889abcdad9776ecd45abaca689f1118c3fd33404b439)
            let g2_x1 := intoMontgomeryForm(0x2588360d269af2cd3e0803839ea274c2b8f062a6308e8da85fd774c26f1bcb87)

            let g2_y2 := intoMontgomeryForm(0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2)
            let g2_x2 := intoMontgomeryForm(0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed)
            let g2_y3 := intoMontgomeryForm(0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b)
            let g2_x3 := intoMontgomeryForm(0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa)

            if iszero(g2IsInSubGroup(g2_x0,g2_x1, g2_y0, g2_y1, MONTGOMERY_ONE(), 0)) {
                console_log(0xCAFE)
			}

            if g2IsInSubGroup(g2_x2,g2_x3, g2_y2, g2_y3, MONTGOMERY_ONE(), 0) {
                console_log(0xCAFE)
			}

		}
	}
}
