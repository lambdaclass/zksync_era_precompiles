import montgomery

# Base field order
N = 21888242871839275222246405745257275088696311157297823662689037894645226208583

def add(augend0, augend1, addend0, addend1):
    return montgomery.add(augend0, addend0), montgomery.add(augend1, addend1)

def sub(minuend0, minuend1, subtrahend0, subtrahend1):
    return montgomery.sub(minuend0, subtrahend0), montgomery.sub(minuend1, subtrahend1)

# [a, ib] * [c, id] = [ac - bd, (ad + bc)i] -> e = ac - bd, f = ad + bc
def regular_mul(a, b, c, d):
    e = montgomery.sub(montgomery.mul(a, c), montgomery.mul(b, d))
    f = montgomery.add(montgomery.mul(a, d), montgomery.mul(b, c))
    return e, f

def mul(a0, a1, b0, b1, montgomery_form=True):
    s = montgomery.add(a0, a1)
    t = montgomery.add(b0, b1)
    d0 = montgomery.mul(s, t)
    d1 = montgomery.mul(a0, b0)
    d2 = montgomery.mul(a1, b1)
    d0 = montgomery.sub(d0, d1)
    d0 = montgomery.sub(d0, d2)
    c1 = montgomery.REDC(d0)
    d2 = montgomery.mul(montgomery.into(5), d2)
    d1 = montgomery.sub(d1, d2)
    c0 = montgomery.REDC(d1)
    if montgomery_form:
        return d1, d0
    return c0, c1

def main():
    # (1 + 2i) * (2 + 2i) = [ac - bd, (ad + bc)i] = -2, 6i
    fp2_a = montgomery.ONE, montgomery.TWO
    fp2_b = montgomery.TWO, montgomery.TWO

    print(regular_mul(*fp2_a, *fp2_b))
    print(mul(*fp2_a, *fp2_b))


if __name__ == '__main__':
    main()