object "EcPairing" {
	code { }
	object "EcPairing_deployed" {
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

			function THREE() -> three {
                three := 0x3
            }

			function NINE() -> nine {
                nine := 0x9
            }

			function PAIR_LENGTH() -> pairLength {
				pairLength := 192
			}

			function Q() -> q {
				q := 21888242871839275222246405745257275088548364400416034343698204186575808495617
			}

			function P() -> p {
				p := 21888242871839275222246405745257275088696311157297823662689037894645226208583
			}

			function G1_GENERATOR() -> x, y {
				x := 1
				y := 2
			}

			function G2_GENERATOR(i) -> ix, x, iy, y {
				ix := 11559732032986387107991004021392285783925812861821192530917403151452391805634
				x := 10857046999023057135944570762232829481370756359578518086990519993285655852781
				iy := 4082367875863433681332203403145435568316851327593401208105741076214120093531
				y := 8495653923123431417604973247489272438418190587263600148770280649306958101930
			}

			function ATE_LOOP_COUNT() -> count {
				count := 29793968203157093288
			}

			function LOG_ATE_LOOP_COUNT() -> log_count {
				log_count := 63
			}

			// ////////////////////////////////////////////////////////////////
			//                      HELPER FUNCTIONS
			// ////////////////////////////////////////////////////////////////

			/// @dev Executes the `precompileCall` opcode.
			function precompileCall(precompileParams, gasToBurn) -> ret {
				// Compiler simulation for calling `precompileCall` opcode
				ret := verbatim_2i_1o("precompile", precompileParams, gasToBurn)
			}

			function burnGas() {
				// Precompiles that do not have a circuit counterpart
				// will burn the provided gas by calling this function.
				precompileCall(0, gas())
		  	}

			function powmod(
				base,
				exponent,
				modulus,
			) -> pow {
				pow := 1
				let base := mod(base, modulus)
				let exponent := exponent
				for { } gt(exponent, ZERO()) { } {
					if eq(mod(exponent, 2), ONE()) {
						pow := mulmod(pow, base, modulus)
					}
					exponent := shr(1, exponent)
					base := mulmod(base, base, modulus)
				}
			}

			function invmod(base, modulus) -> inv {
				inv := powmod(base, sub(modulus, 2), modulus)
			}

			function divmod(dividend, divisor, modulus) -> quotient {
				quotient := mulmod(dividend, invmod(divisor, modulus), modulus)
			}

			// G1 -> Y^2 = X^3 + 3
			function pointIsOnG1(x, y) -> ret {
				let y_squared := mulmod(y, y, P())
				let x_squared := mulmod(x, x, P())
				let x_qubed := mulmod(x_squared, x, P())
				let x_qubed_plus_three := addmod(x_qubed, THREE(), P())

				ret := eq(y_squared, x_qubed_plus_three)
			}

			// G2 -> Y^2 = X^3 + 3/(i+9)
			//    -> (iy + y)^2 = (ix + x)^3 + 3/(i+9)
			function pointIsOnG2(ix, x, iy, y) -> ret {
				// let y_squared := mulmod(y, y, P())
				// let x_squared := mulmod(x, x, P())
				// let x_qubed := mulmod(x_squared, x, P())

				// let i_times_nine := addmod(i, NINE(), P())
				// let three_over_i_times_nine := divmod(THREE(), i_times_nine, P())

				// let x_qubed_plus_three_over_i_times_nine := addmod(x_qubed, three_over_i_times_nine, P())

				// ret := eq(y_squared, x_qubed_plus_three_over_i_times_nine)
			}

			function isG1Infinity(x, y) -> ret {
				ret := and(iszero(x), iszero(y))
			}

			function isG2Infinity(ix, x, iy, y) -> ret {
				ret := and(iszero(ix), iszero(x), iszero(iy), iszero(y))
			}

			// function finalExponentiation(...) {

			// }

			// def miller_loop(Q, P):
			// 	if Q is None or P is None:
			// 		return FQ12.one()
			// 	R = Q
			// 	f = FQ12.one()
			// 	for i in range(log_ate_loop_count, -1, -1):
			// 		f = f * f * linefunc(R, R, P)
			// 		R = double(R)
			// 		if ate_loop_count & (2**i):
			// 			f = f * linefunc(R, Q, P)
			// 			R = add(R, Q)
			// 	# assert R == multiply(Q, ate_loop_count)
			// 	Q1 = (Q[0] ** field_modulus, Q[1] ** field_modulus)
			// 	# assert is_on_curve(Q1, b12)
			// 	nQ2 = (Q1[0] ** field_modulus, -Q1[1] ** field_modulus)
			// 	# assert is_on_curve(nQ2, b12)
			// 	f = f * linefunc(R, Q1, P)
			// 	R = add(R, Q1)
			// 	f = f * linefunc(R, nQ2, P)
			// 	# R = add(R, nQ2) This line is in many specifications but it technically does nothing
			// 	return f ** ((field_modulus ** 12 - 1) // curve_order)
			// function miller(g1_x, g1_y, g2_ix, g1_x, g2_iy, g2_x) {
			// 	for { let i := LOG_ATE_LOOP_COUNT() } gt(i, ZERO()) { i := sub(i, 1) } {
			// 		f := mulFQ12()
			// 	}
			// }

			function checkPairing(k) -> ret {
		  		let inputSize := calldatasize()

				let acc := ONE()
				for { let i := 0 } lt(i, inputSize) { i := add(i, PAIR_LENGTH()) } {
					let g1_x := mload(i)
					let g1_y := mload(add(i, 32))

					if isG1Infinity(g1_x, g1_y) {
						continue
					}

					// if or(iszero(isOnG1Group(g1_x)), iszero(isOnG1Group(g1_y))) {
					// 	burnGas()
					// }

					let g2_ix := mload(add(i, 64))
					let g2_x := mload(add(i, 96))
					let g2_iy := mload(add(i, 128))
					let g2_y := mload(add(i, 160))

					if isG2Infinity(g2_ix, g2_x, g2_iy, g2_y) {
						continue
					}

					if isG1Infinity(g1_x, g1_y) {
						continue
					}

					// if or(iszero(isOnG2Group(g2_ix, g2_x)), iszero(isOnG2Group(g2_iy, g2_y))) {
					// 	burnGas()
					// }

					// acc.Mul(acc, miller(g1_x, g1_y, g2_ix, g2_x, g2_iy, g2_y))
				}
				// return eq(finalExponentiation(acc), ONE())
			}

			////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////

		  	let inputSize := calldatasize()

			// Empty input is valid and results in returning one.
		  	if eq(inputSize, ZERO()) {
				mstore(0, ONE())
				return(0, 32)
			}

			// If the input length is not a multiple of 192, the call fails.
            if mod(inputSize, PAIR_LENGTH()) {
                // Bad pairing input
				burnGas()
            }

			// Calldata "parsing"
			for { let i := 0 } lt(i, inputSize) { i := add(i, PAIR_LENGTH()) } {
				/* G1 */
				calldatacopy(i, i, 32) // x
				calldatacopy(add(i, 32), add(i, 32), 32) // y

				let g1_x := mload(i)
				let g1_y := mload(add(i, 32))

				if iszero(pointIsOnG1(g1_x, g1_y)) {
					burnGas()
				}

				/* G2 */
				let g2_ix_offset := add(i, 64)
				let g2_x_offset := add(i, 96)
				let g2_iy_offset := add(i, 128)
				let g2_y_offset := add(i, 160)

				calldatacopy(g2_ix_offset, g2_ix_offset, 32)
				calldatacopy(g2_x_offset, g2_x_offset, 32)
				calldatacopy(g2_iy_offset, g2_iy_offset, 32)
				calldatacopy(g2_y_offset, g2_y_offset, 32)

				let g2_ix := mload(g2_ix_offset)
				let g2_x := mload(g2_x_offset)
				let g2_iy := mload(g2_iy_offset)
				let g2_y := mload(g2_y_offset)

				if iszero(pointIsOnG2(g2_ix, g2_x, g2_iy, g2_y)) {
					burnGas()
				}
			}

			let k := div(inputSize, PAIR_LENGTH())

			// Return one if log_P1(a1) * log_P2(b1) + ... + log_P1(ak) * log_P2(bk) = 0
			if checkPairing(k) {
				mstore(0, ONE())
				return(0, 32)
			}

			// Return zero otherwise
			mstore(0, ZERO())
			return(0, 32)
		}
	}
}
