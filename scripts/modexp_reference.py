#! /usr/bin/python3
import math
from barret_reduction import barret_reduce
def modular_pow(base, exponent, modulus):
    if modulus == 1:
        return 0

    result = 1
    base %= modulus

    while exponent > 0:
        if exponent % 2 == 1:
            result = (result * base) % modulus
        exponent >>= 1
        base = barret_reduce(base*base, modulus) 
    return result

# Example usage:
base = 4
exponent = 2
modulus = 3
result = modular_pow(base, exponent, modulus)
expected = (base**exponent) % modulus
print(f"Expected: {expected}, got: {result}")
assert result == expected
