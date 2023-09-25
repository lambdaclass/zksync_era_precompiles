object "ModExp" {
	code { }
	object "ModExp_deployed" {
		code {
            // CONSTANTS

            function WORD_SIZE() -> wordSize {
                wordSize := 0x20
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

            /// @notice Add two big numbers.
            /// @param lhsPtr The pointer where the big number on the left operand starts.
            /// @param rhsPtr The pointer where the big number on right operand starts.
            /// @param nLimbs The number of 32-byte words that the big numbers occupy.
            /// @param resPtr The pointer where the result of the addition will be stored.
            /// @return isOverflow A boolean indicating whether the addition overflowed (true) or not (false).
            function bigUIntAdd(lhsPtr, rhsPtr, nLimbs, resPtr) -> isOverflow {
                let totalLength := mul(nLimbs, WORD_SIZE())
                let carry := 0

                let lhsCurrentLimbPtr := add(lhsPtr, totalLength)
                let rhsCurrentLimbPtr := add(rhsPtr, totalLength)

                // Loop through each full 32-byte word to add the two big numbers.
                for {let i := 1 } or(eq(i,nLimbs), lt(i, nLimbs)) { i := add(i, 1) } {
                    // Check limb from the right (least significant limb)
                    let actualLimbOffset := mul(WORD_SIZE(), i)
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
