---
eip: 198
title: Big integer modular exponentiation
author: Vitalik Buterin (@vbuterin)
status: Final
type: Standards Track
category: Core
created: 2017-01-30
---

> Source: https://github.com/ethereum/EIPs

# Parameters

* `GQUADDIVISOR: 20`

# Specification

At address 0x00......05, add a precompile that expects input in the following format:

    <length_of_BASE> <length_of_EXPONENT> <length_of_MODULUS> <BASE> <EXPONENT> <MODULUS>
    
Where every length is a 32-byte left-padded integer representing the number of bytes to be taken up by the next value. Call data is assumed to be infinitely right-padded with zero bytes, and excess data is ignored. Consumes `floor(mult_complexity(max(length_of_MODULUS, length_of_BASE)) * max(ADJUSTED_EXPONENT_LENGTH, 1) / GQUADDIVISOR)` gas, and if there is enough gas, returns an output `(BASE**EXPONENT) % MODULUS` as a byte array with the same length as the modulus.

`ADJUSTED_EXPONENT_LENGTH` is defined as follows.

* If `length_of_EXPONENT <= 32`, and all bits in `EXPONENT` are 0, return 0
* If `length_of_EXPONENT <= 32`, then return the index of the highest bit in `EXPONENT` (eg. 1 -> 0, 2 -> 1, 3 -> 1, 255 -> 7, 256 -> 8).
* If `length_of_EXPONENT > 32`, then return `8 * (length_of_EXPONENT - 32)` plus the index of the highest bit in the first 32 bytes of `EXPONENT` (eg. if `EXPONENT = \x00\x00\x01\x00.....\x00`, with one hundred bytes, then the result is 8 * (100 - 32) + 253 = 797). If all of the first 32 bytes of `EXPONENT` are zero, return exactly `8 * (length_of_EXPONENT - 32)`.

`mult_complexity` is a function intended to approximate the difficulty of Karatsuba multiplication (used in all major bigint libraries) and is defined as follows.

```
def mult_complexity(x):
    if x <= 64: return x ** 2
    elif x <= 1024: return x ** 2 // 4 + 96 * x - 3072
    else: return x ** 2 // 16 + 480 * x - 199680
```

For example, the input data:

    0000000000000000000000000000000000000000000000000000000000000001
    0000000000000000000000000000000000000000000000000000000000000020
    0000000000000000000000000000000000000000000000000000000000000020
    03
    fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2e
    fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f
    
Represents the exponent `3**(2**256 - 2**32 - 978) % (2**256 - 2**32 - 977)`. By Fermat's little theorem, this equals 1, so the result is:

    0000000000000000000000000000000000000000000000000000000000000001
    
Returned as 32 bytes because the modulus length was 32 bytes. The `ADJUSTED_EXPONENT_LENGTH` would be 255, and the gas cost would be `mult_complexity(32) * 255 / 20 = 13056` gas (note that this is ~8 times the cost of using the EXP opcode to compute a 32-byte exponent). A 4096-bit RSA exponentiation would cost `mult_complexity(512) * 4095 / 100 = 22853376` gas in the worst case, though RSA verification in practice usually uses an exponent of 3 or 65537, which would reduce the gas consumption to 5580 or 89292, respectively.

This input data:

    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000020
    0000000000000000000000000000000000000000000000000000000000000020
    fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2e
    fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f
    
Would be parsed as a base of 0, exponent of `2**256 - 2**32 - 978` and modulus of `2**256 - 2**32 - 977`, and so would return 0. Notice how if the length_of_BASE is 0, then it does not interpret _any_ data as the base, instead immediately interpreting the next 32 bytes as EXPONENT.

This input data:

    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000020
    ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe
    fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd
    
Would parse a base length of 0, an exponent length of 32, and a modulus length of `2**256 - 1`, where the base is empty, the exponent is `2**256 - 2` and the modulus is `(2**256 - 3) * 256**(2**256 - 33)` (yes, that's a really big number). It would then immediately fail, as it's not possible to provide enough gas to make that computation.

This input data:

    0000000000000000000000000000000000000000000000000000000000000001
    0000000000000000000000000000000000000000000000000000000000000002
    0000000000000000000000000000000000000000000000000000000000000020
    03
    ffff
    8000000000000000000000000000000000000000000000000000000000000000
    07

Would parse as a base of 3, an exponent of 65535, and a modulus of `2**255`, and it would ignore the remaining 0x07 byte.

This input data:

    0000000000000000000000000000000000000000000000000000000000000001
    0000000000000000000000000000000000000000000000000000000000000002
    0000000000000000000000000000000000000000000000000000000000000020
    03
    ffff
    80
    
Would also parse as a base of 3, an exponent of 65535 and a modulus of `2**255`, as it attempts to grab 32 bytes for the modulus starting from 0x80 - but there is no further data, so it right-pads it with 31 zero bytes.

# Rationale

This allows for efficient RSA verification inside of the EVM, as well as other forms of number theory-based cryptography. Note that adding precompiles for addition and subtraction is not required, as the in-EVM algorithm is efficient enough, and multiplication can be done through this precompile via `a * b = ((a + b)**2 - (a - b)**2) / 4`.

The bit-based exponent calculation is done specifically to fairly charge for the often-used exponents of 2 (for multiplication) and 3 and 65537 (for RSA verification).

# Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).