import montgomery as monty
import fp2

ZERO = (0,0,0,0,0,0)
ONE = [monty.ONE] + [0 for _ in range(5)]

# Algorithm 10 from https://eprint.iacr.org/2010/354.pdf
def add(a_00, a_01, a_10, a_11, a_20, a_21, b_00, b_01, b_10, b_11, b_20, b_21):
    c0 = fp2.add(a_00, a_01, b_00, b_01)
    c1 = fp2.add(a_10, a_11, b_10, b_11)
    c2 = fp2.add(a_20, a_21, b_20, b_21)
    return c0 + c1 + c2

# Algorithm 11 from https://eprint.iacr.org/2010/354.pdf
def sub(a_00, a_01, a_10, a_11, a_20, a_21, b_00, b_01, b_10, b_11, b_20, b_21):
    c0 = fp2.sub(a_00, a_01, b_00, b_01)
    c1 = fp2.sub(a_10, a_11, b_10, b_11)
    c2 = fp2.sub(a_20, a_21, b_20, b_21)
    return c0 + c1 + c2

# Algorithm 13 from https://eprint.iacr.org/2010/354.pdf
def mul(a_00, a_01, a_10, a_11, a_20, a_21, b_00, b_01, b_10, b_11, b_20, b_21):
    t0 = fp2.mul(a_00, a_01, b_00, b_01)
    t1 = fp2.mul(a_10, a_11, b_10, b_11)
    t2 = fp2.mul(a_20, a_21, b_20, b_21)
    c0 = fp2.add(*fp2.mul_by_xi(*fp2.sub(*fp2.sub(*fp2.mul(*fp2.add(a_10, a_11, a_20, a_21), *fp2.add(b_10, b_11, b_20, b_21)), *t1), *t2)), *t0)
    c1 = fp2.add(*fp2.sub(*fp2.sub(*fp2.mul(*fp2.add(a_00, a_01, a_10, a_11), *fp2.add(b_00, b_01, b_10, b_11)), *t0), *t1), *fp2.mul_by_xi(*t2))
    c2 = fp2.add(*fp2.sub(*fp2.sub(*fp2.mul(*fp2.add(a_00, a_01, a_20, a_21), *fp2.add(b_00, b_01, b_20, b_21)), *t0), *t2), *t1)
    return c0 + c1 + c2

# Algorithm 16 from https://eprint.iacr.org/2010/354.pdf
def square(a_00, a_01, a_10, a_11, a_20, a_21):
    c4 = fp2.scalar_mul(*fp2.mul(a_00, a_01, a_10, a_11), monty.TWO)
    c5 = fp2.exp(a_20, a_21, 2)
    c1 = fp2.add(*fp2.mul_by_xi(*c5), *c4)
    c2 = fp2.sub(*c4, *c5)
    c3 = fp2.exp(a_00, a_01, 2)
    c4 = fp2.add(*fp2.sub(a_00, a_01, a_10, a_11), a_20, a_21)
    c5 = fp2.scalar_mul(*fp2.mul(a_10, a_11, a_20, a_21), monty.TWO)
    c4 = fp2.exp(*c4, 2)
    c0 = fp2.add(*fp2.mul_by_xi(*c5), *c3)
    c2 = fp2.sub(*fp2.add(*fp2.add(*c2, *c4), *c5), *c3)
    return c0 + c1 + c2

# Algorithm 17 from https://eprint.iacr.org/2010/354.pdf
# Step 9 is wrong in the paper, it should be: t1 - t4
def inv(a_00, a_01, a_10, a_11, a_20, a_21):
    t0 = fp2.exp(a_00, a_01, 2);
    t1 = fp2.exp(a_10, a_11, 2);
    t2 = fp2.exp(a_20, a_21, 2);
    t3 = fp2.mul(a_00, a_01, a_10, a_11);
    t4 = fp2.mul(a_00, a_01, a_20, a_21);
    t5 = fp2.mul(a_20, a_21, a_10, a_11);
    c0 = fp2.sub(*t0, *fp2.mul_by_xi(*t5))
    c1 = fp2.sub(*fp2.mul_by_xi(*t2), *t3)
    c2 = fp2.sub(*t1, *t4)
    t6 = fp2.mul(a_00, a_01, *c0)
    t6 = fp2.add(*t6, *fp2.mul(*fp2.mul_by_xi(a_20, a_21), *c1))
    t6 = fp2.add(*t6, *fp2.mul(*fp2.mul_by_xi(a_10, a_11), *c2))
    t6 = fp2.inv(*t6)
    c0 = fp2.mul(*c0, *t6)
    c1 = fp2.mul(*c1, *t6)
    c2 = fp2.mul(*c2, *t6)

    return c0 + c1 + c2

def mul_by_gamma(a_00, a_01, a_10, a_11, a_20, a_21):
    c0 = fp2.mul_by_xi(a_20, a_21)
    c1 = a_00, a_01
    c2 = a_10, a_11

    return c0 + c1 + c2

def neg(a_00, a_01, a_10, a_11, a_20, a_21):
    return fp2.neg(a_00, a_01) + fp2.neg(a_10, a_11) + fp2.neg(a_20, a_21)

def main():
    # (1, 2) + (1, 2)x + (1, 2)x^2
    fp2_a_0 = monty.ONE, monty.TWO
    fp2_a_1 = monty.ONE, monty.TWO
    fp2_a_2 = monty.ONE, monty.TWO

    # (2, 2) + (2, 2)x + (2, 2)x^2
    fp2_b_0 = monty.TWO, monty.TWO
    fp2_b_1 = monty.TWO, monty.TWO
    fp2_b_2 = monty.TWO, monty.TWO

    # ADDITION
    fp6_ab = add(*fp2_a_0, *fp2_a_1, *fp2_a_2, *fp2_b_0, *fp2_b_1, *fp2_b_2)

    assert(monty.out_of(fp6_ab[0]) == 3)
    assert(monty.out_of(fp6_ab[1]) == 4)
    assert(monty.out_of(fp6_ab[2]) == 3)
    assert(monty.out_of(fp6_ab[3]) == 4)
    assert(monty.out_of(fp6_ab[4]) == 3)
    assert(monty.out_of(fp6_ab[5]) == 4)

    # SUBTRACTION

    # (1, 2) + (1, 1)x + (1, 0)x^2
    fp2_b_0 = monty.ONE, monty.TWO
    fp2_b_1 = monty.ONE, monty.ONE
    fp2_b_2 = monty.ONE, 0

    fp6_ab = sub(*fp2_a_0, *fp2_a_1, *fp2_a_2, *fp2_b_0, *fp2_b_1, *fp2_b_2)

    assert(monty.out_of(fp6_ab[0]) == 0)
    assert(monty.out_of(fp6_ab[1]) == 0)
    assert(monty.out_of(fp6_ab[2]) == 0)
    assert(monty.out_of(fp6_ab[3]) == 1)
    assert(monty.out_of(fp6_ab[4]) == 0)
    assert(monty.out_of(fp6_ab[5]) == 2)

    # SQUARE AND MULTIPLICATION

    fp6_squared = square(*fp2_a_0, *fp2_a_1, *fp2_a_2)
    fp6_mul_squared = mul(*fp2_a_0, *fp2_a_1, *fp2_a_2, *fp2_a_0, *fp2_a_1, *fp2_a_2)
    
    assert(fp6_squared[0] == fp6_mul_squared[0])
    assert(fp6_squared[1] == fp6_mul_squared[1])
    assert(fp6_squared[2] == fp6_mul_squared[2])
    assert(fp6_squared[3] == fp6_mul_squared[3])
    assert(fp6_squared[4] == fp6_mul_squared[4])
    assert(fp6_squared[5] == fp6_mul_squared[5])

    # INVERSE
    fp6_inversed = inv(*fp2_a_0, *fp2_a_1, *fp2_a_2)
    fp6_one = mul(*fp2_a_0, *fp2_a_1, *fp2_a_2, *fp6_inversed)

    assert(fp6_one[0] == monty.ONE)
    assert(fp6_one[1] == 0)
    assert(fp6_one[2] == 0)
    assert(fp6_one[3] == 0)
    assert(fp6_one[4] == 0)
    assert(fp6_one[5] == 0)

if __name__ == '__main__':
    main()
