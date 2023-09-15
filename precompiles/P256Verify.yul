object "P256VERIFY" {
    code { }
    object "P256VERIFY_deployed" {
        code {
            // Constants

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

            // CURVE CONSTANTS

            // elliptic curve coefficient
            function A() -> a {
                a := 0xffffffff00000001000000000000000000000000fffffffffffffffffffffffc
            }

            // elliptic curve coefficient
            function B() -> b {
                b := 0x5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b
            }

            function P() -> p {
                p := 0xffffffff00000001000000000000000000000000ffffffffffffffffffffffff
            }

            // order of the subgroup
            function N() -> p {
                p := 0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551
            }

            // cofactor of the subgroup
            function H() -> h {
                h := 0x1
            }

            // base point of the subgroup
            function G() -> gx, gy {
                gx := 0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296
                gy := 0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5
            }

            // MONTGOMERY CONSTANTS

            /// @notice Constant function for value one in Montgomery form.
            /// @dev This value was precomputed using Python.
            /// @return m_one The value one in Montgomery form.
            function MONTGOMERY_ONE() -> m_one {
                m_one := 26959946660873538059280334323183841250350249843923952699046031785985
            }

            function MONTGOMERY_A() -> m_a {
                m_a := 115792089129476408780076832771566570560534619664239564663761773211729002495996
            }

            function MONTGOMERY_B() -> m_b {
                m_b := 99593677540221402957765480916910020772520766868399186769503856397241456836063
            }

            /// @notice Constant function for the pre-computation of R^2 % N for the Montgomery REDC algorithm.
            /// @dev R^2 is the Montgomery residue of the value 2^512.
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further detals.
            /// @dev This value was precomputed using Python.
            /// @return ret The value R^2 modulus the curve group order.
            function R2_MOD_P() -> ret {
                ret := 134799733323198995502561713907086292154532538166959272814710328655875
            }

            /// @notice Constant function for the pre-computation of N' for the Montgomery REDC algorithm.
            /// @dev N' is a value such that NN' = -1 mod R, with N being the curve group order.
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further detals.
            /// @dev This value was precomputed using Python.
            /// @return ret The value N'.
            function N_PRIME() -> ret {
                ret := 115792089210356248768974548684794254293921932838497980611635986753331132366849
            }

            // Function Helpers

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

            /// @notice Computes an addition and checks for overflow.
            /// @param augend The value to add to.
            /// @param addend The value to add.
            /// @return sum The sum of the two values.
            /// @return overflowed True if the addition overflowed, false otherwise.
            function overflowingAdd(augend, addend) -> sum, overflowed {
                sum := add(augend, addend)
                overflowed := or(lt(sum, augend), lt(sum, addend))
            }

            /// @notice Retrieves the highest half of the multiplication result.
            /// @param multiplicand The value to multiply.
            /// @param multiplier The multiplier.
            /// @return ret The highest half of the multiplication result.
            function getHighestHalfOfMultiplication(multiplicand, multiplier) -> ret {
                ret := verbatim_2i_1o("mul_high", multiplicand, multiplier)
            }

            /// @notice Implementation of the Montgomery reduction algorithm (a.k.a. REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithm
            /// @param lowestHalfOfT The lowest half of the value T.
            /// @param higherHalfOfT The higher half of the value T.
            /// @return S The result of the Montgomery reduction.
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

            /// @notice Encodes a field element into the Montgomery form using the Montgomery reduction algorithm (REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithmfor further details on transforming a field element into the Montgomery form.
            /// @param a The field element to encode.
            /// @return ret The field element in Montgomery form.
            function intoMontgomeryForm(a) -> ret {
                    let higher_half_of_a := getHighestHalfOfMultiplication(mod(a, P()), R2_MOD_P())
                    let lowest_half_of_a := mul(mod(a, P()), R2_MOD_P())
                    ret := REDC(lowest_half_of_a, higher_half_of_a)
            }

            /// @notice Decodes a field element out of the Montgomery form using the Montgomery reduction algorithm (REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithm for further details on transforming a field element out of the Montgomery form.
            /// @param m The field element in Montgomery form to decode.
            /// @return ret The decoded field element.
            function outOfMontgomeryForm(m) -> ret {
                    let higher_half_of_m := ZERO()
                    let lowest_half_of_m := m 
                    ret := REDC(lowest_half_of_m, higher_half_of_m)
            }

            /// @notice Computes the Montgomery addition.
            /// @param augend The augend in Montgomery form.
            /// @param addend The addend in Montgomery form.
            /// @return ret The result of the Montgomery addition.
            function montgomeryAdd(augend, addend) -> ret {
                ret := addmod(augend, addend, P())
            }

            /// @notice Computes the Montgomery subtraction.
            /// @param minuend The minuend in Montgomery form.
            /// @param subtrahend The subtrahend in Montgomery form.
            /// @return ret The result of the Montgomery subtraction.
            function montgomerySub(minuend, subtrahend) -> ret {
                ret := montgomeryAdd(minuend, sub(P(), subtrahend))
            }

            /// @notice Computes the Montgomery multiplication using the Montgomery reduction algorithm (REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithm for further details on the Montgomery multiplication.
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

            /// @notice Computes the Montgomery division.
            /// @dev The Montgomery division is computed by multiplying the dividend by the modular inverse of the divisor.
            /// @param dividend The dividend in Montgomery form.
            /// @param divisor The divisor in Montgomery form.
            /// @return quotient The result of the Montgomery division.
            function montgomeryDiv(dividend, divisor) -> quotient {
                quotient := montgomeryMul(dividend, montgomeryModularInverse(divisor))
            }

            // CURVE ARITHMETICS

            /// @notice Checks if a field element is on the curve group order.
            /// @dev A field element is on the curve group order if it is on the range [0, curveGroupOrder).
            /// @param felt The field element to check.
            /// @return ret True if the field element is in the range, false otherwise.
            function fieldElementIsOnGroupOrder(felt) -> ret {
                ret := lt(felt, P())
            }

            /// @notice Checks if affine coordinates are on the curve group order.
            /// @dev Affine coordinates are on the curve group order if both coordinates are on the range [0, curveGroupOrder).
            /// @param xp The x coordinate of the point P to check.
            /// @param yp The y coordinate of the point P to check.
            /// @return ret True if the coordinates are in the range, false otherwise.
            function affinePointCoordinatesAreOnGroupOrder(xp, yp) -> ret {
                ret := and(fieldElementIsOnGroupOrder(xp), fieldElementIsOnGroupOrder(yp))
            }

            /// @notice Checks if a point in affine coordinates is the point at infinity.
            /// @dev The point at infinity is defined as the point (0, 0).
            /// @dev See https://eips.ethereum.org/EIPS/eip-196 for further details.
            /// @param xp The x coordinate of the point P in Montgomery form.
            /// @param yp The y coordinate of the point P in Montgomery form.
            /// @return ret True if the point is the point at infinity, false otherwise.
            function affinePointIsInfinity(xp, yp) -> ret {
                ret := iszero(or(xp, yp))
            }

            // @notice Checks if a point in affine coordinates in Montgomery form is on the curve.
            // @dev The curve in question is the secp256r1 curve.
            // @dev The Short Weierstrass equation of the curve is y^2 = x^3 + ax + b.
            // @param xp The x coordinate of the point P in Montgomery form.
            // @param yp The y coordinate of the point P in Montgomery form.
            // @return ret True if the point is on the curve, false otherwise.
            function affinePointIsOnCurve(xp, yp) -> ret {
                let left := montgomeryMul(yp, yp)
                let right := montgomeryMul(xp, montgomeryMul(xp, xp))
                right := montgomeryAdd(right, montgomeryMul(MONTGOMERY_A(), xp))
                right := montgomeryAdd(right, MONTGOMERY_B())
                ret := eq(left, right)
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
                    xr := ZERO()
                    yr := ZERO()
                }
                default {
                    let zp_inv := montgomeryModularInverse(zp)
                    xr := montgomeryMul(xp, zp_inv)
                    yr := montgomeryMul(yp, zp_inv)
                }
            }

            function projectivePointIsInfinity(xp, yp, zp) -> ret {
                ret := iszero(zp)
            }

            /// @notice Doubles a point in projective coordinates in Montgomery form.
            /// @dev See https://www.nayuki.io/page/elliptic-curve-point-addition-in-projective-coordinates for further details.
            /// @dev For performance reasons, the point is assumed to be previously checked to be on the
            /// @dev curve and not the point at infinity.
            /// @param xp The x coordinate of the point P in projective coordinates in Montgomery form.
            /// @param yp The y coordinate of the point P in projective coordinates in Montgomery form.
            /// @param zp The z coordinate of the point P in projective coordinates in Montgomery form.
            /// @return xr The x coordinate of the point 2P in projective coordinates in Montgomery form.
            /// @return yr The y coordinate of the point 2P in projective coordinates in Montgomery form.
            /// @return zr The z coordinate of the point 2P in projective coordinates in Montgomery form.
            function projectiveDouble(xp, yp, zp) -> xr, yr, zr {
                let x_squared := montgomeryMul(xp, xp)
                let z_squared := montgomeryMul(zp, zp)
                let az_squared := montgomeryAdd(MONTGOMERY_A(), z_squared)
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

            /// @notice Adds two points in projective coordinates in Montgomery form.
            /// @dev See https://www.nayuki.io/page/elliptic-curve-point-addition-in-projective-coordinates for further details.
            /// @dev For performance reasons, the points are assumed to be previously checked to be on the
            /// @dev curve and not the point at infinity.
            /// @param xp The x coordinate of the point P in projective coordinates in Montgomery form.
            /// @param yp The y coordinate of the point P in projective coordinates in Montgomery form.
            /// @param zp The z coordinate of the point P in projective coordinates in Montgomery form.
            /// @param xq The x coordinate of the point Q in projective coordinates in Montgomery form.
            /// @param yq The y coordinate of the point Q in projective coordinates in Montgomery form.
            /// @param zq The z coordinate of the point Q in projective coordinates in Montgomery form.
            /// @return xr The x coordinate of the point P + Q in projective coordinates in Montgomery form.
            /// @return yr The y coordinate of the point P + Q in projective coordinates in Montgomery form.
            /// @return zr The z coordinate of the point P + Q in projective coordinates in Montgomery form.
            function projectiveAdd(xp, yp, zp, xq, yq, zq) -> xr, yr, zr {
                let t0 := montgomeryMul(yq, zr)
                let t1 := montgomeryMul(yr, zq)
                let t := montgomerySub(t0, t1)
                let u0 := montgomeryMul(xq, zr)
                let u1 := montgomeryMul(xr, zq)
                let u := montgomerySub(u0, u1)
                let u2 := montgomeryMul(u, u)
                let u3 := montgomeryMul(u2, u)
                let v := montgomeryMul(zq, zr)
                let w := montgomerySub(montgomeryMul(montgomeryMul(t, t), v), montgomeryMul(u2, montgomeryAdd(u0, u1)))

                xr := montgomeryMul(u, w)
                yr := montgomerySub(montgomeryMul(t, montgomerySub(montgomeryMul(u0, u2), w)), montgomeryMul(t0, u3))
                zr := montgomeryMul(u3, v)
            }

            function projectiveScalarMul(xp, yp, zp, scalar) -> xr, yr, zr {
                switch eq(scalar, TWO())
                case 0 {
                    let xq := xp
                    let yq := yp
                    let zq := zp
                    xr := ZERO()
                    yr := MONTGOMERY_ONE()
                    zr := ZERO()
                    for {} scalar {} {
                        if lsbIsOne(scalar) {
                            let qIsInfinity := projectivePointIsInfinity(xq, yq, zq)
                            let rIsInfinity := projectivePointIsInfinity(xr, yr, zr)
                            if and(rIsInfinity, qIsInfinity) {
                                // Infinity + Infinity = Infinity
                                break
                            }
                            if and(rIsInfinity, iszero(qIsInfinity)) {
                                // Infinity + P = P
                                xr := xq
                                yr := yq
                                zr := zq
        
                                xq, yq, zq := projectiveDouble(xq, yq, zq)
                                // Check next bit
                                scalar := shr(1, scalar)
                                continue
                            }
                            if and(iszero(rIsInfinity), qIsInfinity) {
                                // P + Infinity = P
                                break
                            }
                            if and(and(eq(xr, xq), eq(montgomerySub(ZERO(), yr), yq)), eq(zr, zq)) {
                                // P + (-P) = Infinity
                                xr := ZERO()
                                yr := ZERO()
                                zr := ZERO()
        
                                xq, yq, zq := projectiveDouble(xq, yq, zq)
                                // Check next bit
                                scalar := shr(1, scalar)
                                continue
                            }
                            if and(and(eq(xr, xq), eq(yr, yq)), eq(zr, zq)) {
                                // P + P = 2P
                                xr, yr, zr := projectiveDouble(xr, yr, zr)
        
                                xq := xr
                                yq := yr
                                zq := zr
                                // Check next bit
                                scalar := shr(1, scalar)
                                continue
                            }
        
                            // P1 + P2 = P3
        
                            let t0 := montgomeryMul(yq, zr)
                            let t1 := montgomeryMul(yr, zq)
                            let t := montgomerySub(t0, t1)
                            let u0 := montgomeryMul(xq, zr)
                            let u1 := montgomeryMul(xr, zq)
                            let u := montgomerySub(u0, u1)
                            let u2 := montgomeryMul(u, u)
                            let u3 := montgomeryMul(u2, u)
                            let v := montgomeryMul(zq, zr)
                            let w := montgomerySub(montgomeryMul(montgomeryMul(t, t), v), montgomeryMul(u2, montgomeryAdd(u0, u1)))
            
                            xr := montgomeryMul(u, w)
                            yr := montgomerySub(montgomeryMul(t, montgomerySub(montgomeryMul(u0, u2), w)), montgomeryMul(t0, u3))
                            zr := montgomeryMul(u3, v)
                        }
        
                        xq, yq, zq := projectiveDouble(xq, yq, zq)
                        // Check next bit
                        scalar := shr(1, scalar)
                    }
                }
                case 1 {
                    xr, yr, zr := projectiveDouble(xp, yp, zp)
                }
            }

            // Fallback

            let hash := calldataload(0)
            let r := calldataload(32)
            let s := calldataload(64)
            let x := calldataload(96)
            let y := calldataload(128)

            if or(iszero(fieldElementIsOnGroupOrder(r)), iszero(fieldElementIsOnGroupOrder(s))) {
                burnGas()
            }

            if or(affinePointIsInfinity(x, y), iszero(affinePointCoordinatesAreOnGroupOrder(x, y))) {
                burnGas()
            }

            x := intoMontgomeryForm(x)
            y := intoMontgomeryForm(y)

            if iszero(affinePointIsOnCurve(x, y)) {
                burnGas()
            }

            let x, y, z := projectiveFromAffine(x, y)

            // TODO: Check if r, s, s1, t0 and t1 operations are optimal in Montgomery form or not

            r := intoMontgomeryForm(r)
            s := intoMontgomeryForm(s)

            let s1 := montgomeryModularInverse(s)

            let t0 := outOfMontgomeryForm(montgomeryMul(hash, s1))
            let t1 := outOfMontgomeryForm(montgomeryMul(r, s1))

            let gx, gy := G()
            let gx, gy, gz := projectiveFromAffine(gx, gy)

            let xp, yp, zp := projectiveScalarMul(gx, gy, gz, t0)
            let xq, yq, zq := projectiveScalarMul(x, y, z, t1)
            let xr, yr, zr := projectiveAdd(xp, yp, zp, xq, yq, zq)

            xr, yr := projectiveIntoAffine(xr, yr, zr)

            mstore(0, eq(xr, r))
            return(0, 32)
        }
    }
}
