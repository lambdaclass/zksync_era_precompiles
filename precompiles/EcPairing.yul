object "EcPairing" {
	code { }
	object "EcPairing_deployed" {
		code {
			// Note: this check assumes that the curve is bn256, this is not final and could not be right in the future.
            if not(eq(mod(calldatasize(), 0xc0), 0)) {
                // Bad pairing input
                revert(0,0)
            }
		}
	}
}
