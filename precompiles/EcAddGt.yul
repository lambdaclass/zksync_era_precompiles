object "EcAddGt" {
    code { }
    object "EcAddGt_deployed" {
        code {
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

            /// @notice Checks if a Gt point in affine coordinates is the point at infinity.
            /// @dev The coordinates are encoded in Montgomery form.
            /// @dev in Affine coordinates the point represents the infinity if both coordinates are 0.
            /// @param x0, x1 The x coordinate to check.
            /// @param y0, y1 The y coordinate to check.
            /// @return ret True if the point is the point at infinity, false otherwise.
            function gtAffinePointIsInfinity(a000, a001, a010, a011, a020, a021, a100, a101, a110, a111, a120, a121) -> ret {
                ret := iszero(or(or(or(or(a000, a001), or(a010, a011)), or(or(a020, a021), or(a100, a101), or(or(a110, a111), or(a120, a121)))
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

            // FP12 ARITHMETHICS

            /// @notice Computes the sum of two Fp12 elements.
            /// @dev Algorithm 18 in: https://eprint.iacr.org/2010/354.pdf.
            /// @param a000, a001, a010, a011, a020, a021, a100, a101, a110, a111, a120, a121 The coefficients of the A element to sum.
            /// @param b000, b001, b010, b011, b020, b021, b100, b101, b110, b111, b120, b121 The coefficients of the B element to sum.
            /// @return c000, c001, c010, c011, c020, c021, c100, c101, c110, c111, c120, c121 The coefficients of the element C = A + B.
            function fp12Add(a000, a001, a010, a011, a020, a021, a100, a101, a110, a111, a120, a121, b000, b001, b010, b011, b020, b021, b100, b101, b110, b111, b120, b121) -> c000, c001, c010, c011, c020, c021, c100, c101, c110, c111, c120, c121 {
                c000, c001, c010, c011, c020, c021 := fp6Add(a000, a001, a010, a011, a020, a021, b000, b001, b010, b011, b020, b021)
                c100, c101, c110, c111, c120, c121 := fp6Add(a100, a101, a110, a111, a120, a121, b100, b101, b110, b111, b120, b121)
            }

            ////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////

            // Retrieve the coordinates from the calldata
            let a000 := calldataload(0)
            let a001 := calldataload(32)
            let a010 := calldataload(64)
            let a011 := calldataload(96)
            let a011 := calldataload(128)
            let a020 := calldataload(160)
            let a021 := calldataload(224)
            let a020 := calldataload(256)
            let a100 := calldataload(288)
            let a101 := calldataload(320)
            let a110 := calldataload(352)
            let a111 := calldataload(384)
            let a120 := calldataload(416)
            let a121 := calldataload(448)

            let b000 := calldataload(480)
            let b001 := calldataload(512)
            let b010 := calldataload(544)
            let b011 := calldataload(576)
            let b011 := calldataload(608)
            let b020 := calldataload(640)
            let b021 := calldataload(672)
            let b020 := calldataload(704)
            let b100 := calldataload(736)
            let b101 := calldataload(768)
            let b110 := calldataload(800)
            let b111 := calldataload(832)
            let b120 := calldataload(864)
            let b121 := calldataload(896)

            let aIsInfinity := isInfinity(x1, y1)
            let p2IsInfinity := isInfinity(x2, y2)

            return(0, 64)
        }
    }
}