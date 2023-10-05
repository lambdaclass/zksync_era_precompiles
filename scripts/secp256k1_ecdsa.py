A = 0
B = 0x0000000000000000000000000000000000000000000000000000000000000007
N = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141
P = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f

def is_infinity(x, y):
    if x == 0 and y == 0:
        return True

def inv_mod(a, mod):
    return pow(a, mod - 2, mod)

def add_mod(a,b,mod):
    return (a + b) % mod

def sub_mod(a,b,mod):
    return add_mod(a, mod - b, mod)

def div_mod(a,b,mod):
    return mul_mod(a, inv_mod(b, mod), mod)

def mul_mod(a,b,mod):
    return (a * b) % mod

def point_add(x1, y1, x2, y2):
    mod = P
    if is_infinity(x1, y1) and is_infinity(x2, y2):
        return (0, 0)
    if is_infinity(x1, y1) and not is_infinity(x2, y2):
        return (x2, y2)
    if not is_infinity(x1, y1) and is_infinity(x2, y2):
        return (x1, y1)
    if x1 == x2 and sub_mod(0, y1, mod) == y2:
        return (0, 0)
    if x1 == x2 and y1 == y2:
        return point_double(x1, y1, mod)
    
    m = div_mod(sub_mod(y1, y2, mod), sub_mod(x1, x2, mod), mod)
    ret_x = sub_mod(mul_mod(m, m, mod), add_mod(x1, x2, mod), mod)
    ret_y = sub_mod(mul_mod(m, sub_mod(x1, ret_x, mod), mod), y1, mod)
    return (ret_x, ret_y)

def point_double(x, y):
    mod = P
    if is_infinity(x, y):
        return 0, 0
    if y == 0:
        return 0, 0
    m = div_mod(add_mod(A, mul_mod(3, mul_mod(x, x, mod), mod), mod), add_mod(y, y, mod), mod)
    ret_x = sub_mod(mul_mod(m, m, mod), add_mod(x, x, mod), mod)
    ret_y = sub_mod(mul_mod(m, sub_mod(x, ret_x, mod), mod), y, mod)
    return (ret_x, ret_y)

def is_even(x):
    return x % 2 == 0

def scalar_mul(p, n):
    multiplier = n
    res = (0, 0)

    while multiplier > 0:
        if not is_even(multiplier):
            res = point_add(res[0], res[1], p[0], p[1])
        p = point_double(p[0], p[1])

        multiplier = multiplier >> 1    
    return res

'''
ECDSA
'''

def public_key(da, gx, gy):
    return scalar_mul((gx, gy), da)

def sign(z, da, k, gx, gy, n):
    x, y = scalar_mul((gx, gy), k)
    r = x % n
    assert(r != 0)

    k_inv = pow(k, n-2, n)
    assert k_inv * k % n == 1

    s = (k_inv * (z + r * da)) % n
    assert(s != 0)

    return r, s

def verify(z, r, s, public_key_x, public_key_y, gx, gy, n):
    s_inv = pow(s, n-2, n)
    assert s_inv * s % n == 1

    u1 = (z * s_inv) % n
    u2 = (r * s_inv) % n

    x1, _ = point_add(*scalar_mul((gx, gy), u1),*scalar_mul((public_key_x, public_key_y), u2))
    x1 = x1 % n
    r = r % n

    return x1 == r

def main():
    n = N
    
    z = 0x1899fa5c2e77910f63db2d279ae19dea9ec0d2f3b0c8c532c572fe27cd1bedba
    da = 245123
    k = 901879137

    gx = 0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798
    gy = 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8

    # Signature
    r, s = sign(z, da, k, gx, gy, n)

    print(hex(r))
    print(hex(s))

    # Public Key
    public_key_x, public_key_y = public_key(da, gx, gy)

    print(hex(public_key_x))
    print(hex(public_key_y))

    # Verification
    print(verify(z, r, s, public_key_x, public_key_y, gx, gy, n))

if __name__ == "__main__":
    main()