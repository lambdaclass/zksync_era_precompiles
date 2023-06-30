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
                  function ALT_BN128_GROUP_ORDER() -> ret {
                        ret := 21888242871839275222246405745257275088696311157297823662689037894645226208583
                  }
      
                  /// @dev The gas cost of processing ecAdd circuit precompile.
                  function ECMUL_GAS_COST() -> ret {
                        ret := 40000
                  }

                  // ////////////////////////////////////////////////////////////////
                  //                      HELPER FUNCTIONS
                  // ////////////////////////////////////////////////////////////////

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

                  // Returns 1 if (x, y) is in the curve, 0 otherwise
                  function pointIsInCurve(
                        sint256_x,
                        sint256_y,
                  ) -> ret {
                        let y_squared := mulmod(sint256_y, sint256_y, ALT_BN128_GROUP_ORDER())
                        let x_squared := mulmod(sint256_x, sint256_x, ALT_BN128_GROUP_ORDER())
                        let x_qubed := mulmod(x_squared, sint256_x, ALT_BN128_GROUP_ORDER())
                        let x_qubed_plus_three := addmod(x_qubed, 3, ALT_BN128_GROUP_ORDER())

                        ret := eq(y_squared, x_qubed_plus_three)
                  }

                  function pow(base, exponent) -> quotient {
                        switch exponent
                        case 0 { quotient := 1 }
                        case 1 { quotient := base }
                        default {
                              quotient := pow(mul(base, base), div(exponent, 2))
                              switch mod(exponent, 2)
                                    case 1 { quotient := mul(base, quotient) }
                        }
                  }

                  function invmod(uint256_base, uint256_modulus) -> inv {
                        inv := powmod(uint256_base, sub(uint256_modulus, 2), uint256_modulus)
                  }

                  function divmod(uint256_dividend, uint256_divisor, uint256_modulus) -> quotient {
                        quotient := mulmod(uint256_dividend, invmod(uint256_divisor, uint256_modulus), uint256_modulus)
                  }

                  function powmod(
                        uint256_base,
                        uint256_exponent,
                        uint256_modulus,
                  ) -> pow {
                        pow := 1
                        let base := mod(uint256_base, uint256_modulus)
                        let exponent := mod(uint256_exponent, sub(uint256_modulus, 1))
                        for { let i := 0 } gt(exponent, ZERO()) { i := add(i, 1) } {
                              if eq(mod(exponent, 2), ONE()) {
                                    pow := mulmod(pow, base, uint256_modulus)
                              }
                              exponent := shr(1, exponent)
                              base := mulmod(base, base, uint256_modulus)
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
                        sint256_x,
                        sint256_y,
                  ) -> ret {
                        ret := and(eq(sint256_x, ZERO()), eq(sint256_y, ZERO()))
                  }

                  function double(sint256_x, sint256_y) -> x, y {
                        if isInfinity(sint256_x, sint256_y) {
                              x := ZERO()
                              y := ZERO()
                              return(x, y)
                        }
                        // (3 * sint256_x^2 + a) / (2 * sint256_y)
                        let slope := divmod(addmod(mulmod(3, powmod(sint256_x, 2, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER()), ZERO(), ALT_BN128_GROUP_ORDER()), mulmod(2, sint256_y, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                        // x = slope^2 - 2 * sint256_x
                        x := submod(mulmod(slope, slope, ALT_BN128_GROUP_ORDER()), mulmod(2, sint256_x, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                        // y = slope * (sint256_x - x) - sint256_y
                        y := submod(mulmod(slope, submod(sint256_x, x, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER()), sint256_y, ALT_BN128_GROUP_ORDER())
                  }

                  function addPoints(sint256_x1, sint256_y1, sint256_x2, sint256_y2) -> x3, y3 {
                        if isInfinity(sint256_x1, sint256_y1) {
                              x3 := sint256_x2
                              y3 := sint256_y2
                              return(x3, y3)
                        }
                        if isInfinity(sint256_x2, sint256_y2) {
                              x3 := sint256_x1
                              y3 := sint256_y1
                              return(x3, y3)
                        }
                        if and(eq(sint256_x1, sint256_x2), eq(sint256_y1, sint256_y2)) {
                              // Double
                              x3, y3 := double(sint256_x1, sint256_y1)
                              return(x3, y3)
                        }
                        // (sint256_y2 - sint256_y1) / (sint256_x2 - sint256_x1)
                        let slope := divmod(submod(sint256_y2, sint256_y1, ALT_BN128_GROUP_ORDER()), submod(sint256_x2, sint256_x1, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                        // x3 = slope^2 - sint256_x1 - sint256_x2
                        x3 := submod(mulmod(slope, slope, ALT_BN128_GROUP_ORDER()), addmod(sint256_x1, sint256_x2, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                        // y3 = slope * (sint256_x1 - x3) - sint256_y1
                        y3 := submod(mulmod(slope, submod(sint256_x1, x3, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER()), sint256_y1, ALT_BN128_GROUP_ORDER())
                  }

                  ////////////////////////////////////////////////////////////////
                  //                      FALLBACK
                  ////////////////////////////////////////////////////////////////

                  // Retrieve the coordinates from the calldata
                  let x := calldataload(0)
                  let y := calldataload(32)
                  let scalar := calldataload(64)

                  // Ensure that the scalar is a number between 0 and 2^256 - 1.
                  if gt(scalar, sub(shl(1, 256), 1)) {
                        return(0, 0)
                  }

                  // Add the points.
                  if isInfinity(x, y) {
                        // Infinity * scalar = Infinity
                        mstore(0, ZERO())
                        mstore(32, ZERO())
                        return(0, 64)
                  }
                  // Multiply the points.
                  if eq(scalar, ZERO()) {
                        // P * 0 = Infinity
                        mstore(0, ZERO())
                        mstore(32, ZERO())
                        return(0, 64)
                  }
                  if eq(scalar, ONE()) {
                        // P * 1 = P

                        // Ensure that the coordinates are between 0 and the group order.
                        if or(gt(x, sub(ALT_BN128_GROUP_ORDER(), 1)), gt(y, sub(ALT_BN128_GROUP_ORDER(), 1))) {
                              return(0, 0)
                        }

                        // Ensure that the point is in the curve (Y^2 = X^3 + 3).
                        if iszero(pointIsInCurve(x, y)) {
                              return(0, 0)
                        }

                        mstore(0, x)
                        mstore(32, y)
                        return(0, 64)
                  }

                  // Ensure that the coordinates are between 0 and the group order.
                  if or(gt(x, sub(ALT_BN128_GROUP_ORDER(), 1)), gt(y, sub(ALT_BN128_GROUP_ORDER(), 1))) {
                        return(0, 0)
                  }

                  // Ensure that the point is in the curve (Y^2 = X^3 + 3).
                  if iszero(pointIsInCurve(x, y)) {
                        return(0, 0)
                  }

                  let x2 := ZERO()
                  let y2 := ZERO()
                  for { let i := 0 } lt(i, scalar) { i := add(i, 1) } {
                        x2, y2 := addPoints(x, y, x2, y2)
                  }

                  mstore(0, x2)
                  mstore(32, y2)
                  return(0, 64)

                  // // Return the result
                  // let precompileParams := unsafePackPrecompileParams(
                  //       0, // input offset in words
                  //       // TODO: Double check that the input length is 4 because it could be 2
                  //       // if the input points are packed in a single word (points as tuples of coordinates)
                  //       3, // input length in words (x, y, scalar)
                  //       0, // output offset in words
                  //       // TODO: Double check that the input length is 4 because it could be 1
                  //       // if the input points are packed in a single word (points as tuples of coordinates)
                  //       2, // output length in words (x, y)
                  //       0  // No special meaning, ecMul circuit doesn't check this value
                  // )
                  // let gasToPay := ECMUL_GAS_COST()
      
                  // // Check whether the call is successfully handled by the ecMul circuit
                  // let success := precompileCall(precompileParams, gasToPay)
                  // let internalSuccess := mload(0)
      
                  // switch and(success, internalSuccess)
                  // case 0 {
                  //       return(0, 0)
                  // }
                  // default {
                  //       return(0, 64)
                  // }
		}
	}
}
