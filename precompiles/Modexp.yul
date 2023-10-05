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
            // HELPER FUNCTIONS

            /// @notice Stores a one in big unsigned integer form in memory.
            /// @param nLimbs The number of limbs needed to represent the operand.
            /// @param toAddress The pointer to the MSB of the destination.
            function oneWithLimbSizeAt(nLimbs, toAddress) {
                let pointerToOne :=  toAddress
                mstore(pointerToOne, 0x1)
                for { let i := sub(nLimbs, 1) } gt(i, 0) { i := sub(i, 1) } {
                   let offset := add(mul(i, 32), pointerToOne)
                   mstore(offset, 0x0)
                }
             }
            
            /// @notice Stores a zero in big unsigned integer form in memory.
            /// @param nLimbs The number of limbs needed to represent the operand.
            /// @param toAddress The pointer to the MSB of the destination.
            function zeroWithLimbSizeAt(nLimbs, toAddress) {
                for { let i := 0 } lt(i, nLimbs) { i := add(i, 1) } {
                    let offset := mul(i, 32)
                    mstore(add(toAddress, offset), 0)
                }
            }
            
            /// @notice Copy a big unsigned integer from one memory location to another.
            /// @param nLimbs The number of limbs needed to represent the operand.
            /// @param fromAddress The pointer to the MSB of the number to copy.
            /// @param toAddress The pointer to the MSB of the destination.
            function copyBigUint(nLimbs, fromAddress, toAddress) {
                for { let i := 0 } lt(i, nLimbs) { i := add(i, 1) } {
                    let fromOffset := add(mul(i, 32), fromAddress)
                    let toOffset := add(mul(i, 32), toAddress)
                    mstore(toOffset, mload(fromOffset))
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

            /// @notice Computes the difference between two 256 bit number and keeps
            /// account of the borrow bit.
            /// @param minuend The left side of the difference (i.e. the a in a - b).
            /// @param subtrahend The right side of the difference (i.e. the b in a - b).
            /// @return difference i.e. the c in c = a - b.
            /// @return overflowed If there was any borrow on the subtraction, is returned as 1.
            function overflowingSubWithBorrow(minuend, subtrahend, borrow) -> difference, overflowed {
                difference := sub(minuend, add(subtrahend, borrow))
                overflowed := gt(difference, minuend)
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
            function bigUIntIsZero(start, len) -> res {
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
            function bigUIntIsOne(start, len) -> res {
                if len {
                    let lastBytePtr := sub(add(start, len), 1)
                    let lastByte := byte(0, calldataload(lastBytePtr))

                    // Check if the last byte is one.
                    let lastByteIsOne := eq(lastByte, 1)
                    // Check if all other bytes are zero using the bigUIntIsZero function
                    // The length for this check is (len - 1) because we exclude the last byte.
                    let otherBytesAreZeroes := bigUIntIsZero(start, sub(len, 1))

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
                for { let currentOffset := 0 } lt(currentOffset, finalOffset) { currentOffset := add(currentOffset, 0x20) } {
                    let lhsCurrentPtr := add(lhsPtr, currentOffset)
                    let rhsCurrentPtr := add(rhsPtr, currentOffset)
                    let resCurrentPtr := add(resPtr, currentOffset)
                    let lhsCurrentValue := mload(lhsCurrentPtr)
                    let rhsCurrentValue := mload(rhsCurrentPtr)
                    let resCurrentValue := xor(lhsCurrentValue, and(mask, xor(lhsCurrentValue, rhsCurrentValue))) // a ^ (ct & (a ^ b))
                    mstore(resCurrentPtr, resCurrentValue)
                }
            }

            /// @notice Performs the big unsigned integer bit or operation.
            /// @dev The result is stored from `resPtr` to `resPtr + (LIMB_SIZE * nLimbs)`.
            /// @param lhsPtr The pointer to the MSB of the left operand.
            /// @param rhsPtr The pointer to the MSB of the right operand.
            /// @param nLimbs The number of limbs needed to represent the operands.
            /// @param resPtr The pointer to where you want the result to be stored
            function bigUIntBitOr(lhsPtr, rhsPtr, nLimbs, resPtr) {
                let finalOffset := shl(5, nLimbs) // == ( LIMB_SIZE * nLimbs ) == (32 * nLimbs) 
                for { let currentOffset := 0 } lt(currentOffset, finalOffset) { currentOffset := add(currentOffset, 0x20) } {
                    let lhsCurrentPtr := add(lhsPtr, currentOffset)
                    let rhsCurrentPtr := add(rhsPtr, currentOffset)
                    let resCurrentPtr := add(resPtr, currentOffset)
                    let lhsCurrentValue := mload(lhsCurrentPtr)
                    let rhsCurrentValue := mload(rhsCurrentPtr)
                    let resCurrentValue := or(lhsCurrentValue, rhsCurrentValue)
                    mstore(resCurrentPtr, resCurrentValue)
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
            /// @param augendPtr The pointer where the big number on the left operand starts.
            /// @param addendPtr The pointer where the big number on right operand starts.
            /// @param nLimbs The number of 32-byte words that the big numbers occupy.
            /// @param sumPtr The pointer where the result of the addition will be stored.
            /// @return overflowed A boolean indicating whether the addition overflowed (true) or not (false).
            function bigUIntAdd(augendPtr, addendPtr, nLimbs, sumPtr) -> overflowed {
                let totalLength := mul(nLimbs, LIMB_SIZE_IN_BYTES())
                let carry := 0

                let augendCurrentLimbPtr := add(augendPtr, totalLength)
                let addendCurrentLimbPtr := add(addendPtr, totalLength)

                // Loop through each full 32-byte word to add the two big numbers.
                for { let i := 1 } or(eq(i,nLimbs), lt(i, nLimbs)) { i := add(i, 1) } {
                    // Check limb from the right (least significant limb)
                    let currentLimbOffset := mul(LIMB_SIZE_IN_BYTES(), i)
                    augendCurrentLimbPtr := sub(augendCurrentLimbPtr, currentLimbOffset)
                    addendCurrentLimbPtr := sub(addendCurrentLimbPtr, currentLimbOffset)
                    
                    let addendLimb := mload(addendCurrentLimbPtr)
                    let augendLimb := mload(augendCurrentLimbPtr)
                    let sum, overflow := overflowingAdd(augendLimb, addendLimb)
                    let sumWithPreviousCarry, carrySumOverflow := overflowingAdd(sum, carry)
                    sum := sumWithPreviousCarry
                    carry := or(overflow, carrySumOverflow)
                    let limbResultPtr := sub(add(sumPtr,totalLength), currentLimbOffset)
                    mstore(limbResultPtr, sum)
                }
                overflowed := carry

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
            /// in minuendPtr and subtrahendPtr.
            /// @dev Reference: https://github.com/lambdaclass/lambdaworks/blob/main/math/src/unsigned_integer/element.rs#L795
            /// @param minuendPtr The start of the left hand side subtraction Big Number.
            /// @param subtrahendPtr The start of the right hand side subtraction Big Number.
            /// @return nLimbs The number of limbs of both numbers.
            /// @return differencePtr Where the result will be stored.
            function bigUIntSubWithBorrow(minuendPtr, subtrahendPtr, nLimbs, differencePtr) -> borrow {
                let minuendCurrentLimb
                let subtrahendCurrentLimb
                let differenceCurrentLimb
                borrow := 0
                let limbOffset := 0
                for { let i := nLimbs } gt(i, 0) { i := sub(i, 1) } {
                    limbOffset := mul(sub(i,1), 32)
                    let minuendCurrentLimb := getLimbValueAtOffset(minuendPtr, limbOffset)
                    let subtrahendCurrentLimb := getLimbValueAtOffset(subtrahendPtr, limbOffset)
                    differenceCurrentLimb, borrow := overflowingSubWithBorrow(minuendCurrentLimb, subtrahendCurrentLimb, borrow)
                    storeLimbValueAtOffset(differencePtr, limbOffset, differenceCurrentLimb)
                }
            }

            /// @notice Performs the multiplication between two bigUInts
            /// @dev The result is stored from `productPtr` to `productPtr + (LIMB_SIZE * nLimbs)`.
            /// @param multiplicandPtr The start index in memory of the first number.
            /// @param multiplierPtr The start index in memory of the second number.
            /// @param nLimbs The number of limbs needed to represent the operands.
            function bigUIntMul(multiplicandPtr, multiplierPtr, nLimbs, productPtr) {
                let retIndex, retWordAfter, retWordBefore
                // Iterating over each limb in the first number.
                for { let i := nLimbs } gt(i, 0) { i := sub(i, 1) } {
                    let carry := 0

                    // Iterating over each limb in the second number.
                    for { let j := nLimbs } gt(j, 0) { j := sub(j, 1) } {
                        // Loading the i-th and j-th limbs of the first and second numbers.
                        let word1 := mload(add(multiplicandPtr, mul(LIMB_SIZE_IN_BYTES(), sub(i, 1))))
                        let word2 := mload(add(multiplierPtr, mul(LIMB_SIZE_IN_BYTES(), sub(j, 1))))

                        let product, carryFlag := overflowingAdd(mul(word1, word2), carry)
                        carry := add(getHighestHalfOfMultiplication(word1, word2), carryFlag)

                        // Calculate the index to store the product.
                        retIndex := add(productPtr, mul(sub(add(i, j), 1), LIMB_SIZE_IN_BYTES()))
                        retWordBefore := mload(retIndex) // Load the previous value at the result index.
                        retWordAfter, carryFlag := overflowingAdd(retWordBefore, product)

                        mstore(retIndex, retWordAfter)
                        carry := add(carry, carryFlag)
                    }

                    // Store the last word which comes from the final carry.
                    retIndex := add(productPtr, mul(sub(i, 1), LIMB_SIZE_IN_BYTES()))
                    mstore(retIndex, carry)
                }
            }

            // @notice Computes the bit size of an unsigned integer.
            // @dev Return value boundary: `0 <= bitSize <= 256`
            // @param number An unsigned integer value.
            // @return bitSize Number of bits required to represent `number`.
            function UIntBitSize(number) -> bitSize {
                // Increment bitSize until there are no significant bits left.
                bitSize := 0
                for { let shift_me := number } lt(0, shift_me) { shift_me := shr(1, shift_me) } {
                    bitSize := add(bitSize, 1)
                }
            }

            /// @notice Computes the bit size of a big unsigned integer.
            /// @param basePtr Base pointer for a big unsigned integer.
            /// @param nLimbs The number of limbs needed to represent the operand.
            /// @return bitSize Number of bits of the big unsigned integer.
            function bigUIntBitSize(basePtr, nLimbs) -> bitSize {
                bitSize := shl(8, nLimbs)

                // Iterate until finding the most significant limb or reach the end of the limbs.
                let limb := 0
                for { let i := 0 } and(lt(i, nLimbs), iszero(limb)) { i := add(i, 1) } {
                    bitSize := sub(bitSize, 256) // Decrement one limb worth of bits.
                    let ptr_i := add(basePtr, shl(5, i)) // = basePtr + i * 32 bytes
                    limb := mload(ptr_i)
                }

                // At this point, `limb == limbs[i - 1]`. Where `i` equals the
                // last value it took.

                // At this point, `bitSize` equals the amount of bits in the
                // limbs following the most significant limb.

                bitSize := add(bitSize, UIntBitSize(limb))
            }

            /// @notice Performs in-place `x | 1` operation.
            /// @dev This function will mutate the memory space `mem[basePtr...(basePtr + nLimbs * 32)]`
            /// @dev It consumes constant time, aka `O(1)`.
            /// @param basePtr Base pointer for a big unsigned integer.
            /// @param nLimbs Number of 32 Byte limbs composing the big unsigned integer.
            function bigUIntInPlaceOrWith1(basePtr, nLimbs) {
                let offset := mul(sub(nLimbs, 1), 32)
                let limbPtr := add(basePtr, offset)
                let limb := mload(limbPtr)
                mstore(limbPtr, or(limb, 0x1))
            }

            /// @notice Performs one shift to the left for a big unsigned integer (<<).
            /// @dev The shift is performed in-place, mutating the memory space of the number.
            /// @param numberPtr The pointer to the MSB of the number to shift.
            /// @param nLimbs The number of limbs needed to represent the operand.
            function bigUIntOneShiftLeft(numberPtr, nLimbs) {
                let p := add(numberPtr, shl(5, nLimbs)) // numberPtr + 32 * nLimbs
                let carryBit := 0
                for {  } lt(numberPtr, p) {  } {
                    p := sub(p, 32)
                    let limb := mload(p)
                    let msb := shr(255, limb)
                    limb := or(shl(1, limb), carryBit)
                    mstore(p, limb)
                    carryBit := msb
                }
            }

            /// @notice Performs one shift to the right for a big unsigned integer (>>).
            /// @dev The shift is performed in-place, mutating the memory space of the number.
            /// @param numberPtr The pointer to the MSB of the number to shift.
            /// @param nLimbs The number of limbs needed to represent the operand.
            function bigUIntOneShiftRight(numberPtr, nLimbs) {
                let overflowPtr := add(numberPtr, shl(5, nLimbs))
                let carryBit := 0
                for { let p := numberPtr } lt(p, overflowPtr) { p := add(p, 32) } {
                    let limb := mload(p)
                    let lsb := and(limb, 1)
                    limb := or(shr(1, limb), carryBit)
                    carryBit := shl(255, lsb)
                    mstore(p, limb)
                }
            }

            /// @notice Computes the quotiend and reminder of dividing two big unsigned integers.
            /// @dev
            /// @dev Temporary buffers:
            /// @dev ------------------
            /// @dev
            /// @dev This function requires two temporary buffers for internal storage:
            /// @dev - Both buffers must provide `n_limbs * 32` bytes of writable memory space.
            /// @dev - Neither buffer should overlap with each other.
            /// @dev - Neither needs to be initialized to any particular value.
            /// @dev - Consider the written values as undefined after the function returns.
            /// @dev
            /// @dev Return values:
            /// @dev --------------
            /// @dev
            /// @dev - resulting `quotient` will be written `mem[base_ptr, base_ptr + 32 * n_limbs)`
            /// @dev - resulting `reminder` will be written `mem[base_ptr, base_ptr + 32 * n_limbs)`
            /// @dev
            /// @param dividend_ptr Base pointer for a big unsigned integer representing the dividend.
            /// @param divisor_ptr  Base pointer for a big unsigned integer representing the divisor.
            /// @param tmp_ptr_1    Base pointer for a contiguous memory space of `n_limbs` for internal usage. Will be overwritten.
            /// @param tmp_ptr_2    Base pointer for a contiguous memory space of `n_limbs` for internal usage. Will be overwritten.
            /// @param n_limbs      Amount of limbs for each big unsigned integer.
            /// @param quotient_ptr Base pointer for a big unsigned integer to write the division quotient.
            /// @param rem_ptr Base pointer for a big unsigned integer to write the division remainder.
            function bigUIntDivRem(dividend_ptr, divisor_ptr, tmp_ptr_1, tmp_ptr_2, n_limbs, quotient_ptr, rem_ptr) {
                // Assign meaningful internal names to the temporary buffers passed as parameters. We use abstract names for
                // parameters to prevent the leakage of implementation details.
                let c_ptr := tmp_ptr_1
                let r_ptr := tmp_ptr_2

                copyBigUint(n_limbs, dividend_ptr, rem_ptr) // rem = dividend 

                // Init quotient to 0.
                zeroWithLimbSizeAt(n_limbs, quotient_ptr) // quotient = 0

                let mb := bigUIntBitSize(divisor_ptr, n_limbs)
                let bd := sub(mul(n_limbs, 256), mb)
                bigUIntShl(bd, divisor_ptr, n_limbs, c_ptr) // c == divisor << bd

                for { } iszero(0) { } {
                    let borrow := bigUIntSubWithBorrow(rem_ptr, c_ptr, n_limbs, r_ptr)

                    if iszero(borrow) {
                        copyBigUint(n_limbs, r_ptr, rem_ptr)
                    }

                    copyBigUint(n_limbs, quotient_ptr, r_ptr) // r = quotient
                    bigUIntInPlaceOrWith1(r_ptr, n_limbs) // r = quotient | 1

                    if iszero(borrow) {
                        copyBigUint(n_limbs, r_ptr, quotient_ptr)
                    }

                    if iszero(bd) {
                        break
                    }

                    bd := sub(bd, 1)
                    bigUIntOneShiftRight(c_ptr, n_limbs) // c = c >> 1
                    bigUIntOneShiftLeft(quotient_ptr, n_limbs) // q[] = q[] << 1
                }

                if iszero(mb) {
                    zeroWithLimbSizeAt(n_limbs, quotient_ptr)
                }
            }
            function big_uint_duplicate_n_limbs(from_ptr, n_limbs, to_ptr) {}

            function bigUIntMulMod(lhs_ptr, rhs_ptr, modulo_ptr, n_limbs, result_ptr) {
               // Algorithm: 
               // lhs, rhs = u ints of size n_limbs
               // result = (lhs*rhs) mod modulo
               // 1. result = lhs*rhs
               // 2. result can have size 2*(n_limbs),
               //    so zero extend modulo to 2*(n_libms)
               // 3. q, result = (result/modulo),
               // 4 return result 

               // result = lhs*rhs
               bigUIntMul(lhsPtr, rhsPtr, n_limbs, result_ptr)
               // bigUIntMul doubles the limb size of the result,
               // so result now points to a 2*n_limbs number
               let extended_modulo_ptr := 0x800 // Fix: Do not hardcode this
               big_uint_duplicate_n_limbs(modulo_ptr, n_limbs, extended_modulo_ptr) 
               bigUIntDivRem(result_ptr, extended_modulo_ptr)
            }

            ////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////

            let baseLen := calldataload(0)
            let expLength := calldataload(32)
            let modLen := calldataload(64)

            // Handle a special case when both the base and mod length are zeroes.
            if and(iszero(baseLen), iszero(modLen)) {
                return(0, 0)
            }

            let basePtr := 96
            let expPtr := add(basePtr, baseLen)
            let modPtr := add(expPtr, expLength)

            // Note: This check covers the case where length of the modulo is zero.
            // base^exponent % 0 = 0
            if bigUIntIsZero(modPtr, modLen) {
                // Fulfill memory with all zeroes.
                for { let ptr } lt(ptr, modLen) { ptr := add(ptr, 32) } {
                    mstore(ptr, 0)
                }
                return(0, modLen)
            }

            // 1^exponent % modulus = 1
            if bigUIntIsOne(basePtr, baseLen) {
                // Fulfill memory with all zeroes.
                for { let ptr } lt(ptr, modLen) { ptr := add(ptr, 32) } {
                    mstore(ptr, 0)
                }
                mstore8(sub(modLen, 1), 1)
                return(0, modLen)
            }

            // base^0 % modulus = 1
            if bigUIntIsZero(expPtr, expLength) {
                // Fulfill memory with all zeroes.
                for { let ptr } lt(ptr, modLen) { ptr := add(ptr, 32) } {
                    mstore(ptr, 0)
                }
                mstore8(sub(modLen, 1), 1)
                return(0, modLen)
            }

            // 0^exponent % modulus = 0
            if bigUIntIsZero(basePtr, baseLen) {
                // Fulfill memory with all zeroes.
                for { let ptr } lt(ptr, modLen) { ptr := add(ptr, 32) } {
                    mstore(ptr, 0)
                }
                return(0, modLen)
            }

            // TODO: big arithmetics
		}
	}
}
