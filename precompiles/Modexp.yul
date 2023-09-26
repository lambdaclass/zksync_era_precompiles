object "ModExp" {
	code { }
	object "ModExp_deployed" {
		code {
            // CONSTANTS

            function WORD_SIZE() -> wordSize {
                wordSize := 0x20
            }

            // HELPER FUNCTIONS

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

            function bigUIntSqr(numberPtr, nLimbs, productPtr) {
                let endOfProductPtr := add(productPtr, mul(mul(nLimbs, WORD_SIZE()), 2))
                let hiPtr := productPtr
                let loPtr := add(productPtr, mul(nLimbs, WORD_SIZE()))
                
                let i := nLimbs
                let j, k, index, a_i, a_j, hi, lo, cs, overflow, c
                for {} gt(i, 1) {} {
                    i := sub(i, 1)
                    j := i
                    for {} gt(j, 0) {} {
                        j := sub(j, 1)
                        k := add(i, j)
                        if or(gt(k, sub(i, 1)), eq(k, sub(i, 1))) {
                            index := sub(add(k, 1), nLimbs)
                            a_i := mload(add(numberPtr, mul(WORD_SIZE(), i)))
                            a_j := mload(add(numberPtr, mul(WORD_SIZE(), j)))
                            hi := getHighestHalfOfMultiplication(a_i, a_j)
                            lo := mul(a_i,a_j)
                            lo, overflow := overflowingAdd(lo, mload(add(loPtr, mul(index, WORD_SIZE()))))
                            if overflow {
                                hi := add(hi, 1)
                            }
                            lo, overflow := overflowingAdd(lo, c)
                            if overflow {
                                hi := add(hi, 1)
                            }
                            c := hi
                            mstore(add(loPtr, mul(index, WORD_SIZE())), lo)
                        }
                        if lt(k, sub(i, 1)) {
                            index := sub(add(k, 1), nLimbs)
                            a_i := mload(add(numberPtr, mul(WORD_SIZE(), i)))
                            a_j := mload(add(numberPtr, mul(WORD_SIZE(), j)))
                            hi := getHighestHalfOfMultiplication(a_i, a_j)
                            lo := mul(a_i,a_j)
                            lo, overflow := overflowingAdd(lo, mload(add(hiPtr, mul(index, WORD_SIZE()))))
                            if overflow {
                                hi := add(hi, 1)
                            }
                            lo, overflow := overflowingAdd(lo, c)
                            if overflow {
                                hi := add(hi, 1)
                            }
                            c := hi
                            mstore(add(hiPtr, mul(index, WORD_SIZE())), lo)
                        }
                    }
                    mstore(add(hiPtr, i), or(hi,lo))
                }
                let carry := shr(63, mload(loPtr))
                // lo = shl(1, lo)
                // hi = shl(1, hi)
                // hi.limbs[NUM_LIMBS - 1] |= carry;

                c := 0
                i := nLimbs
                for {} gt(i, 0) {} {
                    i := sub(i, 1)
                    if or(lt(sub(nLimbs, 1), mul(i, 2)), eq(sub(nLimbs, 1), mul(i, 2))) {
                        index := sub(add(mul(2, i), 1), nLimbs)
                        a_i := mload(add(numberPtr, mul(WORD_SIZE(), i)))
                        a_j := mload(add(numberPtr, mul(WORD_SIZE(), j)))
                        hi := getHighestHalfOfMultiplication(a_i, a_j)
                        lo := mul(a_i,a_j)
                        lo, overflow := overflowingAdd(lo, mload(add(loPtr, mul(index, WORD_SIZE()))))
                        if overflow {
                            hi := add(hi, 1)
                        }
                        lo, overflow := overflowingAdd(lo, c)
                        if overflow {
                            hi := add(hi, 1)
                        }
                        c := hi
                        mstore(add(loPtr, mul(index, WORD_SIZE())), lo)
                    }
                    if gt(sub(nLimbs, 1), mul(i, 2)) {
                        index := add(mul(2, i), 1)
                        a_i := mload(add(numberPtr, mul(WORD_SIZE(), i)))
                        a_j := mload(add(numberPtr, mul(WORD_SIZE(), j)))
                        hi := getHighestHalfOfMultiplication(a_i, a_j)
                        lo := mul(a_i,a_j)
                        lo, overflow := overflowingAdd(lo, mload(add(hiPtr, mul(index, WORD_SIZE()))))
                        if overflow {
                            hi := add(hi, 1)
                        }
                        lo, overflow := overflowingAdd(lo, c)
                        if overflow {
                            hi := add(hi, 1)
                        }
                        c := hi
                        mstore(add(hiPtr, mul(index, WORD_SIZE())), lo)
                    }
                    if lt(sub(nLimbs, 1), mul(i, 2)) {
                        index := sub(mul(2, i), nLimbs)
                        hi := 0
                        lo, overflow := overflowingAdd(c, mload(add(hiPtr, mul(index, WORD_SIZE()))))
                        if overflow {
                            hi := add(hi, 1)
                        }
                        c := hi
                        mstore(add(loPtr, mul(index, WORD_SIZE())), lo)
                    }
                    if or(gt(sub(nLimbs, 1), mul(i, 2)),eq(sub(nLimbs, 1), mul(i, 2))) {
                        index := mul(2, i)
                        hi := 0
                        lo, overflow := overflowingAdd(c, mload(add(hiPtr, mul(index, WORD_SIZE()))))
                        if overflow {
                            hi := add(hi, 1)
                        }
                        c := hi
                        mstore(add(hiPtr, mul(index, WORD_SIZE())), lo)
                    }
                }
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
            if bigNumberIsZero(modPtr, modLen) {
                // Fulfill memory with all zeroes.
                for { let ptr } lt(ptr, modLen) { ptr := add(ptr, 32) } {
                    mstore(ptr, 0)
                }
                return(0, modLen)
            }

            // 1^exponent % modulus = 1
            if bigNumberIsOne(basePtr, baseLen) {
                // Fulfill memory with all zeroes.
                for { let ptr } lt(ptr, modLen) { ptr := add(ptr, 32) } {
                    mstore(ptr, 0)
                }
                mstore8(sub(modLen, 1), 1)
                return(0, modLen)
            }

            // base^0 % modulus = 1
            if bigNumberIsZero(expPtr, expLength) {
                // Fulfill memory with all zeroes.
                for { let ptr } lt(ptr, modLen) { ptr := add(ptr, 32) } {
                    mstore(ptr, 0)
                }
                mstore8(sub(modLen, 1), 1)
                return(0, modLen)
            }

            // 0^exponent % modulus = 0
            if bigNumberIsZero(basePtr, baseLen) {
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
