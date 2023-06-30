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

            function GQUADDIVISOR() -> ret {
                ret := 20
            }

            function MODEXP_GAS_COST(sint256_length_of_BASE, sint256_length_of_MODULUS) -> modexpGasCost {
                // TODO: Find the correct amount of gas to burn
                modexpGasCost := floor(mult_complexity(max(sint256_length_of_BASE, sint256_length_of_MODULUS)) * max(ADJUSTED_EXPONENT_LENGTH, 1) / GQUADDIVISOR)
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
            let exponent_length := calldataload(32)
            let modulus_length := calldataload(64)
            let base := calldatacopy(0, 64, base_length)
            let exponent := calldatacopy(base_length, 96, exponent_length)
            let modulus := calldatacopy(add(base_length, exponent_length), 128, modulus_length)

            // base^0 % modulus = 1
            if iszero(exponent) {
                mstore(0, ONE())
                return(0, 32)
            }

            // base^exponent % 0 = 0
            if iszero(modulus) {
                let s := add(add(base_length, exponent_length), modulus_length)
                mstore(0, ZERO())
                return(s, modulus_length)
            }

            let pow := 1
            base := mod(base, modulus)
            exponent := mod(exponent, sub(modulus, 1))
            for { let i := 0 } gt(exponent, ZERO()) { i := add(i, 1) } {
                    if eq(mod(exponent, 2), ONE()) {
                        pow := mulmod(pow, base, modulus)
                    }
                    exponent := shr(1, exponent)
                    base := mulmod(base, base, modulus)
            }

            mstore(0, pow)

            // Return the result
            let precompileParams := unsafePackPrecompileParams(
                  0, // input offset in words
                  3, // input length in words (base, exponent, modulus)
                  0, // output offset in words
                  1, // output length in words (pow)
                  0  // No special meaning, modexp circuit doesn't check this value
            )
            let gasToPay := MODEXP_GAS_COST()

            // Check whether the call is successfully handled by the ecAdd circuit
            let success := precompileCall(precompileParams, gasToPay)
            let internalSuccess := mload(0)

            switch and(success, internalSuccess)
            case 0 {
                  mstore(0, 0x7)
                  mstore(32, 0x7)
                  return(0, 64)

                  return(0, 0)
            }
            default {
                  return(0, 64)
            }
		}
	}
}
