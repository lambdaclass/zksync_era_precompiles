object "EcMul" {
	code { }
	object "EcMul_deployed" {
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

                  // Group order of alt_bn128, see https://eips.ethereum.org/EIPS/eip-196
                  function ALT_BN128_GROUP_SIZE() -> ret {
                        ret := 0x4c8d1c3c7c0f9a086d3d9b2f5a3b7e5d6f
                  }
      
                  /// @dev The gas cost of processing ecAdd circuit precompile. 
                  // See https://eips.ethereum.org/EIPS/eip-196
                  function ECMUL_GAS_COST() -> ret {
                        ret := 0x9c40
                  }

                  ////////////////////////////////////////////////////////////////
                  //                      HELPER FUNCTIONS
                  ////////////////////////////////////////////////////////////////

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

                  // @dev Adds two field elements over a prime field of modulus p
                  // Caller should ensure the type matching before!
                  function mulFieldElements(
                        uint256_augend,
                        uint256_addend,
                  ) -> sum {
                        sum := mulmod(uint256_augend, uint256_addend, ALT_BN128_GROUP_SIZE())
                  }

                  // Returns 1 if (x, y) is in the curve, 0 otherwise
                  function pointIsInCurve(
                        uint256_x,
                        uint256_y,
                  ) -> ret {
                        let y_squared = mulmod(uint256_y, uint256_y, ALT_BN128_GROUP_SIZE())
                        let x_squared = mulmod(uint256_x, uint256_x, ALT_BN128_GROUP_SIZE())
                        let x_qubed = mulmod(x_squared, uint256_x, ALT_BN128_GROUP_SIZE())
                        let x_qubed_plus_three = addmod(x_qubed, 3, ALT_BN128_GROUP_SIZE())

                        ret := eq(y_squared, x_qubed_plus_three)
                  }

                  ////////////////////////////////////////////////////////////////
                  //                      FALLBACK
                  ////////////////////////////////////////////////////////////////

                  // Retrieve the coordinates from the calldata
                  let x := calldataload(0)
                  let y := calldataload(32)
                  let scalar := calldataload(64)

                  // Ensure that the point is in the curve (Y^2 = X^3 + 3)
                  let y_squared = mulmod(y, y, ALT_BN128_GROUP_SIZE())
                  let x_squared = mulmod(x, x, ALT_BN128_GROUP_SIZE())
                  let x_qubed = mulmod(x_squared, x, ALT_BN128_GROUP_SIZE())
                  let x_qubed_plus_three = addmod(x_qubed, 3, ALT_BN128_GROUP_SIZE())

                  if not(pointIsInCurve(x, y)) {
                        revert(0, 0)
                  }

                  // Ensure that the point is in the right subgroup (if needed)

                  // Multiply the point by the scalar
                  if eq(m, ONE()) {
                        // Store the data in memory, so the ecMul circuit will read it 
                        mstore(0, x)
                        mstore(32, y)
                  } else {
                        let x2 := mulFieldElements(x, scalar)
                        let y2 := mulFieldElements(y, scalar)
      
                        // Ensure that the point is in the curve (Y^2 = X^3 + 3).
                        if not(pointIsInCurve(x2, y2)) {
                              revert(0, 0)
                        }

                        // Store the data in memory, so the ecMul circuit will read it 
                        mstore(0, x2)
                        mstore(32, y2)
                  }


                  // Return the result.
                  let precompileParams := unsafePackPrecompileParams(
                        0, // input offset in words
                        // TODO: Double check that the input length is 3 because it could be 2
                        // if the input point is packed in a single word (points as tuples of coordinates)
                        3, // input length in words (x1, y1, scalar)
                        0, // output offset in words
                        2, // output length in words (x2, y2)
                        0  // No special meaning, ecrecover circuit doesn't check this value
                  )
                  let gasToPay := ECMUL_GAS_COST()
      
                  // Check whether the call is successfully handled by the ecrecover circuit.
                  let success := precompileCall(precompileParams, gasToPay)
                  let internalSuccess := mload(0)
      
                  switch and(success, internalSuccess)
                  case 0 {
                        return(0, 0)
                  }
                  default {
                        return(32, 32)
                  }
		}
	}
}
