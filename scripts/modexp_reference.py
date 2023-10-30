#! /usr/bin/python3
def modular_pow(base, exponent, modulus):
    if modulus == 1:
        return 0

    result = 1
    base %= modulus

    while exponent > 0:
        print(f"Exponent: {hex(exponent)}, result: {hex(result)}, base: {hex(base)}")
        if exponent % 2 == 1:
            result = (result * base) % modulus
        exponent >>= 1
        base = (base * base) % modulus

    return result

# Example usage:
base = 390298093899999943928098409885853890809480289080848908498808490890809858888590
exponent = 328010176336108753607932954472681594880
modulus = 328083392909999939299399093209090192209
result = modular_pow(base, exponent, modulus)
