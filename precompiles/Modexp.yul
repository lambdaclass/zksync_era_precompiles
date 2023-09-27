object "ModExp" {
	code { }
	object "ModExp_deployed" {
		code {
            // CONSTANTS

            function WORD_SIZE() -> wordSize {
                wordSize := 0x20
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
                        console_log(product)

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
                    retIndex := add(resStart, mul(sub(sub(nLimbs, i), 1), WORD_SIZE()))
                    //retWordBefore := mload(retIndex)
                    console_log(retIndex)
                    console_log(carry)
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

            ////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////
            
            // 5e2d939b602a50911232731d04fe6f40c05f97da0602307
            // 099fb991f9b414e2d52bef130349ec18db1a0215ea6caf76

            // 3f3ad1611ab58212f92a2484e9560935b9ac4615fe61cfe
            // d1a4861e193a74d20c94f9f88d8b2cc089543c3f699969d9
            mstore(0x00, 0x5e2d939b602a50911232731d04fe6f40c05f97da0602307)
            mstore(0x20, 0x099fb991f9b414e2d52bef130349ec18db1a0215ea6caf76)

            mstore(0x40, 0x3f3ad1611ab58212f92a2484e9560935b9ac4615fe61cfe)
            mstore(0x60, 0xd1a4861e193a74d20c94f9f88d8b2cc089543c3f699969d9)

            let retStart := 0x80
            bigNumberMultiplication(0x00, 0x40, 2, retStart)
            let res := mload(retStart)
            let res2 := mload(add(retStart, 0x20))
            let res3 := mload(add(retStart, 0x40))
            let res4 := mload(add(retStart, 0x60))

            console_log(res)
            console_log(res2)
            console_log(res3)
            console_log(res4)

            // TODO: big arithmetics
		}
	}
}
