import bn254_py.fp as fp
import sys

def is_infinity(x, y):
    if x == 0 and y == 0:
        return True

def add(x1, y1, x2, y2):
    if is_infinity(x1, y1) and is_infinity(x2, y2):
        return (0, 0)
    if is_infinity(x1, y1) and not is_infinity(x2, y2):
        return (x2, y2)
    if not is_infinity(x1, y1) and is_infinity(x2, y2):
        return (x1, y1)
    if x1 == x2 and fp.sub(0, y1) == y2:
        return (0, 0)
    if x1 == x2 and y1 == y2:
        return double(x1, y1)
    
    m = fp.div(fp.sub(y2, y1), fp.sub(x2, x1))
    ret_x = fp.sub(fp.mul(m, m), fp.add(x1, x2))
    ret_y = fp.sub(fp.mul(m, fp.sub(x1, ret_x)), y1)
    return (ret_x, ret_y)

def double(x, y):
    if is_infinity(x, y):
        return 0, 0
       
    m = fp.div(fp.mul(3, fp.mul(x, x)), fp.add(y, y))
    ret_x = fp.sub(fp.mul(m, m), fp.add(x, x))
    ret_y = fp.sub(fp.mul(m, fp.sub(x,ret_x,mod)), y)
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
            res = add(res[0], res[1], p[0], p[1])
        p = double(p[0], p[1])

        multiplier = multiplier >> 1
    print(res)

if __name__ == '__main__':
    main()
