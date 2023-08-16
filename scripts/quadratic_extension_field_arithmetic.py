import montgomery

# Base field order
N = 21888242871839275222246405745257275088696311157297823662689037894645226208583

def add(augend0, augend1, addend0, addend1):
    return montgomery.add(augend0, addend0), montgomery.add(augend1, addend1)

def sub(minuend0, minuend1, subtrahend0, subtrahend1):
    return montgomery.sub(minuend0, subtrahend0), montgomery.sub(minuend1, subtrahend1)

# [a, ib] * [c, id] = [ac - bd, (ad + bc)i] -> e = ac - bd, f = ad + bc
def mul(a, b, c, d):
    e = montgomery.sub(montgomery.mul(a, c), montgomery.mul(b, d))
    f = montgomery.add(montgomery.mul(a, d), montgomery.mul(b, c))
    return e, f

def exp(base0, base1, exponent):
    pow0 = montgomery.ONE
    pow1 = 0
    while exponent > 0:
        if exponent % 2 == 1:
            pow0, pow1 = mul(pow0, pow1, base0, base1)
        base0, base1 = mul(base0, base1, base0, base1)
        exponent >>= 1 
    return pow0, pow1

def main():
    # (1 + 2i) * (2 + 2i) = [ac - bd, (ad + bc)i] = -2 + 6i
    fp2_a = montgomery.ONE, montgomery.TWO
    fp2_b = montgomery.TWO, montgomery.TWO
    fp2_ab = mul(*fp2_a, *fp2_b)

    assert(montgomery.out_of(fp2_ab[0]) == N - 2)
    assert(montgomery.out_of(fp2_ab[1]) == 6)

    # (1 + 2i) ^ 0 = 1
    fp2_one = exp(*fp2_a, 0)
    assert(montgomery.out_of(fp2_one[0]) == 1)
    assert(montgomery.out_of(fp2_one[1]) == 0)

    # (1 + 2i) ^ 2 = -3 + 4i
    fp2_a_squared = exp(*fp2_a, 2)
    assert(montgomery.out_of(fp2_a_squared[0]) == N - 3)
    assert(montgomery.out_of(fp2_a_squared[1]) == 4)

    # (1 + 2i) ^ 3 = (1 + 2i) * (-3 + 4i) = [ac - bd, (ad + bc)i] = -11 - 2i
    fp2_a_cubed = exp(*fp2_a, 3)
    assert(montgomery.out_of(fp2_a_cubed[0]) == N - 11)
    assert(montgomery.out_of(fp2_a_cubed[1]) == N - 2)

if __name__ == '__main__':
    main()