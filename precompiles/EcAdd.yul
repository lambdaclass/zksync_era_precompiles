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
                  function ALT_BN128_GROUP_ORDER() -> ret {
                        ret := 21888242871839275222246405745257275088696311157297823662689037894645226208583
                  }
      
                  /// @dev The gas cost of processing ecAdd circuit precompile.
                  function ECADD_GAS_COST() -> ret {
                        ret := 0x1f4
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

                  // @dev Adds two field elements over a prime field of modulus
                  // the group size.
                  // Caller should ensure the type matching before!
                  function addFieldElements(
                        uint256_augend,
                        uint256_addend,
                  ) -> sum {
                        sum := addmod(uint256_augend, uint256_addend, ALT_BN128_GROUP_ORDER())
                  }

                  // Returns 1 if (x, y) is in the curve, 0 otherwise
                  function pointIsInCurve(
                        uint256_x,
                        uint256_y,
                  ) -> ret {
                        let y_squared := mulmod(uint256_y, uint256_y, ALT_BN128_GROUP_ORDER())
                        let x_squared := mulmod(uint256_x, uint256_x, ALT_BN128_GROUP_ORDER())
                        let x_qubed := mulmod(x_squared, uint256_x, ALT_BN128_GROUP_ORDER())
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
                        uint256_x,
                        uint256_y,
                  ) -> ret {
                        ret := and(eq(uint256_x, ZERO()), eq(uint256_y, ZERO()))
                  }

                  ////////////////////////////////////////////////////////////////
                  //                      FALLBACK
                  ////////////////////////////////////////////////////////////////

                  // Retrieve the coordinates from the calldata
                  let x1 := calldataload(0)
                  let y1 := calldataload(32)
                  let x2 := calldataload(64)
                  let y2 := calldataload(96)

                  // Add the points.
                  if and(isInfinity(x1, y1), isInfinity(x2, y2)) {
                        // Infinity + Infinity = Infinity
                        mstore(0, ZERO())
                        mstore(32, ZERO())
                        return(0, 64)
                  }
                  if and(isInfinity(x1, y1), not(isInfinity(x2, y2))) {
                        // Infinity + P = P

                        // Ensure that the coordinates are between 0 and the group order.
                        if or(gt(x2, sub(ALT_BN128_GROUP_ORDER(), ONE())), gt(y2, sub(ALT_BN128_GROUP_ORDER(), ONE()))) {
                              return(0, 0)
                        }

                        // Ensure that the point is in the curve (Y^2 = X^3 + 3).
                        if iszero(pointIsInCurve(x2, y2)) {
                              return(0, 0)
                        }

                        mstore(0, x2)
                        mstore(32, y2)
                        return(0, 64)
                  }
                  if and(not(isInfinity(x1, y1)), isInfinity(x2, y2)) {
                        // P + Infinity = P

                        // Ensure that the coordinates are between 0 and the group order.
                        if or(gt(x1, sub(ALT_BN128_GROUP_ORDER(), ONE())), gt(y1, sub(ALT_BN128_GROUP_ORDER(), ONE()))) {
                              return(0, 0)
                        }

                        // Ensure that the point is in the curve (Y^2 = X^3 + 3).
                        if iszero(pointIsInCurve(x1, y1)) {
                              return(0, 0)
                        }

                        mstore(0, x1)
                        mstore(32, y1)
                        return(0, 64)
                  }
                  if and(eq(x1, x2), eq(not(y1), y2)) {
                        // P + (-P) = Infinity
                        mstore(0, ZERO())
                        mstore(32, ZERO())
                        return(0, 64)
                  }
                  if and(eq(x1, x2), or(eq(y1, ZERO()), eq(y2, ZERO()))) {
                        // P1 + P2 = Infinity

                        // Ensure that the coordinates are between 0 and the group order.
                        if or(gt(x1, sub(ALT_BN128_GROUP_ORDER(), ONE())), gt(y1, sub(ALT_BN128_GROUP_ORDER(), ONE()))) {
                              return(0, 0)
                        }

                        mstore(0, ZERO())
                        mstore(32, ZERO())
                        return(0, 64)
                  }
                  if and(eq(x1, x2), eq(y1, y2)) {
                        // P + P = 2P

                        // Ensure that the coordinates are between 0 and the group order.
                        if or(gt(x1, sub(ALT_BN128_GROUP_ORDER(), ONE())), gt(y1, sub(ALT_BN128_GROUP_ORDER(), ONE()))) {
                              return(0, 0)
                        }

                        // Ensure that the points are in the curve (Y^2 = X^3 + 3).
                        if iszero(pointIsInCurve(x1, y1)) {
                              return(0, 0)
                        }

                        // (3 * x1^2 + a) / (2 * y1)
                        let slope := divmod(addmod(mulmod(3, powmod(x1, 2, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER()), ZERO(), ALT_BN128_GROUP_ORDER()), mulmod(2, y1, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                        // x3 = slope^2 - 2 * x1
                        let x3 := submod(mulmod(slope, slope, ALT_BN128_GROUP_ORDER()), mulmod(2, x1, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                        // y3 = slope * (x1 - x3) - y1
                        let y3 := submod(mulmod(slope, submod(x1, x3, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER()), y1, ALT_BN128_GROUP_ORDER())

                        mstore(0, x3)
                        mstore(32, y3)
                        return(0, 64)
                  }
                  if iszero(eq(x1, x2)) {
                        // P1 + P2 = P3

                        // Ensure that the coordinates are between 0 and the group order.
                        if or(gt(x1, sub(ALT_BN128_GROUP_ORDER(), 1)), gt(y1, sub(ALT_BN128_GROUP_ORDER(), 1))) {
                              return(0, 0)
                        }
                        if or(gt(x2, sub(ALT_BN128_GROUP_ORDER(), 1)), gt(y2, sub(ALT_BN128_GROUP_ORDER(), 1))) {
                              return(0, 0)
                        }

                        // Ensure that the points are in the curve (Y^2 = X^3 + 3).
                        if or(iszero(pointIsInCurve(x1, y1)), iszero(pointIsInCurve(x2, y2))) {
                              return(0, 0)
                        }

                        // (y2 - y1) / (x2 - x1)
                        let slope := divmod(submod(y2, y1, ALT_BN128_GROUP_ORDER()), submod(x2, x1, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                        // x3 = slope^2 - x1 - x2
                        let x3 := submod(mulmod(slope, slope, ALT_BN128_GROUP_ORDER()), addmod(x1, x2, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                        // y3 = slope * (x1 - x3) - y1
                        let y3 := submod(mulmod(slope, submod(x1, x3, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER()), y1, ALT_BN128_GROUP_ORDER())

                        mstore(0, x3)
                        mstore(32, y3)
                        return(0, 64)
                  }

                  // // Return the result
                  // let precompileParams := unsafePackPrecompileParams(
                  //       0, // input offset in words
                  //       4, // input length in words (x1, y1, x2, y2)
                  //       0, // output offset in words
                  //       2, // output length in words (x3, y3)
                  //       0  // No special meaning, ecAdd circuit doesn't check this value
                  // )
                  // let gasToPay := ECADD_GAS_COST()
      
                  // // Check whether the call is successfully handled by the ecAdd circuit
                  // let success := precompileCall(precompileParams, gasToPay)
                  // let internalSuccess := mload(0)
      
                  // switch and(success, internalSuccess)
                  // case 0 {
                  //       mstore(0, 0x7)
                  //       mstore(32, 0x7)
                  //       return(0, 64)

                  //       return(0, 0)
                  // }
                  // default {
                  //       return(0, 64)
                  // }
		}
	}
}
