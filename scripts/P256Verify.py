import sys

A = 0xffffffff00000001000000000000000000000000fffffffffffffffffffffffc

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

def point_add(x1, y1, x2, y2, mod):
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
    
    m = div_mod(sub_mod(y2, y1, mod), sub_mod(x2, x1, mod), mod)
    ret_x = sub_mod(mul_mod(m, m, mod), add_mod(x1, x2, mod), mod)
    ret_y = sub_mod(mul_mod(m, sub_mod(x1, ret_x, mod), mod), y1, mod)
    return (ret_x, ret_y)


def point_double(x, y, mod):
    if is_infinity(x, y):
        return 0, 0
       
    m = div_mod(add_mod(A, mul_mod(3, mul_mod(x, x, mod), mod), mod), add_mod(y, y, mod), mod)
    ret_x = sub_mod(mul_mod(m, m, mod), add_mod(x, x, mod), mod)
    ret_y = sub_mod(mul_mod(m, sub_mod(x,ret_x,mod), mod), y, mod)
    return (ret_x, ret_y)

def is_even(x):
    return x % 2 == 0

def escalarMul(p, n):
    multiplier = n
    mod = 0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551
    res = (0, 0)

    while multiplier > 0:
        if not is_even(multiplier):
            res = point_add(res[0], res[1], p[0], p[1], mod)
        p = point_double(p[0], p[1], mod)

        multiplier = multiplier >> 1
    
    return res

def main():
    n = 0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551
    z = 0x1899fa5c2e77910f63db2d279ae19dea9ec0d2f3b0c8c532c572fe27cd1bedba
    
    da = 245123
    k = 901879137

    gx = 0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296
    gy = 0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5

    x,y = escalarMul((gx,gy),k)
    r = x % n
    assert r != 0

    k_inv = pow(k, n-2, n)
    s = (k_inv * (z + r * da)) % n

    s_inv = pow(s, n-2, n)
    assert s_inv * s % n == 1

    u1 = (z * s_inv) % n
    u2 = (r * s_inv) % n

    x1, y1 = point_add(*escalarMul((gx, gy), u1),*escalarMul((x, y), u2),n)
    x1 = x1 % n
    r = r % n

    print(x1 == r)

if __name__ == '__main__':
    main()
