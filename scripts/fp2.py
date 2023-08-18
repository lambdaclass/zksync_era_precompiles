import montgomery as monty

# Base field order
N = 21888242871839275222246405745257275088696311157297823662689037894645226208583

# Algorithm 5 from https://eprint.iacr.org/2010/354.pdf
def add(a0, a1, b0, b1):
    return monty.add(a0, b0), monty.add(a1, b1)

# Algorithm 6 from https://eprint.iacr.org/2010/354.pdf
def sub(a0, a1, b0, b1):
    return monty.sub(a0, b0), monty.sub(a1, b1)

# Algorithm 7 from https://eprint.iacr.org/2010/354.pdf
def scalar_mul(a0, a1, scalar):
    return monty.mul(a0, scalar), monty.mul(a1, scalar)

def mul(a0, a1, b0, b1):
    e = monty.sub(monty.mul(a0, b0), monty.mul(a1, b1))
    f = monty.add(monty.mul(a0, b1), monty.mul(a1, b0))
    return e, f

# Algorithm 8 from https://eprint.iacr.org/2010/354.pdf
# β = -1
def inv(a0, a1):
    t0 = monty.mul(a0, a0)
    t1 = monty.mul(a1, a1)
    # This step is actually to - β * t1 but β = -1 so we can just add t1 to t0.
    t0 = monty.add(t0, t1)
    t1 = monty.inv(t0)
    return monty.mul(a0, t1), monty.sub(0, monty.mul(a1, t1))

def exp(base0, base1, exponent):
    pow0 = monty.ONE
    pow1 = 0
    while exponent > 0:
        if exponent % 2 == 1:
            pow0, pow1 = mul(pow0, pow1, base0, base1)
        base0, base1 = mul(base0, base1, base0, base1)
        exponent >>= 1 
    return pow0, pow1

def main():
    # (1 + 2i) * (2 + 2i) = [ac - bd, (ad + bc)i] = -2 + 6i
    fp2_a = monty.ONE, monty.TWO
    fp2_b = monty.TWO, monty.TWO
    fp2_ab = mul(*fp2_a, *fp2_b)

    assert(monty.out_of(fp2_ab[0]) == N - 2)
    assert(monty.out_of(fp2_ab[1]) == 6)

    # (1 + 2i) ^ 0 = 1
    fp2_one = exp(*fp2_a, 0)
    assert(monty.out_of(fp2_one[0]) == 1)
    assert(monty.out_of(fp2_one[1]) == 0)

    # (1 + 2i) ^ 2 = -3 + 4i
    fp2_a_squared = exp(*fp2_a, 2)
    assert(monty.out_of(fp2_a_squared[0]) == N - 3)
    assert(monty.out_of(fp2_a_squared[1]) == 4)

    # (1 + 2i) ^ 3 = (1 + 2i) * (-3 + 4i) = [ac - bd, (ad + bc)i] = -11 - 2i
    fp2_a_cubed = exp(*fp2_a, 3)
    assert(monty.out_of(fp2_a_cubed[0]) == N - 11)
    assert(monty.out_of(fp2_a_cubed[1]) == N - 2)

    # (1 + 2i) * 0 = 0
    fp2_zero = scalar_mul(*fp2_a, 0)
    assert(fp2_zero == (0, 0))

    # (1 + 2i) * 1 = 1 + 2i
    fp2_one = scalar_mul(*fp2_a, monty.ONE)
    assert(fp2_one == fp2_a)

    # (1 + 2i) * 2 = 2 + 4i
    fp2_two = scalar_mul(*fp2_a, monty.TWO)
    assert(fp2_two == (monty.TWO, monty.FOUR))

    # (1 + 2i) * 3 = 3 + 6i
    fp2_three = scalar_mul(*fp2_a, monty.THREE)
    assert(fp2_three == (monty.THREE, monty.SIX))
 
if __name__ == '__main__':
    main()
    