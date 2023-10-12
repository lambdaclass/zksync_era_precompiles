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
            function bigIntLimbs(length) -> limbs, misalignment {
                limbs := div(length, LIMB_SIZE_IN_BYTES())
                misalignment := mod(length, LIMB_SIZE_IN_BYTES())
                if misalignment {
                    limbs := add(limbs, 1)
                }
            }

            /// @notice Returns an address for a free memory region,
            /// which will be startPtr...(startPtr+(howManyAdresses*32))
            /// @param howManyAdresses The number of addresses needed.
            function freeMemoryPointer(howManyAdresses) -> startPtr {
                startPtr := mload(0x0)
                mstore(0x0, add(startPtr, shl(5, howManyAdresses)))
            }

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
                let overflow := add(toAddress, shl(5, nLimbs))
                for { } lt(toAddress, overflow) { toAddress := add(toAddress, LIMB_SIZE_IN_BYTES()) } {
                    mstore(toAddress, 0)
                }
            }
            
            /// @notice Copy a big unsigned integer from one memory location to another.
            /// @param nLimbs The number of limbs needed to represent the operand.
            /// @param fromAddress The pointer to the MSB of the number to copy.
            /// @param toAddress The pointer to the MSB of the destination.
            function copyBigUint(nLimbs, fromAddress, toAddress) {
                let offset := 0
                for { let i := 0 } lt(i, nLimbs) { i := add(i, 1) } {
                    let fromOffset := add(offset, fromAddress)
                    let toOffset := add(offset, toAddress)
                    mstore(toOffset, mload(fromOffset))
                    offset := add(offset, LIMB_SIZE_IN_BYTES())
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

            /// @notice Checks whether calldata[start, start + len) is zero.
            /// @param start The pointer to the calldata where the big number starts.
            /// @param len The number of bytes that the big number occupies.
            /// @return res A boolean indicating whether the big number is zero (true) or not (false).
            function callDataBufferIsZero(start, len) -> res {
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
                    let word := shr(sub(LIMB_SIZE_IN_BITS(), mul(lastWordBytes, 8)), calldataload(endOfLastFullWord))
                    // Use the mask to isolate the valid bytes and check if any are non-zero.
                    if and(word, mask) {
                        res := false
                    }
                }
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
            function callDataBufferIsOne(start, len) -> res {
                if len {
                    let lastBytePtr := sub(add(start, len), 1)
                    let lastByte := byte(0, calldataload(lastBytePtr))

                    // Check if the last byte is one.
                    let lastByteIsOne := eq(lastByte, 1)
                    // Check if all other bytes are zero using the callDataBufferIsZero function
                    // The length for this check is (len - 1) because we exclude the last byte.
                    let otherBytesAreZeroes := callDataBufferIsZero(start, sub(len, 1))

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
                returnBorrow := gt(subtractionResult, leftLimb)
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
                let offset := 0
                for { let i := 0 } and(lt(i, nLimbs), iszero(limb)) { i := add(i, 1) } {
                    bitSize := sub(bitSize, 256) // Decrement one limb worth of bits.
                    let ptr_i := add(basePtr, offset) // = basePtr + i * 32 bytes
                    limb := mload(ptr_i)
                    offset := add(offset, LIMB_SIZE_IN_BYTES())
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
                let offset := shl(5, sub(nLimbs, 1))
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
            /// @dev - Both buffers must provide `nLimbs * 32` bytes of writable memory space.
            /// @dev - Neither buffer should overlap with each other.
            /// @dev - Neither needs to be initialized to any particular value.
            /// @dev - Consider the written values as undefined after the function returns.
            /// @dev
            /// @dev Return values:
            /// @dev --------------
            /// @dev
            /// @dev - resulting `quotient` will be written `mem[basePtr, basePtr + 32 * nLimbs)`
            /// @dev - resulting `reminder` will be written `mem[basePtr, basePtr + 32 * nLimbs)`
            /// @dev
            /// @param dividend_ptr Base pointer for a big unsigned integer representing the dividend.
            /// @param divisor_ptr  Base pointer for a big unsigned integer representing the divisor.
            /// @param tmp_ptr_1    Base pointer for a contiguous memory space of `nLimbs` for internal usage. Will be overwritten.
            /// @param tmp_ptr_2    Base pointer for a contiguous memory space of `nLimbs` for internal usage. Will be overwritten.
            /// @param nLimbs      Amount of limbs for each big unsigned integer.
            /// @param quotient_ptr Base pointer for a big unsigned integer to write the division quotient.
            /// @param rem_ptr Base pointer for a big unsigned integer to write the division remainder.
            function bigUIntDivRem(dividend_ptr, divisor_ptr, tmp_ptr_1, tmp_ptr_2, nLimbs, quotient_ptr, rem_ptr) {
                // Assign meaningful internal names to the temporary buffers passed as parameters. We use abstract names for
                // parameters to prevent the leakage of implementation details.
                let c_ptr := tmp_ptr_1
                let r_ptr := tmp_ptr_2

                copyBigUint(nLimbs, dividend_ptr, rem_ptr) // rem = dividend 

                // Init quotient to 0.
                zeroWithLimbSizeAt(nLimbs, quotient_ptr) // quotient = 0

                let mb := bigUIntBitSize(divisor_ptr, nLimbs)
                let bd := sub(mul(nLimbs, 256), mb)
                bigUIntShl(bd, divisor_ptr, nLimbs, c_ptr) // c == divisor << bd

                for { } iszero(0) { } {
                    let borrow := bigUIntSubWithBorrow(rem_ptr, c_ptr, nLimbs, r_ptr)

                    if iszero(borrow) {
                        copyBigUint(nLimbs, r_ptr, rem_ptr)
                    }

                    copyBigUint(nLimbs, quotient_ptr, r_ptr) // r = quotient
                    bigUIntInPlaceOrWith1(r_ptr, nLimbs) // r = quotient | 1

                    if iszero(borrow) {
                        copyBigUint(nLimbs, r_ptr, quotient_ptr)
                    }

                    if iszero(bd) {
                        break
                    }

                    bd := sub(bd, 1)
                    bigUIntOneShiftRight(c_ptr, nLimbs) // c = c >> 1
                    bigUIntOneShiftLeft(quotient_ptr, nLimbs) // q[] = q[] << 1
                }

                if iszero(mb) {
                    zeroWithLimbSizeAt(nLimbs, quotient_ptr)
                }
            }
            
            /// @notice Inplace zero extend to the left a big uint,
            /// the result will have size of 2 times the original limbs.
            function bigUIntDuplicateNLimbs(fromPtr, nLimbs) {
                let finalLimbs := add(nLimbs, nLimbs)
                for { let i := finalLimbs } gt(i, 0) { i := sub(i, 1) } {
                    if or(eq(i, nLimbs), lt(i, nLimbs)) {
                        mstore(add(fromPtr, mul(sub(i, 1), LIMB_SIZE_IN_BYTES())), 0)
                    }
                    if gt(i, nLimbs) {
                        mstore(add(fromPtr, mul(sub(i, 1), LIMB_SIZE_IN_BYTES())), mload(add(fromPtr, mul(sub(sub(i, 1), nLimbs), LIMB_SIZE_IN_BYTES()))))
                    }
                }
            }

            /// @notice Inplace removal of the first half of limbs from a big uint.
            function bigUIntDivideNLimbsByTwo(fromPtr, nLimbs) {
                let finalLimbs := div(nLimbs, 2)
                for { let i := finalLimbs } gt(i, 0) { i := sub(i, 1) } {
                   mstore(add(fromPtr, mul(sub(finalLimbs, i), LIMB_SIZE_IN_BYTES())), mload(add(fromPtr, mul(sub(nLimbs, i), LIMB_SIZE_IN_BYTES()))))
                }
            }

            /// @notice Computes c = (a*b) mod n, where a,b are big uints of
            /// nLimbs size each, starting on lshPtr and rhsPtr, respectively,
            /// and moduloPtr points to the start of the big uint n.
            function bigUIntMulMod(lhsPtr, rhsPtr, moduloPtr, nLimbs, resultPtr) {

                // result = lhs*rhs
                let resultPtrMul := 0x200 // FIXME: Do not hardcode this
                let quoResultPtr := 0x1000 // FIXME: Do not hardcode this
                let auxPtr1 := 0x400 // FIXME: Do not hardcode this
                let auxPtr2 := 0x600 // FIXME: Do not hardcode this

                bigUIntMul(lhsPtr, rhsPtr, nLimbs, resultPtrMul)
                // bigUIntMul doubles the limb size of the result,
                // so result now points to a 2*nLimbs number
                bigUIntDuplicateNLimbs(moduloPtr, nLimbs)
                bigUIntDivRem(resultPtrMul, moduloPtr, auxPtr1, auxPtr2, add(nLimbs, nLimbs), quoResultPtr, resultPtr)
                // divide limb size of result by 2 to get the final result
                bigUIntDivideNLimbsByTwo(resultPtr, add(nLimbs, nLimbs))
            }

            function bigUIntIsGreaterThanOne(nLimbs, basePtr) -> ret {
               // Pointer to the least significant limb.
               let p :=  add(basePtr, shl(5, sub(nLimbs, 1)))

               // Least significant limb.
               let limb := mload(p)

               // If the least significant limb is greater than 1, we know for
               // sure that the big unsigned integer will be greater than 1.
               ret := gt(limb, 1)

               // If we don't know yet whether the big unsigned integer is
               // greater than one, we will have to look if there exists a more
               // significative limb thats greater than 0.
               //
               // We are iterating backwards, because the big unsigned integers
               // we are working with may be left padded with zeros to match
               // the size of other big unsigned integers. This way we have a
               // better chance to consume less iterations. In the worst case
               // scenario, where the answer is false, we will have to read the
               // whole number from memory, making this algorithm `O(nLimbs)`.
               for { } and(lt(basePtr, p), eq(ret, false)) { } {
                   p := sub(p, LIMB_SIZE_IN_BYTES()) 
                   ret := lt(0, mload(p))
               }
            }

            function bigUIntModTwo(nLimbs, basePtr) -> ret {
                let p := add(basePtr, shl(5, sub(nLimbs, 1))) // Least significant limb addr.
                ret := and(mload(p), 0x1)
            }

            function flip(lhs, rhs) -> ret_lhs, ret_rhs {
                ret_lhs := rhs
                ret_rhs := lhs
            }

            function bigUIntIsNotZero(p, nLimbs) -> is_not_zero {
                is_not_zero := false
                let past_the_end_ptr :=  add(p, shl(5, nLimbs))
                for { } lt(p, past_the_end_ptr) { p := add(p, 32) } {
                    is_not_zero := lt(0, mload(p))
                    if is_not_zero {
                        leave
                    }
                }
            }

            function bigUIntLowerHalfPtr(nLimbs, basePtr) -> p {
                let upperHalfSizeInBytes := shl(4, nLimbs) // nLimbs * 32 / 2
                p := add(basePtr, upperHalfSizeInBytes)
            }

            // @notice Computes the big uint modular exponentiation `result[] := base[] ** exponent[] % modulus[]`.
            // @param nLimbs Amount of limbs that compose each of the big unsigned integer parameters.
            // @param basePtr Base pointer to a big unsigned integer representing the `base[]`. It's most significant half must be zeros.
            // @param exponentPtr Base pointer to a big unsigned integer representing the `exponent[]`. It's most significant half must be zeros.
            // @param modulusPtr Base pointer to a big unsigned integer representing the `modulus[]`. Must be greater than 0. It's most significant half must be zeros.
            // @param resultPtr Base pointer to a big unsigned integer to store the result[]. Must be initialized to zeros.
            function bigUIntModularExponentiation(nLimbs, basePtr, exponentPtr, modulusPtr, resultPtr, scratchBuf1Ptr, scratchBuf2Ptr, scratchBuf3Ptr, scratchBuf4Ptr) {
                // Algorithm pseudocode:
                // See: https://en.wikipedia.org/wiki/Modular_exponentiation#Pseudocode
                // function modular_pow(base, exponent, modulus) is
                //     if modulus = 1 then
                //         return 0
                //     Assert :: (modulus - 1) * (modulus - 1) does not overflow base
                //     result := 1
                //     base := base mod modulus
                //     while exponent > 0 do
                //         if (exponent mod 2 == 1) then
                //             result := (result * base) mod modulus
                //         exponent := exponent >> 1
                //         base := (base * base) mod modulus
                //     return result

                // PSEUDOCODE: `if modulus = 1 then return 0`.
                // We are using the precondition that `result == 0` and `0 < modulus`.
                // FIXME: Does the algorithm work without this check? We may be paying the cost of running this function just for a rare test case.
                if bigUIntIsGreaterThanOne(nLimbs, modulusPtr) {

                    // Assert :: (modulus - 1) * (modulus - 1) does not overflow base
                    // We are certain that this is true because our precondition requires the most significant half of exponent to be zeros.

                    // PSEUDOCODE: `result := 1`
                    // Again, we are using the precondition that `result[] == 0`
                    bigUIntInPlaceOrWith1(resultPtr, nLimbs)

                    // PSEUDOCODE: `base := base mod modulus`
                    // FIXME: Is ok to mutate the base[] we were given? Shall we use a temporal buffer?
                    bigUIntDivRem(basePtr, modulusPtr, scratchBuf1Ptr, scratchBuf2Ptr, nLimbs, scratchBuf3Ptr, scratchBuf4Ptr)
                    basePtr, scratchBuf4Ptr := flip(basePtr, scratchBuf4Ptr)

                    // PSEUDOCODE: `while exponent > 0 do`
                    // FIXME: Is ok to mutate the exponent[] we were given? Shall we use a temporal buffer?
                    for { } bigUIntIsNotZero(exponentPtr, nLimbs) { } {

                        // PSEUDOCODE: `if (exponent mod 2 == 1) then`
                        if bigUIntModTwo(nLimbs, exponentPtr) {

                            // PSEUDOCODE: `result := (result * base) mod modulus`
                            // Since result[] is our return value, we are allowed to mutate it.
                            zeroWithLimbSizeAt(nLimbs, scratchBuf1Ptr)
                            let result_low_ptr := bigUIntLowerHalfPtr(nLimbs, resultPtr)
                            let base_low_ptr := bigUIntLowerHalfPtr(nLimbs, basePtr)
                            // scratch_buf_1 <- result * base. NOTICE that the higher half of `scratch_buf_1` may be non-0.
                            bigUIntMul(result_low_ptr, base_low_ptr, shr(1, nLimbs), scratchBuf1Ptr)
                            // result <- scratch_buf_1 % modulus. The upper half of return is guaranteed to be 0.
                            bigUIntDivRem(scratchBuf1Ptr, modulusPtr, scratchBuf4Ptr, scratchBuf2Ptr, nLimbs, scratchBuf3Ptr, resultPtr)

                        }

                        // PSEUDOCODE: `exponent := exponent >> 1`
                        // FIXME: Is ok to mutate the exponent[] we were given? Shall we use a temporal buffer?
                        bigUIntOneShiftRight(exponentPtr, nLimbs)
                        
                        // PSEUDOCODE: `base := (base * base) mod modulus`
                        {
                            // scratch_buf_2 <- base * base
                            zeroWithLimbSizeAt(nLimbs, scratchBuf2Ptr) // scratch_buf_2 <- 0
                            let base_low_ptr := bigUIntLowerHalfPtr(nLimbs, basePtr)
                            bigUIntMul(base_low_ptr, base_low_ptr, shr(1, nLimbs), scratchBuf2Ptr)

                            // base <- temp % modulus
                            bigUIntDivRem(scratchBuf2Ptr, modulusPtr, scratchBuf1Ptr, scratchBuf3Ptr, nLimbs, scratchBuf4Ptr, basePtr)
                        }
                    }
                }
            }
            
            /// @notice Pad a big uint with zeros to the left until newLimbNumber is reached.
            /// @dev The result is stored from `resultPtr` to `resultPtr + (LIMB_SIZE_IN_BYTES * newLimbNumber)`.
            /// @dev If currentLimbNumber is equal to newLimbNumber, then the result is the same as the input.
            /// @param ptr The pointer to the MSB of the number to pad.
            /// @param currentLimbNumber The number of limbs needed to represent the operand.
            /// @param newLimbNumber The number of limbs wanted to represent the operand.
            /// @param resultPtr The pointer to the MSB of the padded number.
            function bigUIntPadWithZeros(ptr, currentLimbNumber, newLimbNumber, resultPtr) -> resultPtr {
                for { let i := 0 } lt(i, currentLimbNumber) { i := add(i, 1) } {
                    // Move the limb to the right position
                    mstore(add(resultPtr, mul(sub(sub(newLimbNumber, 1), i), LIMB_SIZE_IN_BYTES())), mload(add(ptr, mul(sub(sub(currentLimbNumber,1), i), LIMB_SIZE_IN_BYTES()))))
                    // Store zero in the position of the moved limb
                    mstore(add(resultPtr, mul(sub(sub(currentLimbNumber,1), i), LIMB_SIZE_IN_BYTES())), 0)
                }
            }

            // Last limbs refers to the most significant limb in big-endian representation.
            function parseCalldata(calldataValuePtr, calldataValueLen, resPtr) -> memoryValueLen {
                // The in-memory value length in bytes of the calldata value.
                memoryValueLen := calldataValueLen
                let numberOfLimbs := div(calldataValueLen, LIMB_SIZE_IN_BYTES())
                let lastLimbMisalignmentInBytes := mod(calldataValueLen, LIMB_SIZE_IN_BYTES())
                let firstLimbExtraBytes := sub(LIMB_SIZE_IN_BYTES(), lastLimbMisalignmentInBytes)
                let lastLimbBytes := sub(LIMB_SIZE_IN_BYTES(), firstLimbExtraBytes)
                let misalignedWordPtr := sub(calldataValuePtr, firstLimbExtraBytes)
                if lastLimbMisalignmentInBytes {
                    // If there is a misalignment, then we need to add one more limb to the result length.
                    numberOfLimbs := add(numberOfLimbs, 1)
                    memoryValueLen := shl(5, numberOfLimbs)
                    let misalignedLimb := calldataload(misalignedWordPtr)
                    let firstWordExtraBits := shl(3, firstLimbExtraBytes)
                    misalignedLimb := shl(firstWordExtraBits, misalignedLimb)
                    misalignedLimb := shr(firstWordExtraBits, misalignedLimb)
                    mstore(resPtr, misalignedLimb)
                }

                let currentLimbCalldataPtr := calldataValuePtr
                let currentLimbMemoryPtr := resPtr
                for { let currentLimbNumber := 0 } lt(currentLimbNumber, numberOfLimbs) { currentLimbNumber := add(currentLimbNumber, 1) } {
                    if and(iszero(currentLimbNumber), lastLimbMisalignmentInBytes) {
                        // If the MSL is misaligned, then at this point it has been handled and we should 
                        // skip the first iteration (which handles the MSL if it is not misaligned).
                        currentLimbCalldataPtr := add(currentLimbCalldataPtr, lastLimbBytes)
                        currentLimbMemoryPtr := add(currentLimbMemoryPtr, LIMB_SIZE_IN_BYTES())
                        continue
                    }
                    let currentLimb := calldataload(currentLimbCalldataPtr)
                    mstore(currentLimbMemoryPtr, currentLimb)
                    currentLimbCalldataPtr := add(currentLimbCalldataPtr, LIMB_SIZE_IN_BYTES())
                    currentLimbMemoryPtr := add(currentLimbMemoryPtr, LIMB_SIZE_IN_BYTES())
                }
            }

            function padWithZeroesIfNeeded(startingLimbPtr, currentLimbSize, toPadLimbSize) -> resultPtr {
                switch eq(currentLimbSize, toPadLimbSize)
                case 0 {
                    resultPtr := freeMemoryPointer(toPadLimbSize)
                    bigUIntPadWithZeros(startingLimbPtr, currentLimbSize, toPadLimbSize, resultPtr)
                }
                case 1 {
                    resultPtr := startingLimbPtr 
                }
            }

            ////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////

            let baseLen := calldataload(0)
            let expLen := calldataload(32)
            let modLen := calldataload(64)
            freeMemoryPointer(1)
            // // Handle a special case when both the base and mod length are zeroes.
            // if and(iszero(baseLen), iszero(modLen)) {
            //     return(0, 0)
            // }

            let basePtr := 96
            let expPtr := add(basePtr, baseLen)
            let modPtr := add(expPtr, expLen)

            // // Note: This check covers the case where length of the modulo is zero.
            // // base^exponent % 0 = 0
            // if callDataBufferIsZero(modPtr, modLen) {
            //     // Fulfill memory with all zeroes.
            //     for { let ptr } lt(ptr, modLen) { ptr := add(ptr, 32) } {
            //         mstore(ptr, 0)
            //     }
            //     return(0, modLen)
            // }

            // // 1^exponent % modulus = 1
            // if callDataBufferIsOne(basePtr, baseLen) {
            //     // Fulfill memory with all zeroes.
            //     for { let ptr } lt(ptr, modLen) { ptr := add(ptr, 32) } {
            //         mstore(ptr, 0)
            //     }
            //     mstore8(sub(modLen, 1), 1)
            //     return(0, modLen)
            // }

            // // base^0 % modulus = 1
            // if callDataBufferIsZero(expPtr, expLen) {
            //     // Fulfill memory with all zeroes.
            //     for { let ptr } lt(ptr, modLen) { ptr := add(ptr, 32) } {
            //         mstore(ptr, 0)
            //     }
            //     mstore8(sub(modLen, 1), 1)
            //     return(0, modLen)
            // }

            // // 0^exponent % modulus = 0
            // if callDataBufferIsZero(basePtr, baseLen) {
            //     // Fulfill memory with all zeroes.
            //     for { let ptr } lt(ptr, modLen) { ptr := add(ptr, 32) } {
            //         mstore(ptr, 0)
            //     }
            //     return(0, modLen)
            // }

            let limbsBaseLen, misalignment := bigIntLimbs(baseLen)
            let limbsExpLen, misalignment := bigIntLimbs(expLen)
            let limbsModLen, misalignment := bigIntLimbs(modLen)

            let ptrBaseLimbs := freeMemoryPointer(limbsBaseLen)
            parseCalldata(basePtr, baseLen, ptrBaseLimbs)

            let ptrExpLimbs := freeMemoryPointer(limbsExpLen)
            parseCalldata(expPtr, expLen, ptrExpLimbs)

            let ptrModLimbs := freeMemoryPointer(limbsModLen)
            parseCalldata(modPtr, modLen, ptrModLimbs)

            let maxLimbNumber := limbsBaseLen

            if lt(maxLimbNumber, limbsExpLen) {
                maxLimbNumber := limbsExpLen
            }
            if lt(maxLimbNumber, limbsModLen) {
                maxLimbNumber := limbsModLen
            }
            
            let baseStartPtr := padWithZeroesIfNeeded(ptrBaseLimbs, limbsBaseLen, maxLimbNumber)
            let exponentStartPtr := padWithZeroesIfNeeded(ptrExpLimbs, limbsExpLen, maxLimbNumber)
            let moduloStartPtr := padWithZeroesIfNeeded(ptrModLimbs, limbsModLen, maxLimbNumber)

            let scratchBufferPtr1 := freeMemoryPointer(maxLimbNumber)
            let scratchBufferPtr2 := freeMemoryPointer(maxLimbNumber)
            let scratchBufferPtr3 := freeMemoryPointer(maxLimbNumber)
            let scratchBufferPtr4 := freeMemoryPointer(maxLimbNumber)
            let resultPtr := freeMemoryPointer(maxLimbNumber)

            bigUIntModularExponentiation(maxLimbNumber, baseStartPtr, exponentStartPtr, moduloStartPtr, resultPtr, scratchBufferPtr1, scratchBufferPtr2, scratchBufferPtr3, scratchBufferPtr4) 
            return(resultPtr, maxLimbNumber)
		}
	}
}
