object "ModExpCheaper" {
    code { }
    object "ModExpCheaper_deployed" {
        code {
            // CONSTANTS

            function BASE_CALLDATA_PTR() -> baseCalldataPtr {
                baseCalldataPtr := 96
            }

            function EXPONENT_CALLDATA_PTR() -> exponentCalldataPtr {
                exponentCalldataPtr := 128
            }

            function MODULUS_CALLDATA_PTR() -> modulusCalldataPtr {
                modulusCalldataPtr := 160
            }

            // FALLBACK

            // Retrieve the coordinates from the calldata
            let base := calldataload(BASE_CALLDATA_PTR())
            let exponent := calldataload(EXPONENT_CALLDATA_PTR())
            let modulus := calldataload(MODULUS_CALLDATA_PTR())

            // Note: This check covers the case where length of the modulo is zero or one.
            // base^exponent % 0 = 0 || base^exponent % 1 = 0 || 0^exponent % modulus = 0
            if or(lt(modulus, 2), iszero(base)) {
                mstore(0, 0)
                return(0, 32)
            }

            // 1^exponent % modulus = 1 || base^0 % modulus = 1
            if or(eq(base, 1), iszero(exponent)) {
                mstore(0, 1)
                return(0, 32)
            }

            let pow := 1
            base := mod(base, modulus)
            for {} gt(exponent, 0) {} {
                if eq(mod(exponent, 2), 1) {
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
