object "Playground" {
	code { }
	object "Playground_deployed" {
		code {
            function console_log(val) -> {
                let log_address := 0x000000000000000000636F6e736F6c652e6c6f67
                // A big memory address to store the function selector.
                let freeMemPointer := 0x400
                // store the function selector of log(uint256) in memory
                mstore(freeMemPointer, 0xf82c50f1) // mem[0] = 0xf8...
                // store the first argument of log(uint256) in the next memory slot
                mstore(add(freeMemPointer, 0x20), val)
                // call the console.log contract
                if iszero(staticcall(gas(),log_address,add(freeMemPointer, 28),add(freeMemPointer, 0x40),0x00,0x00)) {
                    revert(0,0)
                }
            }

            // CONSTANTS

            function LIMB_SIZE_IN_BYTES() -> limbSize {
                limbSize := 0x20
            }

            function LIMB_SIZE_IN_BITS() -> limbSize {
                limbSize := 0x100
            }

            function oneWithLimbSizeAt(limbSize, address) {
               let pointerToOne :=  address
               mstore(pointerToOne, 0x1)
               for{let i := sub(limbSize, 1)} gt(i, 0) { i := sub(i, 1)} {
                  let offset := add(mul(i, 32), pointerToOne)
                  mstore(offset, 0x0)
               }
            }

            function zeroWithLimbSizeAt(n_limbs, base_ptr) {
               for { let i := 0 } lt(i, n_limbs) { i := add(i, 1) } {
                   let offset := mul(i, 32)
                   mstore(add(base_ptr, offset), 0)
               }
            }

            function copyBigUint(limbSize, fromAddress, toAddress) -> toAddress {
               for{let i := 0} lt(i, limbSize) { i := add(i, 1)} {
                  let fromOffset := add(mul(i, 32), fromAddress)
                  let toOffset := add(mul(i, 32), toAddress)
                  mstore(toOffset, mload(fromOffset))
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

            /// @notice Retrieves the highest half of the multiplication result.
            /// @param multiplicand The value to multiply.
            /// @param multiplier The multiplier.
            /// @return ret The highest half of the multiplication result.
            function getHighestHalfOfMultiplication(multiplicand, multiplier) -> ret {
                ret := verbatim_2i_1o("mul_high", multiplicand, multiplier)
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

            function getLimbValueAtOffset(limbPointer, anOffset) -> limbValue {
                limbValue := mload(add(anOffset, limbPointer))
            }

            function storeLimbValueAtOffset(limbPointer, anOffset, aValue) {
                    mstore(add(limbPointer, anOffset), aValue)
            }

            /// @notice Computes the difference between two 256 bit number and keeps
            /// account of the borrow bit
            /// in lshPointer and rhsPointer.
            /// @dev Reference: https://github.com/lambdaclass/lambdaworks/blob/main/math/src/unsigned_integer/element.rs#L785
            /// @param leftLimb The left side of the difference (i.e. the a in a - b).
            /// @param rightLimb The right side of the difference (i.e. the b in a - b).
            /// @return subtractionResult i.e. the c in c = a - b.
            /// @return returnBorrow If there was any borrow on the subtraction, is returned as 1.
            function subLimbsWithBorrow(leftLimb, rightLimb, limbBorrow) -> subtractionResult, returnBorrow {
                let rightPlusBorrow := add(rightLimb, limbBorrow)
                subtractionResult := sub(leftLimb, rightPlusBorrow)
                if gt(subtractionResult, leftLimb) {
                 returnBorrow := 1
                }
            }
            /// @notice Computes the BigUint subtraction between the number stored
            /// in lshPointer and rhsPointer.
            /// @dev Reference: https://github.com/lambdaclass/lambdaworks/blob/main/math/src/unsigned_integer/element.rs#L795
            /// @param lhsPointer The start of the left hand side subtraction Big Number.
            /// @param rhsPointer The start of the right hand side subtraction Big Number.
            /// @return numberOfLimbs The number of limbs of both numbers.
            /// @return resultPointer Where the result will be stored.
            function bigUintSubtractionWithBorrow(lhsPointer, rhsPointer, numberOfLimbs, resultPointer) -> resultPointer, borrow {
                let leftIthLimbValue
                let rightIthLimbValue
                let ithLimbBorrowResult
                let ithLimbSubtractionResult
                let borrow := 0
                let limbOffset := 0
                for {let i := numberOfLimbs} gt(i, 0) {i := sub(i, 1)} {
                    limbOffset := mul(sub(i,1), 32)
                    leftIthLimbValue := getLimbValueAtOffset(lhsPointer, limbOffset)
                    rightIthLimbValue := getLimbValueAtOffset(rhsPointer, limbOffset)
                    ithLimbSubtractionResult, borrow :=
                                               subLimbsWithBorrow(leftIthLimbValue, rightIthLimbValue, borrow)
                    storeLimbValueAtOffset(resultPointer, limbOffset, ithLimbSubtractionResult)

                }
            }
            /// @notice Performs the multiplication between two bigUInts
            /// @dev The result is stored from `mulResultPtr` to `mulResultPtr + (LIMB_SIZE * nLimbs)`.
            /// @param lhsPtr The start index in memory of the first number.
            /// @param rhsPtr The start index in memory of the second number.
            /// @param nLimbs The number of limbs needed to represent the operands.
            function bigUIntMul(lhsPtr, rhsPtr, nLimbs, mulResultPtr) {
                let retIndex, retWordAfter, retWordBefore
                // Iterating over each limb in the first number.
                for { let i := nLimbs } gt(i, 0) { i := sub(i, 1) } {
                    let carry := 0

                    // Iterating over each limb in the second number.
                    for { let j := nLimbs } gt(j, 0) { j := sub(j, 1) } {
                        // Loading the i-th and j-th limbs of the first and second numbers.
                        let word1 := mload(add(lhsPtr, mul(LIMB_SIZE_IN_BYTES(), sub(i, 1))))
                        let word2 := mload(add(rhsPtr, mul(LIMB_SIZE_IN_BYTES(), sub(j, 1))))

                        let product, carryFlag := overflowingAdd(mul(word1, word2), carry)
                        carry := add(getHighestHalfOfMultiplication(word1, word2), carryFlag)

                        // Calculate the index to store the product.
                        retIndex := add(mulResultPtr, mul(sub(add(i, j), 1), LIMB_SIZE_IN_BYTES()))
                        retWordBefore := mload(retIndex) // Load the previous value at the result index.
                        retWordAfter, carryFlag := overflowingAdd(retWordBefore, product)

                        mstore(retIndex, retWordAfter)
                        carry := add(carry, carryFlag)
                    }

                    // Store the last word which comes from the final carry.
                    retIndex := add(mulResultPtr, mul(sub(i, 1), LIMB_SIZE_IN_BYTES()))
                    mstore(retIndex, carry)
                }
            }

            // @notice Computes the bit size of an unsigned integer.
            // @dev Return value boundary: `0 <= bit_size <= 256`
            // @param x An unsigned integer value.
            // @return bit_size Number of bits required to represent `x`.
            function uint_bit_size(x) -> bit_size {
                // Increment bit_size until there are no significant bits left.
                bit_size := 0
                for { let shift_me := x } lt(0, shift_me) { shift_me := shr(1, shift_me) } {
                    bit_size := add(bit_size, 1)
                }
            }

            function big_uint_bit_size(base_ptr, n_limbs) -> bit_size {
                bit_size := shl(8, n_limbs)

                // Iterate until finding the most significant limb or reach
                let limb := 0
                for { let i := 0 } and(lt(i, n_limbs), iszero(limb)) { i := add(i, 1) } {
                    bit_size := sub(bit_size, 256) // Decrement one limb worth of bits.
                    let ptr_i := add(base_ptr, shl(5, i)) // = base_ptr + i * 32 bytes
                    limb := mload(ptr_i)
                }

                // At this point, `limb == limbs[i - 1]`. Where `i` equals the
                // last value it took.

                // At this point, `bit_size` equals the amount of bits in the
                // limbs following the most significant limb.

                bit_size := add(bit_size, uint_bit_size(limb))
            }

            function big_uint_inplace_or_1(base_ptr, n_limbs) {
                let offset := mul(sub(n_limbs, 1), 32)
                let limb_ptr := add(base_ptr, offset)
                let limb := mload(limb_ptr)
                mstore(limb_ptr, or(limb, 0x1))
            }

            /// @notice Performs the big unsigned integer square of big unsigned integers with an arbitrary amount of limbs.
            /// @dev The quotient is stored from `quotient_ptr` to `quotient_ptr + (WORD_SIZE * nLimbs)`.
            /// @dev The reminder is stored from `rem_ptr` to `rem_ptr + (WORD_SIZE * nLimbs)`.
            function bigUIntDivRem(dividend_ptr, divisor_ptr, n_limbs, quotient_ptr, rem_ptr) {
                copyBigUint(n_limbs, dividend_ptr, rem_ptr) // rem = dividend 

                // Init quotient to 0.
                zeroWithLimbSizeAt(n_limbs, quotient_ptr) // quotient = 0

                let mb := big_uint_bit_size(divisor_ptr, n_limbs)
                let bd := sub(mul(n_limbs, 256), mb)
                let c_ptr := 0x900 // FIXME don't use a hardcoded address!
                bigUIntShl(bd, divisor_ptr, n_limbs, c_ptr) // c == divisor << bd

                let r_ptr := 0x700 // FIXME don't use a hardcoded address!

                for { } iszero(0) { } {
                    // LAMBDAWORKS : let (mut r, borrow) = rem.sbb(&c, 0);
                    let r_ptr, borrow := bigUintSubtractionWithBorrow(rem_ptr, c_ptr, n_limbs, r_ptr)


                    // LAMBDAWORKS : rem = Self::ct_select(&r, &rem, borrow);
                    if iszero(borrow) {
                        copyBigUint(n_limbs, r_ptr, rem_ptr)
                    }

                    // LAMBDAWORKS : r = quo.bitor(Self::from_u64(1));
                    copyBigUint(n_limbs, quotient_ptr, r_ptr) // r = quotient
                    big_uint_inplace_or_1(r_ptr, n_limbs) // r = quotient | 1

                    // LAMBDAWORKS : quo = Self::ct_select(&r, &quo, borrow);
                    if iszero(borrow) {
                        copyBigUint(n_limbs, r_ptr, quotient_ptr)
                    }

                    // LAMBDAWORKS: if bd == 0 { break; }
                    if eq(bd, 0) {
                        break
                    }

                    bd := sub(bd, 1)
                    bigUIntShr(1, c_ptr, n_limbs, c_ptr) // c = c << 1
                    bigUIntShl(1, quotient_ptr, n_limbs, quotient_ptr) // quotient = quotient >> 1
                }

                // LAMBDAWORKS
                //     let is_some = Self::ct_is_nonzero(mb as u64);
                //     quo = Self::ct_select(&Self::from_u64(0), &quo, is_some);
                if iszero(mb) {
                    zeroWithLimbSizeAt(n_limbs, quotient_ptr)
                }
            }

            ////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////

            let nLimbs := 0x1

            let dividendPtr := 0x0
            mstore(add(dividendPtr, 0), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) // dividend[0]

            let divisorPtr := 0x20
            mstore(add(divisorPtr, 0), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) // divisor[0]

            let quotientPtr := 0x40
            mstore(add(quotientPtr, 0), 0x0) // quotient[0]

            let reminderPtr := 0x60
            mstore(add(reminderPtr, 0), 0x0) // reminder[0]

            bigUIntDivRem(dividendPtr, divisorPtr, nLimbs, quotientPtr, reminderPtr)

            // Comparing quotient against expected values:
            console_log(eq(mload(add(64, 0)), 0x1)) // quotient[0]

            // Comparing reminder against expected values:
            console_log(eq(mload(add(96, 0)), 0x0)) // reminder[0]


            // Test 02

            let nLimbs := 0x1

            let dividendPtr := 0x0
            mstore(add(dividendPtr, 0), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) // dividend[0]

            let divisorPtr := 0x20
            mstore(add(divisorPtr, 0), 0x8000000000000000000000000000000000000000000000000000000000000000) // divisor[0]

            let quotientPtr := 0x40
            mstore(add(quotientPtr, 0), 0x0) // quotient[0]

            let reminderPtr := 0x60
            mstore(add(reminderPtr, 0), 0x0) // reminder[0]

            bigUIntDivRem(dividendPtr, divisorPtr, nLimbs, quotientPtr, reminderPtr)

            // Comparing quotient against expected values:
            console_log(eq(mload(add(64, 0)), 0x1)) // quotient[0]

            // Comparing reminder against expected values:
            console_log(eq(mload(add(96, 0)), 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) // reminder[0]

            // Test 03
            let nLimbs := 0x1

            let dividendPtr := 0x0
            mstore(add(dividendPtr, 0), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) // dividend[0]

            let divisorPtr := 0x20
            mstore(add(divisorPtr, 0), 0x1) // divisor[0]

            let quotientPtr := 0x40
            mstore(add(quotientPtr, 0), 0x0) // quotient[0]

            let reminderPtr := 0x60
            mstore(add(reminderPtr, 0), 0x0) // reminder[0]

            bigUIntDivRem(dividendPtr, divisorPtr, nLimbs, quotientPtr, reminderPtr)

            // Comparing quotient against expected values:
            console_log(eq(mload(add(64, 0)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) // quotient[0]

            // Comparing reminder against expected values:
            console_log(eq(mload(add(96, 0)), 0x0)) // reminder[0]

		}
    }
}
