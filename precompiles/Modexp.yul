object "ModExp" {
	code { }
	object "ModExp_deployed" {
		code {
            ////////////////////////////////////////////////////////////////
            //                      CONSTANTS
            ////////////////////////////////////////////////////////////////

            function WORD_SIZE() -> word {
                word := 0x20
            }

            //////////////////////////////////////////////////////////////////
            //                      HELPER FUNCTIONS
            //////////////////////////////////////////////////////////////////

            function exponentIsZero(exponent_limbs, exponent_pointer) -> isZero {
                isZero := 0
                let next_limb_pointer := exponent_pointer
                for { let limb_number := 0 } lt(limb_number, exponent_limbs) { limb_number := add(limb_number, 1) } {
                    let limb := mload(next_limb_pointer)
                    isZero := or(isZero, limb)
                    if isZero {
                        break
                    }
                    next_limb_pointer := add(next_limb_pointer, WORD_SIZE())
                }
                isZero := iszero(isZero)
            }

            ////////////////////////////////////////////////////////////////
            //                      FALLBACK
            ////////////////////////////////////////////////////////////////

            let base_length := calldataload(0)
            let exponent_length := calldataload(32)
            let modulus_length := calldataload(64)

            if lt(calldatasize(), 96) {
                return(0, 0)
            }

            // Handle a special case when both the base and mod length is zero
            if and(iszero(base_length), iszero(modulus_length)) {
                return(0, 0)
            }

            let base_pointer := 96
            let base_padding := sub(WORD_SIZE(), base_length)
            let padded_base_pointer := add(96, base_padding)
            calldatacopy(padded_base_pointer, base_pointer, base_length)
            let base := mload(base_pointer)
            
            // As the exponent length could be more than 32 bytes we
            // decided to represent the exponent with limbs. Because
            // of that, we keep track of a calldata pointer and a memory 
            // pointer.
            //
            // The calldata pointer keeps track of the real exponent length
            // (which could not be divisible by the word size).
            // The memory pointer keeps track of the adjusted exponent length
            // (which is always divisible by the word size).
            //
            // There is a special case to handle when the leftmost limb of 
            // the exponent has less than 32 bytes in the calldata (e.g. if 
            // the calldata has 33 bytes in the calldata, in our limbs 
            // representation it should have 64 bytes). Here is where it
            // it could be a difference between the real exponent length and
            // the adjusted exponent length.
            //
            // For the amount of limbs, if the exponent length is divisible 
            // by the word size, then we just divide it by the word size. 
            // If not, we divide and then add the remainder limb (this is
            // the case when the leftmost limb has less than 32 bytes).
            //
            // In the special case, the memory exponent pointer and the
            // calldata exponent pointer are outphased. That's why after
            // loading the exponent from the calldata, we still need to 
            // compute two pointers for the modulus.
            console_log(2)
            let calldata_exponent_pointer := add(base_pointer, base_length)
            let memory_exponent_pointer := add(base_pointer, WORD_SIZE())
            let exponent_limbs := 0
            switch iszero(mod(exponent_length, WORD_SIZE()))
            case 0 {
                exponent_limbs := add(div(exponent_length, WORD_SIZE()), 1)
            }
            case 1 {
                exponent_limbs := div(exponent_length, WORD_SIZE())
            }
            // The exponent expected length given the amount of limbs.
            let adjusted_exponent_length := mul(WORD_SIZE(), exponent_limbs)
            let calldata_next_limb_pointer := calldata_exponent_pointer
            let memory_next_limb_pointer := memory_exponent_pointer
            for { let limb_number := 0 } lt(limb_number, exponent_limbs) { limb_number := add(limb_number, 1) } {
                // The msb of the leftmost limb could be one.
                // This left-pads with zeros the leftmost limbs to achieve 32 bytes.
                if iszero(limb_number) {
                    // The amount of zeros to left-pad.
                    let padding := sub(adjusted_exponent_length, exponent_length)
                    // This is either 0 or > 0 if there are any zeros to pad.
                    let padded_exponent_pointer := add(memory_exponent_pointer, padding)
                    let amount_of_bytes_for_first_limb := sub(WORD_SIZE(), padding)
                    calldatacopy(padded_exponent_pointer, calldata_exponent_pointer, amount_of_bytes_for_first_limb)
                    calldata_next_limb_pointer := add(calldata_exponent_pointer, amount_of_bytes_for_first_limb)
                    memory_next_limb_pointer := add(memory_exponent_pointer, WORD_SIZE())
                    continue
                }
                calldatacopy(memory_next_limb_pointer, calldata_next_limb_pointer, WORD_SIZE())
                calldata_next_limb_pointer := add(calldata_next_limb_pointer, WORD_SIZE())
                memory_next_limb_pointer := add(memory_next_limb_pointer, WORD_SIZE())
            }

            let calldata_modulus_pointer := add(calldata_exponent_pointer, exponent_length)
            let memory_modulus_pointer := add(memory_exponent_pointer, adjusted_exponent_length)
            calldatacopy(add(memory_modulus_pointer, sub(WORD_SIZE(), modulus_length)), calldata_modulus_pointer, modulus_length)

            let modulus := mload(memory_modulus_pointer)

            // 1^exponent % modulus = 1
            if eq(base, 1) {
                mstore(0, 1)
                let unpadding := sub(WORD_SIZE(), modulus_length)
                return(unpadding, modulus_length)
            }

            // base^exponent % 0 = 0
            if iszero(modulus) {
                mstore(0, 0)
                return(0, modulus_length)
            }

            // base^0 % modulus = 1
            if exponentIsZero(exponent_length, memory_exponent_pointer) {
                mstore(0, 1)
                let unpadding := sub(WORD_SIZE(), modulus_length)
                return(unpadding, modulus_length)
            }

            // 0^exponent % modulus = 0
            if iszero(base) {
                mstore(0, 0)
                return(0, modulus_length)
            }

            switch eq(exponent_limbs, 1)
            // Special case of one limb, we load the hole word.
            case 1 {
                let pow := 1
                // If we have one limb, then the exponent has 32 bytes and it is
                // located in 0x
                let exponent := mload(memory_exponent_pointer)
                base := mod(base, modulus)
                for { let i := 0 } gt(exponent, 0) { i := add(i, 1) } {
                    if eq(mod(exponent, 2), 1) {
                        pow := mulmod(pow, base, modulus)
                    }
                    exponent := shr(1, exponent)
                    base := mulmod(base, base, modulus)
                }
    
                mstore(0, pow)
                let unpadding := sub(WORD_SIZE(), modulus_length)
                return(unpadding, modulus_length)
            }
            case 0 {
                let pow := 1
                base := mod(base, modulus)
                let next_limb_pointer := memory_exponent_pointer
                for { let limb_number := 0 } lt(limb_number, exponent_limbs) { limb_number := add(limb_number, 1) } {
                    let current_limb := mload(next_limb_pointer)
                    for { let i := 0 } gt(current_limb, 0) { i := add(i, 1) } {
                        if eq(mod(current_limb, 2), 1) {
                            pow := mulmod(pow, base, modulus)
                        }
                        current_limb := shr(1, current_limb)
                        base := mulmod(base, base, modulus)
                    }
                    next_limb_pointer := add(next_limb_pointer, WORD_SIZE())
                }
                mstore(0, pow)
                let unpadding := sub(WORD_SIZE(), modulus_length)
                return(unpadding, modulus_length)
            }
		}
	}
}
