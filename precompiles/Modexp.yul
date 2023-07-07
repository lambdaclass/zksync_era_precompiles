object "ModExp" {
	code { }
	object "ModExp_deployed" {
		code {
            ////////////////////////////////////////////////////////////////
            //                      CONSTANTS
            ////////////////////////////////////////////////////////////////

            function ZERO() -> zero {
                zero := 0x0
            }

            function ONE() -> one {
                one := 0x1
            }

            //////////////////////////////////////////////////////////////////
            //                      HELPER FUNCTIONS
            //////////////////////////////////////////////////////////////////

            // @dev Packs precompile parameters into one word.
            // Note: functions expect to work with 32/64 bits unsigned integers.
            // Caller should ensure the type matching before!
            function unsafePackPrecompileParams(
                uint32_inputOffsetInWords,
                uint32_inputLengthInWords,
                uint32_outputOffsetInWords,
                uint32_outputLengthInWords,
                uint64_perPrecompileInterpreted
            ) -> rawParams {
                rawParams := uint32_inputOffsetInWords
                rawParams := or(rawParams, shl(32, uint32_inputLengthInWords))
                rawParams := or(rawParams, shl(64, uint32_outputOffsetInWords))
                rawParams := or(rawParams, shl(96, uint32_outputLengthInWords))
                rawParams := or(rawParams, shl(192, uint64_perPrecompileInterpreted))
            }

            /// @dev Executes the `precompileCall` opcode.
            function precompileCall(precompileParams, gasToBurn) -> ret {
                // Compiler simulation for calling `precompileCall` opcode
                ret := verbatim_2i_1o("precompile", precompileParams, gasToBurn)
            }

            ////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////

            let base_length := calldataload(0)
            mstore(0, base_length)

            let exponent_length := calldataload(32)
            mstore(32, exponent_length)

            let modulus_length := calldataload(64)
            mstore(64, modulus_length)

            let base_length_pointer := 96
            calldatacopy(add(96, sub(32, base_length)), base_length_pointer, base_length)
            
            let exponent_length_pointer := add(base_length_pointer, base_length)
            calldatacopy(add(128, sub(32, exponent_length)), exponent_length_pointer, exponent_length)
            
            let modulus_length_pointer := add(exponent_length_pointer, exponent_length)
            calldatacopy(add(160, sub(32, modulus_length)), modulus_length_pointer, modulus_length)
            
            let base := mload(96)
            let exponent := mload(128)
            let modulus := mload(160)

            // 1^exponent % modulus = 1
            if eq(base, ONE()) {
                mstore(196, ONE())
                return(196, modulus_length)
            }

            // base^0 % modulus = 1
            if iszero(exponent) {
                mstore(196, ONE())
                return(196, modulus_length)
            }

            // base^exponent % 0 = 0
            if iszero(modulus) {
                mstore(196, ZERO())
                return(196, modulus_length)
            }

            let pow := 1
            base := mod(base, modulus)
            for { let i := 0 } gt(exponent, ZERO()) { i := add(i, 1) } {
                if eq(mod(exponent, 2), ONE()) {
                    pow := mulmod(pow, base, modulus)
                }
                exponent := shr(1, exponent)
                base := mulmod(base, base, modulus)
            }

            mstore(196, pow)
            return(196, modulus_length)
		}
	}
}
