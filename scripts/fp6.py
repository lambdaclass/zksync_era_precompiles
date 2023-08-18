import montgomery as monty
import fp2

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
    c0 = fp2.add(*fp2.mul_by_xi(*fp2.sub(*fp2.sub(*fp2.mul(*fp2.add(a_10, a_11, a_20, a_21), *fp2.add(b_10, b_11, b_20, b_21)), *t1), *t2)), *t0)
    c1 = fp2.add(*fp2.sub(*fp2.sub(*fp2.mul(*fp2.add(a_00, a_01, a_10, a_11), *fp2.add(b_00, b_01, b_10, b_11)), *t0), *t1), *fp2.mul_by_xi(*t2))
    c2 = fp2.add(*fp2.sub(*fp2.sub(*fp2.mul(*fp2.add(a_00, a_01, a_20, a_21), *fp2.add(b_00, b_01, b_20, b_21)), *t0), *t2), *t1)
    return c0, c1, c2

# Algorithm 16 from https://eprint.iacr.org/2010/354.pdf
def square(a_00, a_01, a_10, a_11, a_20, a_21):
    c4 = fp2.scalar_mul(*fp2.mul(a_00, a_01, a_10, a_11), monty.TWO)
    c5 = fp2.exp(a_20, a_21, 2)
    c1 = fp2.add(*fp2.mul_by_xi(*c5), *c4)
    c2 = fp2.sub(*c4, *c5)
    c3 = fp2.exp(a_00, a_01, 2)
    c4 = fp2.add(*fp2.sub(a_00, a_01, a_10, a_11), a_20, a_21)
    c5 = fp2.scalar_mul(*fp2.mul(a_00, a_01, a_20, a_21), monty.TWO)
    c4 = fp2.exp(*c4, 2)
    c0 = fp2.add(*fp2.mul_by_xi(*c5), *c3)
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
    c0 = fp2.sub(*t0, *fp2.mul_by_xi(*t5))
    c1 = fp2.sub(*fp2.mul_by_xi(*t2), *t3)
    c2 = fp2.mul(*t1, *t4)
    t6 = fp2.mul(a_00, a_01, *c0)
    t6 = fp2.add(*t6, *fp2.mul(*fp2.mul_by_xi(a_20, a_21), *c1))
    t6 = fp2.add(*t6, *fp2.mul(*fp2.mul_by_xi(a_10, a_11), *c2))
    t6 = fp2.inv(*t6)
    c0 = fp2.mul(*c0, *t6)
    c1 = fp2.mul(*c1, *t6)
    c2 = fp2.mul(*c2, *t6)

    return c0, c1, c2

def inv_aux(a_00, a_01, a_10, a_11, a_20, a_21):
        c0 = a_20, a_21;
        c0 = fp2.mul_by_xi(*c0)
        c0 = fp2.mul(*c0, a_10, a_11)
        c0 = fp2.sub(0, 0, *c0)

        c0s = a_00, a_01
        c0s = fp2.exp(*c0s, monty.TWO)
        c0 = fp2.add(*c0, *c0s)

        c1 = a_20, a_21
        c1 = fp2.exp(*c1, monty.TWO)
        c1 = fp2.mul_by_xi(*c1);

        c01 = a_00, a_01
        c01 = fp2.mul(*c01, *c1)
        c1 = fp2.sub(*c1, *c01)

        c2 = a_10, a_11
        c2 = fp2.exp(*c2, monty.TWO)
        c02 = a_00, a_01
        c02 = fp2.mul(*c02, *c2)
        c2 = fp2.sub(*c2, *c02)

        tmp1 = a_20, a_21
        tmp1 = fp2.mul(*tmp1, *c1)
        tmp2 = a_10, a_11;
        tmp2 = fp2.mul(*tmp2, *c2)
        tmp1 = fp2.add(*tmp1, *tmp2)
        tmp1 = fp2.mul_by_xi(*tmp1)
        tmp2 = a_00, a_01
        tmp2 = fp2.mul(*tmp2, *c0)
        tmp1 = fp2.add(*tmp1, *tmp2)

        tmp = fp2.inv(*tmp1)
        
        c0 = fp2.mul(*tmp, *c0)
        c1 = fp2.mul(*tmp, *c1)
        c2 = fp2.mul(*tmp, *c2)

        return c0, c1, c2

def mul_by_xi(a_00, a_01, a_10, a_11, a_20, a_21):
    c0 = fp2.mul_by_xi(a_20, a_21)
    c1 = a_00, a_01
    c2 = a_10, a_11

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

    # INVERSE
    fp6_inversed = inv_aux(*fp2_a_0, *fp2_a_1, *fp2_a_2)
    fp6_zero = mul(*fp2_a_0, *fp2_a_1, *fp2_a_2, *fp6_inversed[0], *fp6_inversed[1], *fp6_inversed[2])
    
    print(monty.out_of(fp6_zero[0][0]))
    print(monty.out_of(fp6_zero[0][1]))

    print(monty.out_of(fp6_zero[1][0]))
    print(monty.out_of(fp6_zero[1][1]))
    print(monty.out_of(fp6_zero[2][0]))
    print(monty.out_of(fp6_zero[2][1]))


    assert(fp6_zero[0][0] == monty.ONE)
    assert(fp6_zero[0][1] == 0)

    assert(fp6_zero[1][0] == 0)
    assert(fp6_zero[1][1] == 0)
    assert(fp6_zero[2][0] == 0)
    assert(fp6_zero[2][1] == 0)

if __name__ == '__main__':
    main()
