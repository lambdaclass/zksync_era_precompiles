# 2^256
R = 115792089237316195423570985008687907853269984665640564039457584007913129639936
# Fp
N = 21888242871839275222246405745257275088696311157297823662689037894645226208583
# R2 % N
R2_MOD_N = 3096616502983703923843567936837374451735540968419076528771170197431451843209
# N' -> NN' ≡ −1 mod R
N_PRIME = 111032442853175714102588374283752698368366046808579839647964533820976443843465

ONE = 6350874878119819312338956282401532409788428879151445726012394534686998597021
TWO = 12701749756239638624677912564803064819576857758302891452024789069373997194042
THREE = 19052624634359457937016868847204597229365286637454337178037183604060995791063
FOUR = 3515256640640002027109419384348854550457404359307959241360540244102768179501
FIVE = 9866131518759821339448375666750386960245833238459404967372934778789766776522
SIX = 16217006396879640651787331949151919370034262117610850693385329313476765373543
SEVEN = 679638403160184741879882486296176691126379839464472756708685953518537761981
EIGHT = 7030513281280004054218838768697709100914808718615918482721080488205536359002
NINE = 13381388159399823366557795051099241510703237597767364208733475022892534956023

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
def into(a):
    return REDC((a % N) * R2_MOD_N)

# REDC(aR mod N)
def out_of(a_mont):
    return REDC(a_mont)

# REDC((aR mod N)(bR mod N))
def mul(a_mont, b_mont):
    return REDC(a_mont * b_mont)

def exp(base, exponent):
    pow = into(1)
    while exponent > 0:
        if exponent % 2 == 1:
            pow = mul(pow, base)
        exponent = exponent >> 1 
        base = mul(base, base)
    return pow

def inv(a):
    return binary_extended_euclidean_algorithm(a, N)

def div(dividend, divisor):
    divisor_inv = inv(divisor)
    return mul(dividend, divisor_inv)

def add(augend, addend):
    return (augend + addend) % N

def sub(minuend, subtrahend):
    return add(minuend, N - subtrahend)
