object "Modexp" {
	code { }
	object "Modexp_deployed" {
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

            ////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////

            let base := calldataload(0)
            let exponent := calldataload(32)
            let modulus := calldataload(64)

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
            return(0, 32)
		}
	}
}
