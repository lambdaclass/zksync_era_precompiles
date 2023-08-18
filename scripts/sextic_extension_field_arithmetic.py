import montgomery as monty
import quadratic_extension_field_arithmetic as fp2

XI = monty.NINE, monty.ONE

# Algorithm 10 from https://eprint.iacr.org/2010/354.pdf
def add(a_00, a_01, a_10, a_11, a_20, a_21, b_00, b_01, b_10, b_11, b_20, b_21):
    c0 = fp2.add(a_00, a_01, b_00, b_01)
    c1 = fp2.add(a_10, a_11, b_10, b_11)
    c2 = fp2.add(a_20, a_21, b_20, b_21)
    return c0, c1, c2

# Algorithm 11 from https://eprint.iacr.org/2010/354.pdf
def sub(a_00, a_01, a_10, a_11, a_20, a_21, b_00, b_01, b_10, b_11, b_20, b_21):
    c0 = fp2.sub(a_00, a_01, b_00, b_01)
    c1 = fp2.sub(a_10, a_11, b_10, b_11)
    c2 = fp2.sub(a_20, a_21, b_20, b_21)
    return c0, c1, c2

# Algorithm 13 from https://eprint.iacr.org/2010/354.pdf
def mul(a_00, a_01, a_10, a_11, a_20, a_21, b_00, b_01, b_10, b_11, b_20, b_21):
    t0 = fp2.mul(a_00, a_01, b_00, b_01)
    t1 = fp2.mul(a_10, a_11, b_10, b_11)
    t2 = fp2.mul(a_20, a_21, b_20, b_21)
    c0 = fp2.add(*fp2.mul(*fp2.sub(*fp2.sub(*fp2.mul(*fp2.add(a_10, a_11, a_20, a_21), *fp2.add(b_10, b_11, b_20, b_21)), *t1), *t2), *XI), *t0)
    c1 = fp2.add(*fp2.sub(*fp2.sub(*fp2.mul(*fp2.add(a_00, a_01, a_10, a_11), *fp2.add(b_00, b_01, b_10, b_11)), *t0), *t1), *fp2.mul(*XI, *t2))
    c2 = fp2.add(*fp2.sub(*fp2.sub(*fp2.mul(*fp2.add(a_00, a_01, a_20, a_21), *fp2.add(b_00, b_01, b_20, b_21)), *t0), *t2), *t1)
    return c0, c1, c2

# Algorithm 16 from https://eprint.iacr.org/2010/354.pdf
def square(a_00, a_01, a_10, a_11, a_20, a_21):
    c4 = fp2.scalar_mul(*fp2.mul(a_00, a_01, a_10, a_11), monty.TWO)
    c5 = fp2.exp(a_20, a_21, 2)
    c1 = fp2.add(*fp2.mul(*c5, *XI), *c4)
    c2 = fp2.sub(*c4, *c5)
    c3 = fp2.exp(a_00, a_01, 2)
    c4 = fp2.add(*fp2.sub(a_00, a_01, a_10, a_11), a_20, a_21)
    c5 = fp2.scalar_mul(*fp2.mul(a_00, a_01, a_20, a_21), monty.TWO)
    c4 = fp2.exp(*c4, 2)
    c0 = fp2.add(*fp2.mul(*c5, *XI), *c3)
    c2 = fp2.sub(*fp2.add(*fp2.add(*c2, *c4), *c5), *c3)
    return c0, c1, c2

# Algorithm 17 from https://eprint.iacr.org/2010/354.pdf
# FIXME: This is not correct
def inv(a_00, a_01, a_10, a_11, a_20, a_21):
    t0 = fp2.exp(a_00, a_01, 2);
    t1 = fp2.exp(a_10, a_11, 2);
    t2 = fp2.exp(a_20, a_21, 2);
    t3 = fp2.mul(a_00, a_01, a_10, a_11);
    t4 = fp2.mul(a_00, a_01, a_20, a_21);
    t5 = fp2.mul(a_20, a_21, a_10, a_11);
    c0 = fp2.sub(*t0, *fp2.mul(*XI, *t5))
    c1 = fp2.sub(*fp2.mul(*XI, *t2), *t3)
    c2 = fp2.mul(*t1, *t4)
    t6 = fp2.mul(a_00, a_01, *c0)
    t6 = fp2.add(*t6, *fp2.mul(*fp2.mul(*XI, a_20, a_21), *c1))
    t6 = fp2.add(*t6, *fp2.mul(*fp2.mul(*XI, a_10, a_11), *c2))
    t6 = fp2.inv(*t6)
    c0 = fp2.mul(*c0, *t6)
    c1 = fp2.mul(*c1, *t6)
    c2 = fp2.mul(*c2, *t6)

    return c0, c1, c2


def main():
    # ADDITION
    # (1, 2) + (1, 2)x + (1, 2)x^2
    fp2_a_0 = monty.ONE, monty.TWO
    fp2_a_1 = monty.ONE, monty.TWO
    fp2_a_2 = monty.ONE, monty.TWO

    # (2, 2) + (2, 2)x + (2, 2)x^2
    fp2_b_0 = monty.TWO, monty.TWO
    fp2_b_1 = monty.TWO, monty.TWO
    fp2_b_2 = monty.TWO, monty.TWO

    fp6_ab = add(*fp2_a_0, *fp2_a_1, *fp2_a_2, *fp2_b_0, *fp2_b_1, *fp2_b_2)

    assert(monty.out_of(fp6_ab[0][0]) == 3)
    assert(monty.out_of(fp6_ab[0][1]) == 4)
    assert(monty.out_of(fp6_ab[1][0]) == 3)
    assert(monty.out_of(fp6_ab[1][1]) == 4)
    assert(monty.out_of(fp6_ab[2][0]) == 3)
    assert(monty.out_of(fp6_ab[2][1]) == 4)

    # SUBTRACTION

    # (1, 2) + (1, 1)x + (1, 0)x^2
    fp2_b_0 = monty.ONE, monty.TWO
    fp2_b_1 = monty.ONE, monty.ONE
    fp2_b_2 = monty.ONE, 0

    fp6_ab = sub(*fp2_a_0, *fp2_a_1, *fp2_a_2, *fp2_b_0, *fp2_b_1, *fp2_b_2)

    assert(monty.out_of(fp6_ab[0][0]) == 0)
    assert(monty.out_of(fp6_ab[0][1]) == 0)
    assert(monty.out_of(fp6_ab[1][0]) == 0)
    assert(monty.out_of(fp6_ab[1][1]) == 1)
    assert(monty.out_of(fp6_ab[2][0]) == 0)
    assert(monty.out_of(fp6_ab[2][1]) == 2)

    # SQUARE AND MULTIPLICATION

    fp6_squared = square(*fp2_a_0, *fp2_a_1, *fp2_a_2)
    fp6_mul_squared = mul(*fp2_a_0, *fp2_a_1, *fp2_a_2, *fp2_a_0, *fp2_a_1, *fp2_a_2)
    
    assert(fp6_squared[0][0] == fp6_mul_squared[0][0])
    assert(fp6_squared[0][1] == fp6_mul_squared[0][1])
    assert(fp6_squared[1][0] == fp6_mul_squared[1][0])
    assert(fp6_squared[1][1] == fp6_mul_squared[1][1])
    assert(fp6_squared[2][0] == fp6_mul_squared[2][0])
    assert(fp6_squared[2][1] == fp6_mul_squared[2][1])

    # # INVERSE
    # fp6_inversed = inv(*fp2_a_0, *fp2_a_1, *fp2_a_2)
    # fp6_zero = mul(*fp2_a_0, *fp2_a_1, *fp2_a_2, *fp6_inversed[0], *fp6_inversed[1], *fp6_inversed[2])
    
    # assert(fp6_zero[0][0] == monty.ONE)
    # assert(fp6_zero[0][1] == 0)
    # assert(fp6_zero[1][0] == 0)
    # assert(fp6_zero[1][1] == 0)
    # assert(fp6_zero[2][0] == 0)
    # assert(fp6_zero[2][1] == 0)

if __name__ == '__main__':
    main()
