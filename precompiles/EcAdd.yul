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

                  function R2_mod_ALT_BN128_GROUP_ORDER() -> ret {
                        ret := 3096616502983703923843567936837374451735540968419076528771170197431451843209
                  }
      
                  function ALT_BN128_GROUP_ORDER_INVERSE() -> ret {
                        ret := 4759646384140481320982610724935209484903937857060724391493050186936685796471
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
                        uint256_x,
                        uint256_y,
                  ) -> ret {
                        let y_squared := mulmod(uint256_y, uint256_y, ALT_BN128_GROUP_ORDER())
                        let x_squared := mulmod(uint256_x, uint256_x, ALT_BN128_GROUP_ORDER())
                        let x_qubed := mulmod(x_squared, uint256_x, ALT_BN128_GROUP_ORDER())
                        let x_qubed_plus_three := addmod(x_qubed, 3, ALT_BN128_GROUP_ORDER())

                        ret := eq(y_squared, x_qubed_plus_three)
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
                        let exponent := uint256_exponent
                        for { } gt(exponent, ZERO()) { } {
                              if mod(exponent, 2) {
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

                  function isOnGroupOrder(num) -> ret {
                        ret := iszero(gt(num, sub(ALT_BN128_GROUP_ORDER(), ONE())))
                  }

                  function burnGas() {
                        let precompileParams := unsafePackPrecompileParams(
                              0, // input offset in words
                              4, // input length in words (x1, y1, x2, y2)
                              0, // output offset in words
                              2, // output length in words (x3, y3)
                              0  // No special meaning
                        )
                        let gasToPay := gas()
            
                        // Precompiles that do not have a circuit counterpart
                        // will burn the provided gas by calling this function.
                        precompileCall(precompileParams, gasToPay)
                  }

                  function overflowingSub(minuend, subtrahend) -> difference, overflowed {
                        difference := sub(minuend, subtrahend)
                        overflowed := or(gt(difference, minuend), gt(difference, subtrahend))
                    }
        
                    function getHighestHalfOfMultiplication(multiplicand, multiplier) -> ret {
                        ret := verbatim_2i_1o("mul_high", multiplicand, multiplier)
                    }
        
                    // https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithm
                    function REDC(lowest_half_of_T, higher_half_of_T) -> S {
                        let q := mul(lowest_half_of_T, ALT_BN128_GROUP_ORDER_INVERSE())
                        let a_high := sub(getHighestHalfOfMultiplication(q, ALT_BN128_GROUP_ORDER()), higher_half_of_T)
                        let a_low, overflowed := overflowingSub(lowest_half_of_T, mul(q, ALT_BN128_GROUP_ORDER()))
                        if overflowed {
                            a_high := sub(a_high, ONE())
                        }
                        S := a_high
                        if or(gt(a_high, ALT_BN128_GROUP_ORDER()), eq(a_high, ALT_BN128_GROUP_ORDER())) {
                            S := sub(a_high, ALT_BN128_GROUP_ORDER())
                        }
                    }
        
                    // Transforming into the Montgomery form -> REDC((a mod N)(R2 mod N))
                    function intoMontgomeryForm(a) -> ret {
                            let higher_half_of_a := getHighestHalfOfMultiplication(mod(a, ALT_BN128_GROUP_ORDER()), R2_mod_ALT_BN128_GROUP_ORDER())
                            let lowest_half_of_a := mul(mod(a, ALT_BN128_GROUP_ORDER()), R2_mod_ALT_BN128_GROUP_ORDER())
                            ret := REDC(lowest_half_of_a, higher_half_of_a)
                    }
        
                    // Transforming out of the Montgomery form -> REDC(a * R mod N)
                    function outOfMontgomeryForm(m) -> ret {
                            let higher_half_of_m := ZERO()
                            let lowest_half_of_m := m 
                            ret := REDC(lowest_half_of_m, higher_half_of_m)
                    }
        
                    // Multipling field elements in Montgomery form -> REDC((a * R mod N)(b * R mod N))
                    function montgomeryMul(multiplicand, multiplier) -> ret {
                        let higher_half_of_product := getHighestHalfOfMultiplication(multiplicand, multiplier)
                        let lowest_half_of_product := mul(multiplicand, multiplier)
                        ret := REDC(lowest_half_of_product, higher_half_of_product)
                    }

                  ////////////////////////////////////////////////////////////////
                  //                      FALLBACK
                  ////////////////////////////////////////////////////////////////

                  // Retrieve the coordinates from the calldata
                  let x1 := calldataload(0)
                  let y1 := calldataload(32)
                  let x2 := calldataload(64)
                  let y2 := calldataload(96)


                  if and(isInfinity(x1, y1), isInfinity(x2, y2)) {
                        // Infinity + Infinity = Infinity
                        mstore(0, ZERO())
                        mstore(32, ZERO())
                        return(0, 64)
                  }
                  if and(isInfinity(x1, y1), iszero(isInfinity(x2, y2))) {
                        // Infinity + P = P

                        // Ensure that the coordinates are between 0 and the group order.
                        if or(iszero(isOnGroupOrder(x2)), iszero(isOnGroupOrder(y2))) {
                              burnGas()
                              revert(0, 0)
                        }

                        // Ensure that the point is in the curve (Y^2 = X^3 + 3).
                        if iszero(pointIsInCurve(x2, y2)) {
                              burnGas()
                              revert(0, 0)
                        }

                        mstore(0, x2)
                        mstore(32, y2)
                        return(0, 64)
                  }
                  if and(iszero(isInfinity(x1, y1)), isInfinity(x2, y2)) {
                        // P + Infinity = P

                        // Ensure that the coordinates are between 0 and the group order.
                        if or(iszero(isOnGroupOrder(x1)), iszero(isOnGroupOrder(y1))) {
                              burnGas()
                              revert(0, 0)
                        }

                        // Ensure that the point is in the curve (Y^2 = X^3 + 3).
                        if iszero(pointIsInCurve(x1, y1)) {
                              burnGas()
                              revert(0, 0)
                        }

                        mstore(0, x1)
                        mstore(32, y1)
                        return(0, 64)
                  }

                  // Ensure that the coordinates are between 0 and the group order.
                  if or(iszero(isOnGroupOrder(x1)), iszero(isOnGroupOrder(y1)), iszero(isOnGroupOrder(x2)), iszero(isOnGroupOrder(y2))) {
                        burnGas()
                        revert(0, 0)
                  }

                  // Ensure that the points are in the curve (Y^2 = X^3 + 3).
                  if or(iszero(pointIsInCurve(x1, y1)), iszero(pointIsInCurve(x2, y2))) {
                        burnGas()
                        revert(0, 0)
                  }

                  if and(eq(x1, x2), eq(submod(0, y1, ALT_BN128_GROUP_ORDER()), y2)) {
                        // P + (-P) = Infinity

                        mstore(0, ZERO())
                        mstore(32, ZERO())
                        return(0, 64)
                  }
                  if and(eq(x1, x2), eq(y1, y2)) {
                        // P + P = 2P

                        // (3 * x1^2 + a) / (2 * y1)
                        let slope := divmod(mulmod(3, mulmod(x1, x1, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER()), addmod(y1, y1, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                        // x3 = slope^2 - 2 * x1
                        let x3 := submod(mulmod(slope, slope, ALT_BN128_GROUP_ORDER()), addmod(x1, x1, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                        // y3 = slope * (x1 - x3) - y1
                        let y3 := submod(mulmod(slope, submod(x1, x3, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER()), y1, ALT_BN128_GROUP_ORDER())

                        mstore(0, x3)
                        mstore(32, y3)
                        return(0, 64)
                  }
                  if and(eq(x1, x2), and(iszero(eq(y1, y2)), iszero(eq(y1, submod(0, y2, ALT_BN128_GROUP_ORDER()))))) {
                        burnGas()
                        revert(0, 0)
                  }

                  // P1 + P2 = P3

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
	}
}
