object "P256VERIFY" {
    code { }
    object "P256VERIFY_deployed" {
        code {
            // Constants

            // CURVE CONSTANTS

            function P() -> p {
                p := 0xffffffff00000001000000000000000000000000ffffffffffffffffffffffff
            }

            // order of the subgroup
            function N() -> p {
                p := 0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551
            }

            // MONTGOMERY CONSTANTS

            /// @notice Constant function for value one in Montgomery form.
            /// @dev This value was precomputed using Python.
            /// @return m_one The value one in Montgomery form.
            function MONTGOMERY_ONE_P() -> m_one {
                m_one := 26959946660873538059280334323183841250350249843923952699046031785985
            }

            function MONTGOMERY_ONE_N() -> m_one {
                m_one := 26959946660873538059280334323273029441504803697035324946844617595567
            }

            function MONTGOMERY_A_P() -> m_a {
                m_a := 115792089129476408780076832771566570560534619664239564663761773211729002495996
            }

            function MONTGOMERY_B_P() -> m_b {
                m_b := 99593677540221402957765480916910020772520766868399186769503856397241456836063
            }

            function MONTGOMERY_PROJECTIVE_G_P() -> m_gx, m_gy, m_gz {
                m_gx := 0x18905F76A53755C679FB732B7762251075BA95FC5FEDB60179E730D418A9143C
                m_gy := 0x8571FF1825885D85D2E88688DD21F3258B4AB8E4BA19E45CDDF25357CE95560A
                m_gz := MONTGOMERY_ONE_P()
            }

            /// @notice Constant function for the pre-computation of R^2 % N for the Montgomery REDC algorithm.
            /// @dev R^2 is the Montgomery residue of the value 2^512.
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further detals.
            /// @dev This value was precomputed using Python.
            /// @return ret The value R^2 modulus the curve group order.
            function R2_MOD_P() -> ret {
                ret := 134799733323198995502561713907086292154532538166959272814710328655875
            }

            function R2_MOD_N() -> ret {
                ret := 46533765739406314298121036767150998762426774378559716911348521029833835802274
            }

            /// @notice Constant function for the pre-computation of N' for the Montgomery REDC algorithm.
            /// @dev N' is a value such that NN' = -1 mod R, with N being the curve group order.
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#The_REDC_algorithm for further detals.
            /// @dev This value was precomputed using Python.
            /// @return ret The value N'.
            function P_PRIME() -> ret {
                ret := 115792089210356248768974548684794254293921932838497980611635986753331132366849
            }

            function N_PRIME() -> ret {
                ret := 43790243024438006127650828685417305984841428635278707415088219106730833919055
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
                ret := and(x, 1)
            }

            // MONTGOMERY

            function binaryExtendedEuclideanAlgorithm(base, modulus, d) -> inv {
                // Precomputation of 1 << 255
                let mask := 57896044618658097711785492504343953926634992332820282019728792003956564819968
                // modulus >> 255 == 0 -> modulus & 1 << 255 == 0
                let modulusHasSpareBits := iszero(and(modulus, mask))

                let u := base
                let v := modulus
                // Avoids unnecessary reduction step.
                let b := d
                let c := 0x0

                for {} and(iszero(eq(u, 0x1)), iszero(eq(v, 0x1))) {} {
                    for {} iszero(and(u, 0x1)) {} {
                        u := shr(1, u)
                        let currentB := b
                        switch and(currentB, 0x1)
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

                    for {} iszero(and(v, 0x1)) {} {
                        v := shr(1, v)
                        let currentC := c
                        switch and(currentC, 0x1)
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

                switch eq(u, 0x1)
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
            // T es T
            // N es P, N' es P'
            // R es 2^256
            function REDC(TLo, THi, n, nPrime) -> S {
                let m := mul(TLo, nPrime)
                let tHi, tHiOverflowed := overflowingAdd(THi, getHighestHalfOfMultiplication(m, n))
                let aLo, aLoOverflowed := overflowingAdd(TLo, mul(m, n))
                if tHiOverflowed {
                    // TODO: Check if this addition could overflow.
                    tHi := add(tHi, sub(0, n))
                }
                if aLoOverflowed {
                    tHi, tHiOverflowed := overflowingAdd(tHi, 1)
                }
                if tHiOverflowed {
                    tHi, tHiOverflowed := overflowingAdd(tHi, sub(0, n))
                }
                S := tHi

                if iszero(lt(tHi, n)) {
                    S := sub(tHi, n)
                }
            }

            /// @notice Encodes a field element into the Montgomery form using the Montgomery reduction algorithm (REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithmfor further details on transforming a field element into the Montgomery form.
            /// @param a The field element to encode.
            /// @return ret The field element in Montgomery form.
            function intoMontgomeryForm(a, n, nPrime, r2) -> ret {
                let higher_half_of_a := getHighestHalfOfMultiplication(a, r2)
                let lowest_half_of_a := mul(a, r2)
                ret := REDC(lowest_half_of_a, higher_half_of_a, n, nPrime)
            }

            function intoMontgomeryFormN(a) -> ret {
                // Note: mod(a, N()) is left because `hash` could not be in the range [0, N()).
                let aModN := mod(a, N())
                let higher_half_of_a := getHighestHalfOfMultiplication(aModN, R2_MOD_N())
                let lowest_half_of_a := mul(aModN, R2_MOD_N())
                ret := REDC(lowest_half_of_a, higher_half_of_a, N(), N_PRIME())
            }

            /// @notice Decodes a field element out of the Montgomery form using the Montgomery reduction algorithm (REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithm for further details on transforming a field element out of the Montgomery form.
            /// @param m The field element in Montgomery form to decode.
            /// @return ret The decoded field element.
            function outOfMontgomeryFormP(m) -> ret {
                let higher_half_of_m := 0
                let lowest_half_of_m := m 
                ret := REDC(lowest_half_of_m, higher_half_of_m, P(), P_PRIME())
            }

            function outOfMontgomeryFormN(m) -> ret {
                let higher_half_of_m := 0
                let lowest_half_of_m := m 
                ret := REDC(lowest_half_of_m, higher_half_of_m, N(), N_PRIME())
            }

            /// @notice Computes the Montgomery addition.
            /// @param augend The augend in Montgomery form.
            /// @param addend The addend in Montgomery form.
            /// @return ret The result of the Montgomery addition.
            function montgomeryAddP(augend, addend) -> ret {
                ret := addmod(augend, addend, P())
            }

            /// @notice Computes the Montgomery subtraction.
            /// @param minuend The minuend in Montgomery form.
            /// @param subtrahend The subtrahend in Montgomery form.
            /// @return ret The result of the Montgomery subtraction.
            function montgomerySubP(minuend, subtrahend) -> ret {
                ret := montgomeryAddP(minuend, sub(P(), subtrahend))
            }

            /// @notice Computes the Montgomery multiplication using the Montgomery reduction algorithm (REDC).
            /// @dev See https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithm for further details on the Montgomery multiplication.
            /// @param multiplicand The multiplicand in Montgomery form.
            /// @param multiplier The multiplier in Montgomery form.
            /// @return ret The result of the Montgomery multiplication.
            function montgomeryMulP(multiplicand, multiplier) -> ret {
                let higher_half_of_product := getHighestHalfOfMultiplication(multiplicand, multiplier)
                let lowest_half_of_product := mul(multiplicand, multiplier)
                ret := REDC(lowest_half_of_product, higher_half_of_product, P(), P_PRIME())
            }

            function montgomeryMulN(multiplicand, multiplier) -> ret {
                let higher_half_of_product := getHighestHalfOfMultiplication(multiplicand, multiplier)
                let lowest_half_of_product := mul(multiplicand, multiplier)
                ret := REDC(lowest_half_of_product, higher_half_of_product, N(), N_PRIME())
            }

            /// @notice Computes the Montgomery modular inverse skipping the Montgomery reduction step.
            /// @dev The Montgomery reduction step is skept because a modification in the binary extended Euclidean algorithm is used to compute the modular inverse.
            /// @dev See the function `binaryExtendedEuclideanAlgorithm` for further details.
            /// @param a The field element in Montgomery form to compute the modular inverse of.
            /// @return invmod The result of the Montgomery modular inverse (in Montgomery form).
            function montgomeryModularInverse(a, n, r2) -> invmod {
                invmod := binaryExtendedEuclideanAlgorithm(a, n, r2)
            }

            // CURVE ARITHMETICS

            /// @notice Checks if a field element is on the curve group order.
            /// @dev A field element is on the curve group order if it is on the range [0, curveGroupOrder).
            /// @param felt The field element to check.
            /// @return ret True if the field element is in the range, false otherwise.
            function fieldElementIsOnFieldOrder(felt) -> ret {
                ret := lt(felt, P())
            }

            /// @notice Checks if affine coordinates are on the curve group order.
            /// @dev Affine coordinates are on the curve group order if both coordinates are on the range [0, curveGroupOrder).
            /// @param xp The x coordinate of the point P to check.
            /// @param yp The y coordinate of the point P to check.
            /// @return ret True if the coordinates are in the range, false otherwise.
            function affinePointCoordinatesAreOnFieldOrder(xp, yp) -> ret {
                ret := and(fieldElementIsOnFieldOrder(xp), fieldElementIsOnFieldOrder(yp))
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
                let left := montgomeryMulP(yp, yp)
                let right := montgomeryAddP(montgomeryMulP(xp, montgomeryMulP(xp, xp)), montgomeryAddP(montgomeryMulP(MONTGOMERY_A_P(), xp), MONTGOMERY_B_P()))
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
                zr := MONTGOMERY_ONE_P()
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
                    let zp_inv := montgomeryModularInverse(zp, P(), R2_MOD_P())
                    xr := montgomeryMulP(xp, zp_inv)
                    yr := montgomeryMulP(yp, zp_inv)
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
                let x_squared := montgomeryMulP(xp, xp)
                let z_squared := montgomeryMulP(zp, zp)
                let az_squared := montgomeryMulP(MONTGOMERY_A_P(), z_squared)
                let t := montgomeryAddP(montgomeryAddP(x_squared, montgomeryAddP(x_squared, x_squared)), az_squared)
                let yz := montgomeryMulP(yp, zp)
                let u := montgomeryAddP(yz, yz)
                let uxy := montgomeryMulP(u, montgomeryMulP(xp, yp))
                let v := montgomeryAddP(uxy, uxy)
                let w := montgomerySubP(montgomeryMulP(t, t), montgomeryAddP(v, v))

                xr := montgomeryMulP(u, w)
                let uy := montgomeryMulP(u, yp)
                let uy_squared := montgomeryMulP(uy, uy)
                yr := montgomerySubP(montgomeryMulP(t, montgomerySubP(v, w)), montgomeryAddP(uy_squared, uy_squared))
                zr := montgomeryMulP(u, montgomeryMulP(u, u))
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
                let flag := 1
                let qIsInfinity := projectivePointIsInfinity(xq, yq, zq)
                let pIsInfinity := projectivePointIsInfinity(xp, yp, zp)
                if and(pIsInfinity, qIsInfinity) {
                    // Infinity + Infinity = Infinity
                    xr := 0
                    yr := MONTGOMERY_ONE_P()
                    zr := 0
                    flag := 0
                }
                if and(flag, pIsInfinity) {
                    // Infinity + P = P
                    xr := xq
                    yr := yq
                    zr := zq
                    flag := 0
                }
                if and(flag, qIsInfinity) {
                    // P + Infinity = P
                    xr := xp
                    yr := yp
                    zr := zp
                    flag := 0
                }
                if and(flag, and(and(eq(xp, xq), eq(montgomerySubP(0, yp), yq)), eq(zp, zq))) {
                    // P + (-P) = Infinity
                    xr := 0
                    yr := MONTGOMERY_ONE_P()
                    zr := 0
                    flag := 0
                }
                if and(flag, and(and(eq(xp, xq), eq(yp, yq)), eq(zp, zq))) {
                    // P + P = 2P
                    xr, yr, zr := projectiveDouble(xp, yp, zp)
                    flag := 0
                }

                // P1 + P2 = P3
                if flag {
                    let t0 := montgomeryMulP(yq, zp)
                    let t1 := montgomeryMulP(yp, zq)
                    let t := montgomerySubP(t0, t1)
                    let u0 := montgomeryMulP(xq, zp)
                    let u1 := montgomeryMulP(xp, zq)
                    let u := montgomerySubP(u0, u1)
                    let u2 := montgomeryMulP(u, u)
                    let u3 := montgomeryMulP(u2, u)
                    let v := montgomeryMulP(zq, zp)
                    let w := montgomerySubP(montgomeryMulP(montgomeryMulP(t, t), v), montgomeryMulP(u2, montgomeryAddP(u0, u1)))
    
                    xr := montgomeryMulP(u, w)
                    yr := montgomerySubP(montgomeryMulP(t, montgomerySubP(montgomeryMulP(u0, u2), w)), montgomeryMulP(t0, u3))
                    zr := montgomeryMulP(u3, v)
                }
            }

            function projectiveScalarMul(xp, yp, zp, scalar) -> xr, yr, zr {
                switch eq(scalar, 2)
                case 0 {
                    let xq := xp
                    let yq := yp
                    let zq := zp
                    xr := 0
                    yr := MONTGOMERY_ONE_P()
                    zr := 0
                    for {} scalar {} {
                        if lsbIsOne(scalar) {
                            xr, yr, zr := projectiveAdd(xr, yr, zr, xq, yq, zq)
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

            // Fallback
            let a := 0x129321
            let am := intoMontgomeryForm(a, P(), P_PRIME(), R2_MOD_P())
            let am_inv := montgomeryModularInverse(am, P(), R2_MOD_P())
            let one_m := montgomeryMulP(am, am_inv)

            let hash := calldataload(0)
            let r := calldataload(32)
            let s := calldataload(64)
            let x := calldataload(96)
            let y := calldataload(128)

            if or(iszero(fieldElementIsOnFieldOrder(r)), iszero(fieldElementIsOnFieldOrder(s))) {
                burnGas()
            }

            if or(affinePointIsInfinity(x, y), iszero(affinePointCoordinatesAreOnFieldOrder(x, y))) {
                burnGas()
            }

            x := intoMontgomeryForm(x, P(), P_PRIME(), R2_MOD_P())
            y := intoMontgomeryForm(y, P(), P_PRIME(), R2_MOD_P())

            if iszero(affinePointIsOnCurve(x, y)) {
                burnGas()
            }

            let z
            x, y, z := projectiveFromAffine(x, y)

            // TODO: Check if r, s, s1, t0 and t1 operations are optimal in Montgomery form or not

            hash := intoMontgomeryForm(hash, N(), N_PRIME(), R2_MOD_N())
            r := intoMontgomeryForm(r, N(), N_PRIME(), R2_MOD_N())
            s := intoMontgomeryForm(s, N(), N_PRIME(), R2_MOD_N())

            let s1 := montgomeryModularInverse(s, N(), R2_MOD_N())
            let result := outOfMontgomeryFormN(montgomeryMulN(s, s1))

            let t0 := outOfMontgomeryFormN(montgomeryMulN(hash, s1))
            let t1 := outOfMontgomeryFormN(montgomeryMulN(r, s1))

            let gx, gy, gz := MONTGOMERY_PROJECTIVE_G_P()

            // TODO: Implement Shamir's trick for adding to scalar multiplications faster.
            let xp, yp, zp := projectiveScalarMul(gx, gy, gz, t0)
            let xq, yq, zq := projectiveScalarMul(x, y, z, t1)
            let xr, yr, zr := projectiveAdd(xp, yp, zp, xq, yq, zq)

            // As we only need xr in affine form, we can skip transforming the `y` coordinate.
            xr := montgomeryMulP(xr, montgomeryModularInverse(zr, P(), R2_MOD_P()))
            xr := outOfMontgomeryFormP(xr)
            r := outOfMontgomeryFormN(r)

            xr := mod(xr, N())
            r := mod(r, N())

            mstore(0, eq(xr, r))
            return(0, 32)
        }
    }
}
