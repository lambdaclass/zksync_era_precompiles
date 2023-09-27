object "ModExp" {
	code { }
	object "ModExp_deployed" {
		code {
            // CONSTANTS

            function LIMB_SIZE_IN_BYTES() -> limbSize {
                limbSize := 0x20
            }

            function LIMB_SIZE_IN_BITS() -> limbSize {
                limbSize := 0x100
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

            // HELPER FUNCTIONS

            /// @notice Computes an addition and checks for overflow.
            /// @param augend The value to add to.
            /// @param addend The value to add.
            /// @return sum The sum of the two values.
            /// @return overflowed True if the addition overflowed, false otherwise.
            function overflowingAdd(augend, addend) -> sum, overflowed {
                sum := add(augend, addend)
                overflowed := lt(sum, augend)
            }

            /// @notice Checks whether a big number is zero.
            /// @param start The pointer to the calldata where the big number starts.
            /// @param len The number of bytes that the big number occupies.
            /// @return res A boolean indicating whether the big number is zero (true) or not (false).
            function bigNumberIsZero(start, len) -> res {
                // Initialize result as true, assuming the number is zero until proven otherwise.
                res := true

                // Calculate the ending pointer of the big number in memory.
                let end := add(start, len)
                // Calculate the number of bytes in the last (potentially partial) word of the big number.
                let lastWordBytes := mod(len, 32)
                // Calculate the ending pointer of the last full 32-byte word.
                let endOfLastFullWord := sub(end, lastWordBytes)

                // Loop through each full 32-byte word to check for non-zero bytes.
                for { let ptr := start } lt(ptr, endOfLastFullWord) { ptr := add(ptr, 32) } {
                    let word := calldataload(ptr)
                    if word {
                        res := false
                        break
                    }
                }

                // Check if the last partial word has any non-zero bytes.
                if lastWordBytes {
                    // Create a mask that isolates the valid bytes in the last word.
                    // The mask has its first `lastWordBytes` bytes set to `0xff`.
                    let mask := sub(shl(mul(lastWordBytes, 8), 1), 1)
                    let word := calldataload(endOfLastFullWord)
                    // Use the mask to isolate the valid bytes and check if any are non-zero.
                    if and(word, mask) {
                        res := false
                    }
                }
            }

            /// @param start1 - The start index in memory of the first number.
            /// @param numberOfLimbs1 - The number of limbs in the first number.
            /// @param start2 - The start index in memory of the second number.
            /// @param numberOfLimbs2 - The number of limbs in the second number.
            function bigNumberMultiplication(start1, start2, nLimbs, resStart) {
                // TODO: allocate retStart and retLen
                // Iterating over each limb in the first number.
                let retIndex, retWordAfter, retWordBefore
                for { let i := nLimbs } gt(i, 0) { i := sub(i, 1) } {
                    // Initialize carry to 0 for each iteration of i.
                    let carry := 0

                    // Iterating over each limb in the second number.
                    for { let j := nLimbs } gt(j, 0) { j := sub(j, 1) } {
                        // Loading the i-th and j-th limbs of the first and second numbers.
                        let word1 := mload(add(start1, mul(WORD_SIZE(), sub(i, 1))))
                        let word2 := mload(add(start2, mul(WORD_SIZE(), sub(j, 1))))

                        // Calculating the product of the two limbs and adding the carry.
                        let product, carryFlag := overflowingAdd(mul(word1, word2), carry)

                        // Calculating the new carry.
                        carry := add(getHighestHalfOfMultiplication(word1, word2), carryFlag)

                        // Calculate the index to store the result.
                        retIndex := add(resStart, mul(sub(add(i, j), 1), WORD_SIZE()))
                        retWordBefore := mload(retIndex) // Load the previous value at the result index.
                        retWordAfter, carryFlag := overflowingAdd(retWordBefore, product) // Add the product to the result.

                        console_log(retIndex)
                        console_log(retWordAfter)
                        // Store the new result back to memory.
                        mstore(retIndex, retWordAfter)

                        // Adding to the carry if there was an overflow.
                        carry := add(carry, carryFlag)
                    }

                    // Store the last word which comes from the final carry.
                    retIndex := add(resStart, mul(sub(i, 1), WORD_SIZE()))
                    mstore(retIndex, carry)
                }
            }

            /// @notice Checks whether a big number is one.
            /// @param start The pointer to the calldata where the big number starts.
            /// @param len The number of bytes that the big number occupies.
            /// @return res A boolean indicating whether the big number is one (true) or not (false).
            function bigNumberIsOne(start, len) -> res {
                if len {
                    let lastBytePtr := sub(add(start, len), 1)
                    let lastByte := byte(0, calldataload(lastBytePtr))

                    // Check if the last byte is one.
                    let lastByteIsOne := eq(lastByte, 1)
                    // Check if all other bytes are zero using the bigNumberIsZero function
                    // The length for this check is (len - 1) because we exclude the last byte.
                    let otherBytesAreZeroes := bigNumberIsZero(start, sub(len, 1))

                    // The number is one if the last byte is one and all other bytes are zero.
                    res := and(lastByteIsOne, otherBytesAreZeroes)
                }
            }

            /// @notice Performs the Big UInt Conditional Select operation.
            /// @dev The result is stored from `resPtr` to `resPtr + (LIMB_SIZE * nLimbs)`.
            /// @dev For each limb, `res[i] == lhs[i] ^ (mask & (lhs[i] ^ rhs[i]))`
            /// @param lhsPtr Base pointer to the left hand side operand.
            /// @param rhsPtr Base pointer to the right hand side operand.
            /// @param resPtr Base pointer to where you want the result to be stored
            /// @param nLimbs The number of limbs needed to represent all of the operands.
            /// @param mask Either `0x0` or `0xFF...FF`.
            function bigUIntCondSelect(lhsPtr, rhsPtr, resPtr, nLimbs, mask) {
                let finalOffset := shl(5, nLimbs) // == ( LIMB_SIZE * nLimbs ) == (32 * nLimbs)
                for { let offset_i := 0 } lt(offset_i, finalOffset) { offset_i := add(offset_i, 0x20) }
                {
                    let ptr_lhs_i := add(lhsPtr, offset_i)
                    let ptr_rhs_i := add(rhsPtr, offset_i)
                    let ptr_res_i := add(resPtr, offset_i)
                    let value_lhs_i := mload(ptr_lhs_i)
                    let value_rhs_i := mload(ptr_rhs_i)
                    let value_res_i := xor(value_lhs_i, and(mask, xor(value_lhs_i, value_rhs_i))) // a ^ (ct & (a ^ b))
                    mstore(ptr_res_i, value_res_i)
                }
            }

            /// @notice Performs the big unsigned integer bit or operation.
            /// @dev The result is stored from `resPtr` to `resPtr + (LIMB_SIZE * nLimbs)`.
            /// @param lhsPtr The pointer to the MSB of the left operand.
            /// @param rhsPtr The pointer to the MSB of the right operand.
            /// @param nLimbs The number of limbs needed to represent the operands.
            /// @param resPtr The pointer to where you want the result to be stored
            function bigUIntBitOr(lhsPtr, rhsPtr, nLimbs, resPtr) {
                // +------------+-----------------------+-------------------------------+-------------------------------+-------------------------------+-----------------+-----------------+--------------------------------------+
                // | Iteration  |       offset_i        |           ptr_lhs_i           |           ptr_rhs_i           |           ptr_res_i           |   value_lhs_i   |   value_rhs_i   |             value_res_i              |
                // +------------+-----------------------+-------------------------------+-------------------------------+-------------------------------+-----------------+-----------------+--------------------------------------+
                // | 0          | +0x00                 | lhsPtr + 0x00                 | rhsPtr + 0x00                 | resPtr + 0x00                 | lhs[0]          | rhs[0]          | or(lhs[0], rhs[0])                   |
                // | 1          | +0x20                 | lhsPtr + 0x20                 | rhsPtr + 0x20                 | resPtr + 0x20                 | lhs[1]          | rhs[1]          | or(lhs[1], rhs[1])                   |
                // | 2          | +0x40                 | lhsPtr + 0x40                 | rhsPtr + 0x40                 | resPtr + 0x40                 | lhs[2]          | rhs[2]          | or(lhs[2], rhs[2])                   |
                // |            |                       |                               |                               |                               |                 |                 |                                      |
                // | ...        | ...                   | ...                           | ...                           | ...                           | ...             | ...             | ...                                  |
                // |            |                       |                               |                               |                               |                 |                 |                                      |
                // | nLimbs - 1 | +(0x20 * (nLimbs - 1) | lhsPtr + (0x20 * (nLimbs - 1) | rhsPtr + (0x20 * (nLimbs - 1) | resPtr + (0x20 * (nLimbs - 1) | lhs[nLimbs - 1] | rhs[nLimbs - 1] | or(lhs[nLimbs - 1], rhs[nLimbs - 1]) |
                // +------------+-----------------------+-------------------------------+-------------------------------+-------------------------------+-----------------+-----------------+--------------------------------------+

                let finalOffset := shl(5, nLimbs) // == ( LIMB_SIZE * nLimbs ) == (32 * nLimbs) 
                for { let offset_i := 0 } lt(offset_i, finalOffset) { offset_i := add(offset_i, 0x20) }
                {
                    let ptr_lhs_i := add(lhsPtr, offset_i)
                    let ptr_rhs_i := add(rhsPtr, offset_i)
                    let ptr_res_i := add(resPtr, offset_i)
                    let value_lhs_i := mload(ptr_lhs_i)
                    let value_rhs_i := mload(ptr_rhs_i)
                    let value_res_i := or(value_lhs_i, value_rhs_i)
                    mstore(ptr_res_i, value_res_i)
                }
            }

            /// @notice Performs the big unsigned integer right shift (>>).
            /// @dev The result is stored from `shiftedPtr` to `shiftedPtr + (WORD_SIZE * nLimbs)`.
            /// @param numberPtr The pointer to the MSB of the number to shift.
            /// @param nLimbs The number of limbs needed to represent the operands.
            /// @param shiftedPtr The pointer to the MSB of the shifted number.
            function bigUIntShr(times, numberPtr, nLimbs, shiftedPtr) {
                switch times
                case 0 {
                    // If the pointers are different and the amount of bits to shift is zero, 
                    // then we copy the number, otherwise, we do nothing.
                    if iszero(eq(numberPtr, shiftedPtr)) {
                        let currentLimbPtr := numberPtr
                        let currentShiftedLimbPtr := shiftedPtr
                        for { let i := 0 } lt(i, nLimbs) { i := add(i, 1) } {
                            mstore(currentShiftedLimbPtr, mload(currentLimbPtr))
                            currentShiftedLimbPtr := add(currentShiftedLimbPtr, LIMB_SIZE_IN_BYTES())
                            currentLimbPtr := add(currentLimbPtr, LIMB_SIZE_IN_BYTES())
                        }
                    }
                }
                default {
                    let effectiveShifts := mod(times, LIMB_SIZE_IN_BITS())
                    let b_inv := sub(LIMB_SIZE_IN_BITS(), effectiveShifts)
                    let limbsToShiftOut := div(times, LIMB_SIZE_IN_BITS())
                    let shiftDivInv := sub(LIMB_SIZE_IN_BITS(), limbsToShiftOut)

                    switch iszero(effectiveShifts)
                    case 1 {
                        // When numberPtr could be equal to shiftedPtr that means that the result
                        // will be stored in the same pointer as the value to shift. To avoid
                        // overlaping, as this is a right shift we read and store from right to
                        // left.

                        // currentLimbPtrOffset is the value that added to numberPtr pointer gives 
                        // us the pointer to what is the rightmost limb of the result. From there 
                        // we move through the limbs from left to right (subtracting).
                        let currentLimbPtrOffset := mul(sub(nLimbs, add(limbsToShiftOut, 1)), LIMB_SIZE_IN_BYTES())
                        let currentLimbPtr := add(numberPtr, currentLimbPtrOffset)
                        // currentShiftedLimbPtrOffset is the value that added to shiftedPtr gives
                        // us the pointer to the less significant limb of the result.
                        let currentShiftedLimbPtrOffset := mul(sub(nLimbs, 1), LIMB_SIZE_IN_BYTES())
                        let currentShiftedLimbPtr := add(shiftedPtr, currentShiftedLimbPtrOffset)
                        for { let i := limbsToShiftOut } lt(i, nLimbs) { i := add(i, 1) } {
                            mstore(currentShiftedLimbPtr, mload(currentLimbPtr))
                            currentLimbPtr := sub(currentLimbPtr, LIMB_SIZE_IN_BYTES())
                            currentShiftedLimbPtr := sub(currentShiftedLimbPtr, LIMB_SIZE_IN_BYTES())
                        }
                        // Fill with zeros the limbs that will shifted out limbs.
                        // We need to fill the zeros after in the edge case that numberPtr == shiftedPtr. 
                        currentShiftedLimbPtr := shiftedPtr
                        for { let i := 0 } lt(i, limbsToShiftOut) { i := add(i, 1) } {
                            mstore(currentShiftedLimbPtr, 0)
                            currentShiftedLimbPtr := add(currentShiftedLimbPtr, LIMB_SIZE_IN_BYTES())
                        }
                    }
                    default {
                        // When there are effectiveShifts we need to do a bit more of work.
                        // We go from right to left, shifting the current limb and adding the
                        // previous one shifted to the left by b_inv bits.

                        // currentLimbPtrOffset is the value that added to numberPtr pointer gives 
                        // us the pointer to what is the rightmost limb of the result. From there 
                        // we move through the limbs from right to left (subtracting).
                        let currentLimbPtrOffset := mul(sub(nLimbs, add(limbsToShiftOut, 1)), LIMB_SIZE_IN_BYTES())
                        let currentLimbPtr := add(numberPtr, currentLimbPtrOffset)
                        let previousLimbPtr := sub(currentLimbPtr, LIMB_SIZE_IN_BYTES())
                        // currentShiftedLimbPtrOffset is the value that added to shiftedPtr gives
                        // us the pointer to the less significant limb of the result.
                        let currentShiftedLimbPtrOffset := mul(sub(nLimbs, 1), LIMB_SIZE_IN_BYTES())
                        let currentShiftedLimbPtr := add(shiftedPtr, currentShiftedLimbPtrOffset)
                        for { let i := add(limbsToShiftOut, 1) } lt(i, nLimbs) { i := add(i, 1) } {
                            let shiftedLimb := or(shl(b_inv, mload(previousLimbPtr)), shr(effectiveShifts, mload(currentLimbPtr)))
                            mstore(currentShiftedLimbPtr, shiftedLimb)
                            previousLimbPtr := sub(previousLimbPtr, LIMB_SIZE_IN_BYTES())
                            currentLimbPtr := sub(currentLimbPtr, LIMB_SIZE_IN_BYTES())
                            currentShiftedLimbPtr := sub(currentShiftedLimbPtr, LIMB_SIZE_IN_BYTES())
                        }
                        // Fill with zeros the limbs that will shifted out limbs.
                        // We need to fill the zeros after in the edge case that numberPtr == shiftedPtr. 
                        currentShiftedLimbPtr := shiftedPtr
                        for { let i := 0 } lt(i, limbsToShiftOut) { i := add(i, 1) } {
                            mstore(currentShiftedLimbPtr, 0)
                            currentShiftedLimbPtr := add(currentShiftedLimbPtr, LIMB_SIZE_IN_BYTES())
                        }
                        // Finally the non-zero MSB limb.
                        mstore(currentShiftedLimbPtr, shr(effectiveShifts, mload(currentShiftedLimbPtr)))
                    }
                }
            }

            /// @notice Performs the big unsigned integer left shift (<<).
            /// @dev The result is stored from `shiftedPtr` to `shiftedPtr + (LIMB_SIZE_IN_BYTES * nLimbs)`.
            /// @param numberPtr The pointer to the MSB of the number to shift.
            /// @param nLimbs The number of limbs needed to represent the operands.
            /// @param shiftedPtr The pointer to the MSB of the shifted number.
            function bigUIntShl(times, numberPtr, nLimbs, shiftedPtr) {
                switch times
                case 0 {
                    // If the pointers are different and the amount of bits to shift is zero, 
                    // then we copy the number, otherwise, we do nothing.
                    if iszero(eq(numberPtr, shiftedPtr)) {
                        let currentLimbPtr := numberPtr
                        let currentShiftedLimbPtr := shiftedPtr
                        for { let i := 0 } lt(i, nLimbs) { i := add(i, 1) } {
                            mstore(currentShiftedLimbPtr, mload(currentLimbPtr))
                            currentShiftedLimbPtr := add(currentShiftedLimbPtr, LIMB_SIZE_IN_BYTES())
                            currentLimbPtr := add(currentLimbPtr, LIMB_SIZE_IN_BYTES())
                        }
                    }
                }
                default {
                    let effectiveShifts := mod(times, LIMB_SIZE_IN_BITS())
                    let b_inv := sub(LIMB_SIZE_IN_BITS(), effectiveShifts)
                    let limbsToShiftOut := div(times, LIMB_SIZE_IN_BITS())
                    let shiftDivInv := sub(LIMB_SIZE_IN_BITS(), limbsToShiftOut)
                    
                    switch iszero(effectiveShifts)
                    case 1 {
                        // When numberPtr could be equal to shiftedPtr that means that the result
                        // will be stored in the same pointer as the value to shift. To avoid
                        // overlaping, as this is a left shift we read and store from left to
                        // right.

                        let currentLimbPtrOffset := mul(limbsToShiftOut, LIMB_SIZE_IN_BYTES())
                        let currentLimbPtr := add(numberPtr, currentLimbPtrOffset)
                        let currentShiftedLimbPtr := shiftedPtr
                        for { let i := limbsToShiftOut } lt(i, nLimbs) { i := add(i, 1) } {
                            mstore(currentShiftedLimbPtr, mload(currentLimbPtr))
                            currentLimbPtr := add(currentLimbPtr, LIMB_SIZE_IN_BYTES())
                            currentShiftedLimbPtr := add(currentShiftedLimbPtr, LIMB_SIZE_IN_BYTES())
                        }
                        // Fill with zeros the limbs that will shifted out limbs.
                        // We need to fill the zeros after in the edge case that numberPtr == shiftedPtr. 
                        for { let i := 0 } lt(i, limbsToShiftOut) { i := add(i, 1) } {
                            mstore(currentShiftedLimbPtr, 0)
                            currentShiftedLimbPtr := add(currentShiftedLimbPtr, LIMB_SIZE_IN_BYTES())
                        }
                    }
                    default {
                        // When there are effectiveShifts we need to do a bit more of work.
                        // We go from right to left, shifting the current limb and adding the
                        // previous one shifted to the left by b_inv bits.
                        let currentLimbPtrOffset := mul(limbsToShiftOut, LIMB_SIZE_IN_BYTES())
                        let currentLimbPtr := add(numberPtr, currentLimbPtrOffset)
                        let nextLimbPtr := add(currentLimbPtr, LIMB_SIZE_IN_BYTES())
                        let currentShiftedLimbPtr := shiftedPtr
                        for { let i := limbsToShiftOut } lt(i, nLimbs) { i := add(i, 1) } {
                            let shiftedLimb := or(shr(b_inv, mload(nextLimbPtr)), shl(effectiveShifts, mload(currentLimbPtr)))
                            mstore(currentShiftedLimbPtr, shiftedLimb)
                            nextLimbPtr := add(nextLimbPtr, LIMB_SIZE_IN_BYTES())
                            currentLimbPtr := add(currentLimbPtr, LIMB_SIZE_IN_BYTES())
                            currentShiftedLimbPtr := add(currentShiftedLimbPtr, LIMB_SIZE_IN_BYTES())
                        }
                        // Finally the non-zero LSB limb.
                        mstore(currentShiftedLimbPtr, shl(effectiveShifts, mload(currentShiftedLimbPtr)))
                        currentShiftedLimbPtr := add(currentShiftedLimbPtr, LIMB_SIZE_IN_BYTES())
                        // Fill with zeros the shifted in limbs.
                        for { let i := 0 } lt(i, limbsToShiftOut) { i := add(i, 1) } {
                            mstore(currentShiftedLimbPtr, 0)
                            currentShiftedLimbPtr := add(currentShiftedLimbPtr, LIMB_SIZE_IN_BYTES())
                        }
                    }
                }
            }

            /// @notice Add two big numbers.
            /// @param lhsPtr The pointer where the big number on the left operand starts.
            /// @param rhsPtr The pointer where the big number on right operand starts.
            /// @param nLimbs The number of 32-byte words that the big numbers occupy.
            /// @param resPtr The pointer where the result of the addition will be stored.
            /// @return isOverflow A boolean indicating whether the addition overflowed (true) or not (false).
            function bigUIntAdd(lhsPtr, rhsPtr, nLimbs, resPtr) -> isOverflow {
                let totalLength := mul(nLimbs, LIMB_SIZE_IN_BYTES())
                let carry := 0

                let lhsCurrentLimbPtr := add(lhsPtr, totalLength)
                let rhsCurrentLimbPtr := add(rhsPtr, totalLength)

                // Loop through each full 32-byte word to add the two big numbers.
                for {let i := 1 } or(eq(i,nLimbs), lt(i, nLimbs)) { i := add(i, 1) } {
                    // Check limb from the right (least significant limb)
                    let actualLimbOffset := mul(LIMB_SIZE_IN_BYTES(), i)
                    lhsCurrentLimbPtr := sub(lhsCurrentLimbPtr, actualLimbOffset)
                    rhsCurrentLimbPtr := sub(rhsCurrentLimbPtr, actualLimbOffset)
                    
                    let rhsLimb := mload(rhsCurrentLimbPtr)
                    let lhsLimb := mload(lhsCurrentLimbPtr)
                    let sumResult, overflow := overflowingAdd(lhsLimb, rhsLimb)
                    let sumWithPreviousCarry, carrySumOverflow := overflowingAdd(sumResult, carry)
                    sumResult := sumWithPreviousCarry
                    carry := or(overflow, carrySumOverflow)
                    let limbResultPtr := sub(add(resPtr,totalLength),actualLimbOffset)
                    mstore(limbResultPtr, sumResult)
                }
                isOverflow := carry

            }

            ////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////
            
            // 5e2d939b602a50911232731d04fe6f40c05f97da0602307
            // 099fb991f9b414e2d52bef130349ec18db1a0215ea6caf76

            // 3f3ad1611ab58212f92a2484e9560935b9ac4615fe61cfe
            // d1a4861e193a74d20c94f9f88d8b2cc089543c3f699969d9
            mstore(0x00, 0x5e2d939b602a50911232731d04fe6f4)
            mstore(0x20, 0x0c05f97da0602307099fb991f9b414e2d52bef130349ec18db1a0215ea6caf76)
            mstore(0x40, 0x0c05f97da0602307099fb991f9b414e2d52bef130349ec18db1a0215ea6caf76)

            mstore(0x60, 0x3f3ad1611ab58212f92a2484e956093)
            mstore(0x80, 0x5b9ac4615fe61cfed1a4861e193a74d20c94f9f88d8b2cc089543c3f699969d9)
            mstore(0xa0,0x5b9ac4615fe61cfed1a4861e193a74d20c94f9f88d8b2cc089543c3f699969d9)

            let retStart := 0x120
            bigNumberMultiplication(0x00, 0x60, 3, retStart)
            let res := mload(retStart)
            let res2 := mload(add(retStart, 0x20))
            let res3 := mload(add(retStart, 0x40))
            let res4 := mload(add(retStart, 0x60))
            let res5 := mload(add(retStart, 0x80))
            let res6 := mload(add(retStart, 0xa0))

            console_log(res)
            console_log(res2)
            console_log(res3)
            console_log(res4)
            console_log(res5)
            console_log(res6)

            // TODO: big arithmetics
        }
	}
}
