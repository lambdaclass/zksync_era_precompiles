import math

# # 2^256
R = 115792089237316195423570985008687907853269984665640564039457584007913129639936
# R_PRIME = 20988524275117001072002809824448087578619730785600314334253784976379291040311
# # R^2 = (2^256)^2 = 2^512
# R2 = 13407807929942597099574024998205846127479365820592393377723561443721764030073546976801874298166903427690031858186486050853753882811946569946433649006084096
# # R^3 = (2^256)^3 = 2^768
# R3 = 1552518092300708935148979488462502555256886017116696611139052038026050952686376886330878408828646477950487730697131073206171580044114814391444287275041181139204454976020849905550265285631598444825262999193716468750892846853816057856
# # R3 % N
# R3_MOD_N = 14921786541159648185948152738563080959093619838510245177710943249661917737183
# Fp
N = int(0xffffffff00000001000000000000000000000000ffffffffffffffffffffffff)
# R2 % N
R2_MOD_N = 134799733323198995502561713907086292154532538166959272814710328655875
# N' -> NN' ≡ −1 mod R
N_PRIME = 115792089210356248768974548684794254293921932838497980611635986753331132366849

ONE = 6350874878119819312338956282401532409788428879151445726012394534686998597021
TWO = 12701749756239638624677912564803064819576857758302891452024789069373997194042
THREE = 19052624634359457937016868847204597229365286637454337178037183604060995791063
FOUR = 3515256640640002027109419384348854550457404359307959241360540244102768179501
FIVE = 9866131518759821339448375666750386960245833238459404967372934778789766776522
SIX = 16217006396879640651787331949151919370034262117610850693385329313476765373543
SEVEN = 679638403160184741879882486296176691126379839464472756708685953518537761981
EIGHT = 7030513281280004054218838768697709100914808718615918482721080488205536359002
NINE = 13381388159399823366557795051099241510703237597767364208733475022892534956023
TEN = 19732263037519642678896751333500773920491666476918809934745869557579533553044

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

# def montgomery_modular_inverse(a):
#     a_inv = prime_field_inv(a, N)
#     return REDC(a_inv * R3_MOD_N)

def inv(a):
    return binary_extended_euclidean_algorithm(a, N)

def div(dividend, divisor):
    divisor_inv = inv(divisor)
    return mul(dividend, divisor_inv)

def add(augend, addend):
    return (augend + addend) % N

def sub(minuend, subtrahend):
    return add(minuend, N - subtrahend)

x = 0x18905f76a53755c679fb732b7762251075ba95fc5fedb60179e730d418a9143c
y = 0x8571ff1825885d85d2e88688dd21f3258b4ab8e4ba19e45cddf25357ce95560a
a = into(115792089210356248762697446949407573530086143415290314195533631308867097853948)
b = into(41058363725152142129326129780047268409114441015993725554835256314039467401291)
assert(mul(y, y) == add(mul(x, mul(x, x)), add(mul(a, x), b)))
print(y*y)
print(hex(y))
print(hex(mul(y, y)))
print(hex(mul(x, mul(x, x))))
print(hex(mul(a, x)))
print(hex(add(mul(a, x), b)))
print(hex(add(mul(x, mul(x, x)), add(mul(a, x), b))))
print(mul(y, y) == add(mul(x, mul(x, x)), add(mul(a, x), b)))