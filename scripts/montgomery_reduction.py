import math

# 2^256
R = 115792089237316195423570985008687907853269984665640564039457584007913129639936
R_PRIME = 20988524275117001072002809824448087578619730785600314334253784976379291040311
# R^2 = (2^256)^2 = 2^512
R2 = 13407807929942597099574024998205846127479365820592393377723561443721764030073546976801874298166903427690031858186486050853753882811946569946433649006084096
# R^3 = (2^256)^3 = 2^768
R3 = 1552518092300708935148979488462502555256886017116696611139052038026050952686376886330878408828646477950487730697131073206171580044114814391444287275041181139204454976020849905550265285631598444825262999193716468750892846853816057856
# R3 % N
R3_MOD_N = 14921786541159648185948152738563080959093619838510245177710943249661917737183
# Fp
N = 21888242871839275222246405745257275088696311157297823662689037894645226208583
# R2 % N
R2_MOD_N = 3096616502983703923843567936837374451735540968419076528771170197431451843209
# N' -> NN' ≡ −1 mod R
N_PRIME = 111032442853175714102588374283752698368366046808579839647964533820976443843465

# Extended euclidean algorithm to find modular inverses for integers.
def prime_field_inv(a, modulus):
    if a == 0:
        return 0
    lm, hm = 1, 0
    low, high = a % modulus, modulus
    while low > 1:
        r = high // low
        nm, new = hm - lm * r, high - low * r
        lm, low, hm, high = nm, new, lm, low
    return lm % modulus

def binary_extended_euclidean_algorithm(a, modulus):
    modulus_has_spare_bits = modulus >> 255 == 0

    u = a
    v = modulus
    b = R2_MOD_N
    c = 0

    while u != 1 and v != 1:
        while u & 1 == 0:
            u >>= 1
            if b & 1 == 0:
                b >>= 1
            else:
                b += modulus
                carry = b >> 256
                b >>= 1
                if not modulus_has_spare_bits and carry > 0:
                    b |= 1 << 255

        while v & 1 == 0:
            v >>= 1
            if c & 1 == 0:
                c >>= 1
            else:
                c += modulus 
                carry = c >> 256
                c >>= 1
                if not modulus_has_spare_bits and carry > 0:
                    c |= 1 << 255
        if v <= u:
            u -= v
            if b < c:
                b += modulus
            b -= c
        else:
            v -= u
            if c < b:
                c += modulus
            c -= b

    if u == 1:
        return b

    return c
# Montgomery reduction algorithm
def REDC(n):
    m = (n % R) * N_PRIME % R
    t = ((m * N) + n) // R
    if t >= N:
        t -= N
    return t

# REDC((a mod N)(R2 mod N))
def into_montgomery_form(a):
    return REDC((a % N) * R2_MOD_N)

# REDC(aR mod N)
def from_montgomery_form(a_mont):
    return REDC(a_mont)

# REDC((aR mod N)(bR mod N))
def montgomery_multiplication(a_mont, b_mont):
    return REDC(a_mont * b_mont)

# REDC((a mod N)(R2 mod N))
def into_montgomery_form_naive(a):
    return a * R % N

def montgomery_modular_exponentiation(base, exponent):
    pow = into_montgomery_form(1)
    while exponent > 0:
        if exponent % 2 == 1:
            pow = montgomery_multiplication(pow, base)
        exponent = exponent >> 1 
        base = montgomery_multiplication(base, base)
    return pow

def montgomery_modular_inverse(a):
    a_inv = prime_field_inv(a, N)
    return REDC(a_inv * R3_MOD_N)

def optimized_montgomery_modular_inverse(a):
    return binary_extended_euclidean_algorithm(a, N)

def main():
    a = 3
    a_mont = into_montgomery_form(a)
    print(a)
    print(hex(a_mont))
    print(from_montgomery_form(a_mont))

    a_prod = a * a
    print(a_prod)
    a_prod_mont = montgomery_multiplication(a_mont, a_mont)
    print(hex(a_prod_mont))
    print(from_montgomery_form(a_prod_mont))

    print(a**3 % N)
    a_pow_3 = montgomery_modular_exponentiation(a_mont, 3)
    print(hex(a_pow_3))
    print(from_montgomery_form(a_pow_3))

    print(a // a)
    a_inv_mont = montgomery_modular_inverse(a_mont)
    a_times_a_inv = montgomery_multiplication(a_mont, a_inv_mont)
    print(hex(a_times_a_inv))
    print(from_montgomery_form(a_times_a_inv))

if __name__ == '__main__':
    main()
