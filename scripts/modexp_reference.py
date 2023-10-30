#! /usr/bin/python3
import math
from barret_reduction import barret_reduce
def modular_pow(base, exponent, modulus):
    if modulus == 1:
        return 0

    result = 1
    base %= modulus
    
    while exponent > 0:
        print(f"face: {hex(result)}")
        print(f"dead: {hex(exponent)}")
        if exponent % 2 == 1:
            result = (result * base) % modulus
        exponent >>= 1
        base = barret_reduce(base*base, modulus) 
    return result

# Example usage:
base = 3
exponent = 115792089237316195423570985008687907853269984665640564039457584007908834671662
modulus = 115792089237316195423570985008687907853269984665640564039457584007908834671663
result = modular_pow(base, exponent, modulus)
expected = (pow(base, exponent, modulus)) 
print(f"Expected: {expected}, got: {result}")
assert result == expected
