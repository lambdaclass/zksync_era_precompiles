import math

GQUADDIVISOR = 20

def adjusted_exponent_length(length_of_EXPONENT, EXPONENT):
    if length_of_EXPONENT <= 32 and EXPONENT == 0:
        return 0
    elif length_of_EXPONENT <= 32 and EXPONENT:
        aux_exp = EXPONENT
        index_of_highest_bit = 0
        i = 0
        while aux_exp > 0:
            aux_exp >>= 1
            if aux_exp & 1:
                index_of_highest_bit = i
            i += 1
        return index_of_highest_bit + 1
    elif length_of_EXPONENT > 32:
        return 8 * (length_of_EXPONENT - 32)

def mult_complexity(x):
    if x <= 64: return x ** 2
    elif x <= 1024: return x ** 2 // 4 + 96 * x - 3072
    else: return x ** 2 // 16 + 480 * x - 199680

def modexpGasCost(length_of_BASE, length_of_EXPONENT, length_of_MODULUS, EXPONENT):
    return math.floor(mult_complexity(max(length_of_MODULUS, length_of_BASE)) * max(adjusted_exponent_length(length_of_EXPONENT, EXPONENT), 1) / GQUADDIVISOR)

def main():
    length_of_BASE = 1
    length_of_EXPONENT = 32
    length_of_MODULUS = 32
    EXPONENT = 115792089237316195423570985008687907853269984665640564039457584007908834671662
    print(modexpGasCost(length_of_BASE, length_of_EXPONENT, length_of_MODULUS, EXPONENT))

if __name__ == '__main__':
    main()