object "Playground" {
	code { }
	object "Playground_deployed" {
		code {
            // CONSTANTS

            // CONSOLE.LOG Caller
            // It prints 'val' in the node console and it works using the 'mem'+0x40 memory sector
            function console_log(val) -> {
                let log_address := 0x000000000000000000636F6e736F6c652e6c6f67
                // load the free memory pointer
                let freeMemPointer := 0x400
                // store the function selector of log(uint256) in memory
                mstore(freeMemPointer, 0xf82c50f1)
                // store the first argument of log(uint256) in the next memory slot
                mstore(add(freeMemPointer, 0x20), val)
                // call the console.log contract
                if iszero(staticcall(gas(),log_address,add(freeMemPointer, 28),add(freeMemPointer, 0x40),0x00,0x00)) {
                    revert(0,0)
                }
            }

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

            // @notice Performs in-place `x | 1` operation.
            // @dev This function will mutate the memory space `mem[base_ptr...(base_ptr + n_limbs * 32)]`
            // @dev It consumes constant time, aka `O(1)`.
            // @param base_ptr Base pointer for a big unsigned integer.
            // @param n_limbs Number of 32 Byte limbs composing the big unsigned integer.
            function big_uint_inplace_or_1(base_ptr, n_limbs) {
                let offset := mul(sub(n_limbs, 1), 32)
                let limb_ptr := add(base_ptr, offset)
                let limb := mload(limb_ptr)
                mstore(limb_ptr, or(limb, 0x1))
            }

            function big_uint_shift_left_by_one_in_place(ptr_base, n_limbs) {
                let p := add(ptr_base, shl(5, n_limbs)) // ptr_base + 32 * n_limbs
                let carry_bit := 0
                for {  } lt(ptr_base, p) {  } {
                    p := sub(p, 32)
                    let limb := mload(p)
                    let msb := shr(255, limb) // most significant bit.
                    limb := or(shl(1, limb), carry_bit)
                    mstore(p, limb)
                    carry_bit := msb
                }
            }

            function big_uint_shift_right_by_one_in_place(base_ptr, n_limbs) {
                let ptr_overflow := add(base_ptr, shl(5, n_limbs))
                let carry_bit := 0
                for { let p := base_ptr } lt(p, ptr_overflow) { p := add(p, 32) } {
                    let limb := mload(p)
                    let lsb := and(limb, 1) // Least significant bit.
                    limb := or(shr(1, limb), carry_bit)
                    carry_bit := shl(255, lsb)
                    mstore(p, limb)
                }
            }

            /// @notice Performs the big unsigned integer square of big unsigned integers with an arbitrary amount of limbs.
            /// @dev The quotient is stored from `quotient_ptr` to `quotient_ptr + (WORD_SIZE * nLimbs)`.
            /// @dev The reminder is stored from `rem_ptr` to `rem_ptr + (WORD_SIZE * nLimbs)`.
            function bigUIntDivRem(dividend_ptr, divisor_ptr, n_limbs, quotient_ptr, rem_ptr) {
                // Init pointers for internal use buffers.
                // FIXME This is ok for development purposes, but fix it before publishing the code.
                let c_ptr := 0x900 // FIXME don't use a hardcoded address!
                let r_ptr := 0x700 // FIXME don't use a hardcoded address!

                copyBigUint(n_limbs, dividend_ptr, rem_ptr) // rem = dividend 

                // Init quotient to 0.
                zeroWithLimbSizeAt(n_limbs, quotient_ptr) // quotient = 0

                let mb := big_uint_bit_size(divisor_ptr, n_limbs)
                let bd := sub(mul(n_limbs, 256), mb)
                bigUIntShl(bd, divisor_ptr, n_limbs, c_ptr) // c == divisor << bd

                for { } iszero(0) { } {
                    // LAMBDAWORKS : let (mut r, borrow) = rem.sbb(&c, 0);
                    let borrow := bigUIntSubWithBorrow(rem_ptr, c_ptr, n_limbs, r_ptr)

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
                    if iszero(bd) {
                        break
                    }

                    bd := sub(bd, 1)
                    big_uint_shift_right_by_one_in_place(c_ptr, n_limbs) // c = c >> 1
                    big_uint_shift_left_by_one_in_place(quotient_ptr, n_limbs) // q[] = q[] << 1
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

            // 1 limb

            let nLimbs := 1
            mstore(0x00, 500721)
            mstore(0x20, 5)

            bigUIntDivRem(0x00, 0x20, nLimbs, 0x40, 0x60)
            console_log(mload(0x40)) // 18730
            console_log(mload(0x60)) // 1

            // 2 limbs
            let nLimbs := 2
            mstore(0x00, 0x7463719198237981235)
            mstore(0x20, 0x7132857231590813759832657138957167247234980237328573573650819325)

            mstore(0x40, 0x3A31B8C8CC11BCC091A)
            mstore(0x60, 0xB89942B918AC8409BACC1932B89C4AB8B392391A4C011B9942B9AB9B2840C992)

            bigUIntDivRem(0x00, 0x40, nLimbs, 0x80, 0xc0)
            console_log(mload(0x80)) // 0
            console_log(mload(0xa0)) // 2
            console_log(mload(0xc0)) // 0
            console_log(mload(0xe0)) // 1

            // 3 limbs
            let nLimbs := 3
            mstore(0x00, 0x5bb295e9f8dbfb0a66839c44c0c0ad67e14bfd036)
            mstore(0x20, 0x1d9c29443b5c29a9313f8ba267fd8296ccc4e3590b3048a0a32d19456339e8cc)
            mstore(0x40, 0x45d9ceb10e1b5f51f417b314fe197fe037ba8cb143b5ff987d6652e6d1808ee4)

            mstore(0x60, 0x2dd94af4fc6dfd853341ce22606056b3f0a5fe81b)
            mstore(0x80, 0x0ece14a21dae14d4989fc5d133fec14b666271ac8598245051968ca2b19cf466)
            mstore(0xc0, 0x22ece758870dafa8fa0bd98a7f0cbff01bdd4658a1daffcc3eb3297368c04772)

            bigUIntDivRem(0x00, 0x60, nLimbs, 0xe0, 0x140)
            console_log(mload(0xe0)) //  0
            console_log(mload(0x100)) // 0
            console_log(mload(0x120)) // 2
            console_log(mload(0x140)) // 0
            console_log(mload(0x160)) // 0
            // THIS IS NOT WORKING AS EXPECTED
            console_log(mload(0x180)) // 0
		}
	}
}
