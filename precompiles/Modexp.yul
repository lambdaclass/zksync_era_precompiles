object "ModExp" {
	code { }
	object "ModExp_deployed" {
		code {
            // CONSTANTS

            function WORD_SIZE() -> wordSize {
                wordSize := 0x20
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
                    let ptr_lhs_i := add(rhsPtr, offset_i)
                    let ptr_res_i := add(resPtr, offset_i)
                    let value_lhs_i := mload(ptr_lhs_i)
                    let value_rhs_i := mload(ptr_lhs_i)
                    let value_res_i := or(value_lhs_i, value_rhs_i)
                    mstore(ptr_res_i, value_res_i)
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
