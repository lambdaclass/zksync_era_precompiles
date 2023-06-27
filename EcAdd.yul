object "EcAdd" {
	code { }
	object "EcAdd_deployed" {
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
                  function ECADD_GAS_COST() -> ret {
                        ret := 0x1f4
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

                  // @dev Adds two field elements over a prime field of modulus
                  // the group size.
                  // Caller should ensure the type matching before!
                  function addFieldElements(
                        uint256_augend,
                        uint256_addend,
                  ) -> sum {
                        sum := addmod(uint256_augend, uint256_addend, ALT_BN128_GROUP_SIZE())
                  }

                  // Returns 1 if (x, y) is in the curve, 0 otherwise
                  function pointIsInCurve(
                        uint256_x,
                        uint256_y,
                  ) -> ret {
                        let y_squared := mulmod(uint256_y, uint256_y, ALT_BN128_GROUP_SIZE())
                        let x_squared := mulmod(uint256_x, uint256_x, ALT_BN128_GROUP_SIZE())
                        let x_qubed := mulmod(x_squared, uint256_x, ALT_BN128_GROUP_SIZE())
                        let x_qubed_plus_three := addmod(x_qubed, 3, ALT_BN128_GROUP_SIZE())

                        ret := eq(y_squared, x_qubed_plus_three)
                  }

                  function power(base, exponent) -> quotient {
                        switch exponent
                        case 0 { quotient := 1 }
                        case 1 { quotient := base }
                        default {
                              quotient := power(mul(base, base), div(exponent, 2))
                              switch mod(exponent, 2)
                                    case 1 { quotient := mul(base, quotient) }
                        }
                  }

                  function divmod(uint256_dividend, uint256_divisor, uint256_modulus) -> quotient {
                        quiotient := mulmod(uint256_dividend, power(uint256_divisor, sub(ALT_BN128_GROUP_SIZE(), 2)))
                  }

                  function powermod(
                        uint256_base,
                        uint256_exponent,
                        uint256_modulus,
                  ) -> power {
                        let exponent := mod(uint256_exponent, sub(ALT_BN128_GROUP_SIZE(), 1))
                        power := 1
                        for { let i := 0 } lt(i, exponent) { i := add(i, 1) }
                        {
                              power := mulmod(power, base, modulus)
                        }
                  }

                  function submod(
                        uint256_minuend,
                        uint256_subtrahend,
                        uint256_modulus,
                  ) -> difference {
                        difference := addmod(uint256_minuend, sub(uint256_modulus, uint256_subtrahend), uint256_modulus)
                  }

                  function isInfinity(
                        uint256_x,
                        uint256_y,
                  ) -> ret {
                        ret := and(eq(x, ZERO()), eq(y, ZERO()))
                  }

                  ////////////////////////////////////////////////////////////////
                  //                      FALLBACK
                  ////////////////////////////////////////////////////////////////

                  // Retrieve the coordinates from the calldata
                  let x1 := calldataload(0)
                  let y1 := calldataload(32)
                  let x2 := calldataload(64)
                  let y2 := calldataload(96)

                  // Ensure that the points are in the curve (Y^2 = X^3 + 3).
                  if or(not(pointIsInCurve(x1, y1)), not(pointIsInCurve(x2, y2))) {
                        return(0, 0)
                  }

                  // Ensure that the coordinates are between 0 and the group order.
                  if or(gt(x, submod(ALT_BN128_GROUP_ORDER(), 1, ALT_BN128_GROUP_ORDER())), gt(y, submod(ALT_BN128_GROUP_ORDER(), 1, ALT_BN128_GROUP_ORDER()))) {
                        return(0, 0)
                  }

                  // Ensure that the point is in the right subgroup (if needed).

                  // Add the points.
                  if and(isInfinity(x1, y1), isInfinity(x2, y2)) {
                        // Infinity + Infinity = Infinity
                        mstore(0, ZERO())
                        mstore(32, ZERO())
                  }
                  if and(isInfinity(x1, y1), not(isInfinity(x2, y2))) {
                        // Infinity + P = P
                        mstore(0, x2)
                        mstore(32, y2)
                  }
                  if and(not(isInfinity(x1, y1)), isInfinity(x2, y2)) {
                        // P + Infinity = P
                        mstore(0, x1)
                        mstore(32, y1)
                  }
                  if and(eq(x1, x2), not(eq(y1, y2))) {
                        // P + (-P) = Infinity
                        mstore(0, ZERO())
                        mstore(32, ZERO())
                  }
                  if and(eq(x1, x2), or(eq(y1, ZERO()), eq(y2, ZERO()))) {
                        // P + P = Infinity
                        mstore(0, ZERO())
                        mstore(32, ZERO())
                  }
                  if and(eq(x1, x2), eq(y1, y2)) {
                        // P + P = 2P

                        // (3 * x1^2 + a) / (2 * y1)
                        let slope := divmod(addmod(mulmod(3, powermod(x1, 2, ALT_BN128_GROUP_SIZE())), ZERO(), ALT_BN128_GROUP_SIZE()), mulmod(y1, 2, ALT_BN128_GROUP_SIZE()), ALT_BN128_GROUP_SIZE())
                        // x3 = slope^2 - 2 * x1
                        let x3 := submod(powermod(slope, 2, ALT_BN128_GROUP_SIZE), mulmod(2, x1, ALT_BN128_GROUP_SIZE()), ALT_BN128_GROUP_ORDER())
                        // y3 = slope * (x1 - x3) - y1
                        let y3 := submod(mulmod(slope, submod(x1, x3, ALT_BN128_GROUP_SIZE()), ALT_BN128_GROUP_SIZE()), y1, ALT_BN128_GROUP_SIZE())

                        // Ensure that the new point is in the curve
                        if not(pointIsInCurve(x3, y3)) {
                              return(0, 0)
                        }

                        mstore(0, x3)
                        mstore(32, y3)
                  }
                  if not(eq(x1, x2)) {
                        // P1 + P2 = P3

                        // (y2 - y1) / (x2 - x1)
                        let slope := divmod(submod(y2, y1, ALT_BN128_GROUP_SIZE()), submod(x2, x1, ALT_BN128_GROUP_SIZE()), ALT_BN128_GROUP_SIZE())
                        // x3 = slope^2 - x1 - x2
                        let x3 := submod(submod(powermod(slope, 2, ALT_BN128_GROUP_SIZE()), x1, ALT_BN128_GROUP_SIZE()), x2, ALT_BN128_GROUP_SIZE())
                        // y3 = slope * (x1 - x3) - y1
                        let y3 := submod(mulmod(slope, submod(x1, x3, ALT_BN128_GROUP_SIZE()), ALT_BN128_GROUP_SIZE()), y1, ALT_BN128_GROUP_SIZE())

                        // Ensure that the new point is in the curve
                        if not(pointIsInCurve(x3, y3)) {
                              return(0, 0)
                        }

                        mstore(0, x3)
                        mstore(32, y3)
                  }

                  // Return the result
                  let precompileParams := unsafePackPrecompileParams(
                        0, // input offset in words
                        // TODO: Double check that the input length is 4 because it could be 2
                        // if the input points are packed in a single word (points as tuples of coordinates)
                        4, // input length in words (x1, y1, x2, y2)
                        0, // output offset in words
                        // TODO: Double check that the input length is 4 because it could be 1
                        // if the input points are packed in a single word (points as tuples of coordinates)
                        2, // output length in words (x3, y3)
                        0  // No special meaning, ecAdd circuit doesn't check this value
                  )
                  let gasToPay := ECADD_GAS_COST()
      
                  // Check whether the call is successfully handled by the ecrecover circuit
                  let success := precompileCall(precompileParams, gasToPay)
                  let internalSuccess := mload(0)
      
                  switch and(success, internalSuccess)
                  case 0 {
                        return(0, 0)
                  }
                  default {
                        // TODO: Check that we're returning the right stuff.
                        return(0, 64)
                  }
		}
	}
}
