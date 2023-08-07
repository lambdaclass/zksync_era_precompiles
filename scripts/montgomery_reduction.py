import math

# 2^256
R = 115792089237316195423570985008687907853269984665640564039457584007913129639936
R_PRIME = 20988524275117001072002809824448087578619730785600314334253784976379291040311
# R^2 = (2^256)^2 = 2^512
R2 = 13407807929942597099574024998205846127479365820592393377723561443721764030073546976801874298166903427690031858186486050853753882811946569946433649006084096
# Fp
N = 21888242871839275222246405745257275088696311157297823662689037894645226208583
# R2 % N
R2_MOD_N = 3096616502983703923843567936837374451735540968419076528771170197431451843209
# N' -> NN' ≡ −1 mod R
N_PRIME = 4759646384140481320982610724935209484903937857060724391493050186936685796471

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

# Montgomery reduction algorithm
def REDC(n):
    assert(math.gcd(R, N) == 1)
    assert(N * N_PRIME % R == 1)
    q = (n % R) * N_PRIME % R
    a = ((q * N) - n) // R
    print("a1: ", a)
    if a >= N:
        a -= N
        print("a2: ", a)
    return a

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

# Suma en forma de Montgomery
# a + b -> a % N + b % N -> (a + b) % N
# a + b -> a * R % N + b * R % N -> (a + b) * R % N

# Multiplicación en forma de Montgomery
# a * b -> a % N * b % N -> (a * b) % N
# a * b -> a * R % N * b * R % N -> (a + b) * R^2 % N -> (a + b) * R^2 % N * R^-1

def main():
    a = 3
    #print(a)
    a_mont = into_montgomery_form(a)
    #print(hex(a_mont))
    #print(from_montgomery_form(a_mont))

    a_prod = a * a
    print(a_prod)
    a_prod_mont = montgomery_multiplication(a_mont, a_mont)
    print(hex(a_prod_mont))
    print(from_montgomery_form(a_prod_mont))

if __name__ == '__main__':
    main()