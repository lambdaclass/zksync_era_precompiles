import sys

A = 0xffffffff00000001000000000000000000000000fffffffffffffffffffffffc
# A = 0xFCFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000001000000FFFFFFFF
B = 0x5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b
# B = 0x4B60D2273E3CCE3BF6B053CCB0061D65BC86987655BDEBB3E7933AAAD835C65A

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
    mod = 0xffffffff00000001000000000000000000000000ffffffffffffffffffffffff
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
    mod = 0xffffffff00000001000000000000000000000000ffffffffffffffffffffffff
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

def escalarMul(p, n):
    multiplier = n
    res = (0, 0)

    while multiplier > 0:
        if not is_even(multiplier):
            res = point_add(res[0], res[1], p[0], p[1])
        p = point_double(p[0], p[1])

        multiplier = multiplier >> 1    
    return res

def main():
    n = 0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551
    
    z = 0x1899fa5c2e77910f63db2d279ae19dea9ec0d2f3b0c8c532c572fe27cd1bedba
    da = 245123
    k = 901879137

    gx = 0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296
    gy = 0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5
    
    # Signature
    x, y = escalarMul((gx,gy),k)
    r = x % n
    assert r != 0

    k_inv = pow(k, n-2, n)
    assert k_inv * k % n == 1

    s = (k_inv * (z + r * da)) % n
    assert s != 0

    # z = 0x5ad83880e16658d7521d4e878521defaf6b43dec1dbd69e514c09ab8f1f2ffe2
    # r = 0xBE2B5B76B868F64F255F8CF666EA3B0B17EE8A2C352757B9454DD4979539D7DE
    # s = 0x93973E2948748003BC6C947D56A47411EA1C812B358BE9D0189E2BD0A0B9D11E
    # x = 0x18905F76A53755C679FB732B7762251075BA95FC5FEDB60179E730D418A9143C
    # y = 0x8571FF1825885D85D2E88688DD21F3258B4AB8E4BA19E45CDDF25357CE95560A

    # Check generators
    assert((0,0) == escalarMul((gx, gy), n))
    # Check Public key
    assert((0,0) == escalarMul((x, y), n))

    # Verification
    s_inv = pow(s, n-2, n)
    assert s_inv * s % n == 1

    u1 = (z * s_inv) % n
    u2 = (r * s_inv) % n

    x1, y1 = point_add(*escalarMul((gx, gy), u1),*escalarMul((x, y), u2))
    x1 = x1 % n
    r = r % n

    print(x1 == r)


if __name__ == '__main__':
    main()
