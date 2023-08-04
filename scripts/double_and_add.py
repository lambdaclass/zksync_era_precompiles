import sys

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
       
    m = div_mod(mul_mod(3, mul_mod(x, x, mod), mod), add_mod(y, y, mod), mod)
    ret_x = sub_mod(mul_mod(m, m, mod), add_mod(x, x, mod), mod)
    ret_y = sub_mod(mul_mod(m, sub_mod(x,ret_x,mod), mod), y, mod)
    return (ret_x, ret_y)

def is_even(x):
    return x % 2 == 0

def main():
    multiplier = int(sys.argv[1])
    mod = 21888242871839275222246405745257275088696311157297823662689037894645226208583
    res = (0, 0)
    p = (1,2)

    while multiplier > 0:
        if not is_even(multiplier):
            res = point_add(res[0], res[1], p[0], p[1], mod)
        p = point_double(p[0], p[1], mod)

        multiplier = multiplier >> 1
    print(res)

if __name__ == '__main__':
    main()
