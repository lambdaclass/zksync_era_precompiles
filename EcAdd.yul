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

                  // Retrieve the coordinates from the calldata
                  let x1 := calldataload(0)
                  let y1 := calldataload(32)
                  let x2 := calldataload(64)
                  let y2 := calldataload(96)

                  // Retrieve the curve parameters from the calldata
                  let a := calldataload(128)
                  let b := calldataload(160)

                  // Retrieve the field modulus from the calldata
                  let p := calldataload(192)

                  // Ensure p is valid

                  // Ensure that the points are in the curve

                  // Ensure that the point is in the right subgroup (if needed)

                  // Add the points

                  // Ensure that the resulting point is in the curve

                  // Return the result
		}
	}
}
