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

                  function TWO() -> two {
                        two := 0x2
                  }

                  function THREE() -> three {
                        three := 0x3
                  }

                  // Group order of alt_bn128, see https://eips.ethereum.org/EIPS/eip-196
                  function ALT_BN128_GROUP_ORDER() -> ret {
                        ret := 21888242871839275222246405745257275088696311157297823662689037894645226208583
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
                        let x_qubed_plus_three := addmod(x_qubed, THREE(), ALT_BN128_GROUP_ORDER())

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
                        }
                        if iszero(isInfinity(sint256_x, sint256_y)) {
                              // (3 * sint256_x^2 + a) / (2 * sint256_y)
                              let slope := divmod(mulmod(3, mulmod(sint256_x, sint256_x, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER()), addmod(sint256_y, sint256_y, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                              // x = slope^2 - 2 * x
                              x := submod(mulmod(slope, slope, ALT_BN128_GROUP_ORDER()), addmod(sint256_x, sint256_x, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                              // y = slope * (sint256_x - x) - sint256_y
                              y := submod(mulmod(slope, submod(sint256_x, x, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER()), sint256_y, ALT_BN128_GROUP_ORDER())
                        }
                  }

                  function isOnGroupOrder(num) -> ret {
                        ret := iszero(gt(num, sub(ALT_BN128_GROUP_ORDER(), ONE())))
                  }

                  function burnGas() {
                        let precompileParams := unsafePackPrecompileParams(
                              0, // input offset in words
                              3, // input length in words (x, y, scalar)
                              0, // output offset in words
                              2, // output length in words (x2, y2)
                              0  // No special meaning
                        )
                        let gasToPay := gas()
            
                        // Precompiles that do not have a circuit counterpart
                        // will burn the provided gas by calling this function.
                        precompileCall(precompileParams, gasToPay)
                  }

                  function lsbIsOne(x) -> ret {
                        ret := eq(mod(x, 2), 1)
                  }

                  ////////////////////////////////////////////////////////////////
                  //                      FALLBACK
                  ////////////////////////////////////////////////////////////////

                  // Retrieve the coordinates from the calldata
                  let x := calldataload(0)
                  let y := calldataload(32)
                  let scalar := calldataload(64)

                  if isInfinity(x, y) {
                        // Infinity * scalar = Infinity
                        mstore(0, ZERO())
                        mstore(32, ZERO())
                        return(0, 64)
                  }

                  // Ensure that the coordinates are between 0 and the group order.
                  if or(iszero(isOnGroupOrder(x)), iszero(isOnGroupOrder(y))) {
                        burnGas()
                        revert(0, 0)
                  }

                  // Ensure that the point is in the curve (Y^2 = X^3 + 3).
                  if iszero(pointIsInCurve(x, y)) {
                        burnGas()
                        revert(0, 0)
                  }

                  if eq(scalar, ZERO()) {
                        // P * 0 = Infinity
                        mstore(0, ZERO())
                        mstore(32, ZERO())
                        return(0, 64)
                  }
                  if eq(scalar, ONE()) {
                        // P * 1 = P
                        mstore(0, x)
                        mstore(32, y)
                        return(0, 64)
                  }
                  if eq(scalar, TWO()) {
                        let x2, y2 := double(x, y)
                        mstore(0, x2)
                        mstore(32, y2)
                        return(0, 64)
                  }

                  let x2 := x
                  let y2 := y
                  let x_res := ZERO()
                  let y_res := ZERO()
                  for {} iszero(eq(scalar, ZERO())) {} {
                        if lsbIsOne(scalar) {
                              if and(isInfinity(x_res, y_res), isInfinity(x2, y2)) {
                                    // Infinity + Infinity = Infinity
                                    x_res := ZERO()
                                    y_res := ZERO()
                                    
                                    x2, y2 := double(x2, y2)
                                    // Check next bit
                                    scalar := shr(1, scalar)
                                    continue
                              }
                              if and(isInfinity(x_res, y_res), iszero(isInfinity(x2, y2))) {
                                    // Infinity + P = P
                                    x_res := x2
                                    y_res := y2

                                    x2, y2 := double(x2, y2)
                                    // Check next bit
                                    scalar := shr(1, scalar)
                                    continue
                              }
                              if and(iszero(isInfinity(x_res, y_res)), isInfinity(x2, y2)) {
                                    // P + Infinity = P

                                    // Check next bit
                                    scalar := shr(1, scalar)
                                    continue
                              }
                              if and(eq(x_res, x2), eq(submod(0, y_res, ALT_BN128_GROUP_ORDER()), y2)) {
                                    // P + (-P) = Infinity
                                    x_res := ZERO()
                                    y_res := ZERO()

                                    x2, y2 := double(x2, y2)
                                    // Check next bit
                                    scalar := shr(1, scalar)
                                    continue
                              }
                              if and(eq(x_res, x2), eq(y_res, y2)) {
                                    // P + P = 2P
                                    x_res, y_res := double(x_res, y_res)
                                    
                                    x2, y2 := double(x2, y2)
                                    // Check next bit
                                    scalar := shr(1, scalar)
                                    continue
                              }

                              // P1 + P2 = P3
                              
                              // (y2 - y1) / (x2 - x1)
                              let slope := divmod(submod(y2, y_res, ALT_BN128_GROUP_ORDER()), submod(x2, x_res, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                              // x3 = slope^2 - x1 - x2
                              let x3 := submod(mulmod(slope, slope, ALT_BN128_GROUP_ORDER()), addmod(x_res, x2, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER())
                              // y3 = slope * (x1 - x3) - y1
                              let y3 := submod(mulmod(slope, submod(x_res, x3, ALT_BN128_GROUP_ORDER()), ALT_BN128_GROUP_ORDER()), y_res, ALT_BN128_GROUP_ORDER())
                              
                              x_res := x3
                              y_res := y3
                        }

                        x2, y2 := double(x2, y2)
                        // Check next bit
                        scalar := shr(1, scalar)
                  }

                  mstore(0, x_res)
                  mstore(32, y_res)
                  return(0, 64)
		}
	}
}
