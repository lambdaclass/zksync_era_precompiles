import montgomery as monty
import fp6

FP6_ZERO = [0,0,0,0,0,0]
FP6_ONE = [monty.ONE] + [0 for _ in range(5)]

# Algorithm 18 from https://eprint.iacr.org/2010/354.pdf
def add(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121, b_000, b_001, b_010, b_011, b_020, b_021, b_100, b_101, b_110, b_111, b_120, b_121):
    c0 = fp6.add(a_000, a_001, a_010, a_011, a_020, a_021, b_000, b_001, b_010, b_011, b_020, b_021)
    c1 = fp6.add(a_100, a_101, a_110, a_111, a_120, a_121, b_100, b_101, b_110, b_111, b_120, b_121)
    return c0, c1

# Algorithm 19 from https://eprint.iacr.org/2010/354.pdf
def sub(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121, b_000, b_001, b_010, b_011, b_020, b_021, b_100, b_101, b_110, b_111, b_120, b_121):
    c0 = fp6.sub(a_000, a_001, a_010, a_011, a_020, a_021, b_000, b_001, b_010, b_011, b_020, b_021)
    c1 = fp6.sub(a_100, a_101, a_110, a_111, a_120, a_121, b_100, b_101, b_110, b_111, b_120, b_121)
    return c0, c1

# Algorithm 20 from https://eprint.iacr.org/2010/354.pdf
def mul(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121, b_000, b_001, b_010, b_011, b_020, b_021, b_100, b_101, b_110, b_111, b_120, b_121):
    t0 = fp6.mul(a_000, a_001, a_010, a_011, a_020, a_021, b_000, b_001, b_010, b_011, b_020, b_021)
    t1 = fp6.mul(a_100, a_101, a_110, a_111, a_120, a_121, b_100, b_101, b_110, b_111, b_120, b_121)
    t2 = fp6.mul_by_gamma(t1[0][0],t1[0][1],t1[1][0],t1[1][1],t1[2][0],t1[2][1])
    c0 = fp6.add(t0[0][0],t0[0][1],t0[1][0],t0[1][1],t0[2][0],t0[2][1],t2[0][0],t2[0][1],t2[1][0],t2[1][1],t2[2][0],t2[2][1])
    t3 = fp6.add(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121)
    t4 = fp6.add(b_000, b_001, b_010, b_011, b_020, b_021, b_100, b_101, b_110, b_111, b_120, b_121)
    c1 = fp6.mul(t3[0][0],t3[0][1],t3[1][0],t3[1][1],t3[2][0],t3[2][1],t4[0][0],t4[0][1],t4[1][0],t4[1][1],t4[2][0],t4[2][1])
    c1 = fp6.sub(c1[0][0],c1[0][1],c1[1][0],c1[1][1],c1[2][0],c1[2][1],t0[0][0],t0[0][1],t0[1][0],t0[1][1],t0[2][0],t0[2][1])
    c1 = fp6.sub(c1[0][0],c1[0][1],c1[1][0],c1[1][1],c1[2][0],c1[2][1],t1[0][0],t1[0][1],t1[1][0],t1[1][1],t1[2][0],t1[2][1])
    return c0, c1

# Algorithm 22 from https://eprint.iacr.org/2010/354.pdf
def square(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121):
    t1 = fp6.sub(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121)
    t2 = fp6.mul_by_gamma(a_100, a_101, a_110, a_111, a_120, a_121)
    t3 = fp6.sub(a_000, a_001, a_010, a_011, a_020, a_021,t2[0][0],t2[0][1],t2[1][0],t2[1][1],t2[2][0],t2[2][1])
    t4 = fp6.mul(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121)
    t5 = fp6.mul(t1[0][0],t1[0][1],t1[1][0],t1[1][1],t1[2][0],t1[2][1],t3[0][0],t3[0][1],t3[1][0],t3[1][1],t3[2][0],t3[2][1])
    t6 = fp6.add(t4[0][0],t4[0][1],t4[1][0],t4[1][1],t4[2][0],t4[2][1],t5[0][0],t5[0][1],t5[1][0],t5[1][1],t5[2][0],t5[2][1])
    c1 = fp6.add(t4[0][0],t4[0][1],t4[1][0],t4[1][1],t4[2][0],t4[2][1],t4[0][0],t4[0][1],t4[1][0],t4[1][1],t4[2][0],t4[2][1])
    t8 = fp6.mul_by_gamma(t4[0][0],t4[0][1],t4[1][0],t4[1][1],t4[2][0],t4[2][1])
    c0 = fp6.add(t6[0][0],t6[0][1],t6[1][0],t6[1][1],t6[2][0],t6[2][1],t8[0][0],t8[0][1],t8[1][0],t8[1][1],t8[2][0],t8[2][1])
    return c0, c1

# Algorithm 23 from https://eprint.iacr.org/2010/354.pdf
def inv(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121):
    t0 = fp6.square(a_000, a_001, a_010, a_011, a_020, a_021)
    t1 = fp6.square(a_100, a_101, a_110, a_111, a_120, a_121)
    t2 = fp6.mul_by_gamma(t1[0][0],t1[0][1],t1[1][0],t1[1][1],t1[2][0],t1[2][1])
    t0 = fp6.sub(t0[0][0],t0[0][1],t0[1][0],t0[1][1],t0[2][0],t0[2][1],t2[0][0],t2[0][1],t2[1][0],t2[1][1],t2[2][0],t2[2][1])
    t1 = fp6.inv(t0[0][0],t0[0][1],t0[1][0],t0[1][1],t0[2][0],t0[2][1])
    c0 = fp6.mul(a_000, a_001, a_010, a_011, a_020, a_021, t1[0][0],t1[0][1],t1[1][0],t1[1][1],t1[2][0],t1[2][1])
    minus_one = fp6.sub(*FP6_ZERO, *FP6_ONE)
    c1 = fp6.mul(minus_one[0][0],minus_one[0][1],minus_one[1][0],minus_one[1][1],minus_one[2][0],minus_one[2][1], a_100, a_101, a_110, a_111, a_120, a_121)
    c1 = fp6.mul(c1[0][0],c1[0][1],c1[1][0],c1[1][1],c1[2][0],c1[2][1], t1[0][0],t1[0][1],t1[1][0],t1[1][1],t1[2][0],t1[2][1])
    return c0, c1

def main():

    fp12_zero = [0 for _ in range(12)]
    fp12_one = [monty.ONE] + [0 for _ in range(11)]
    fp12_all_one = [monty.ONE for _ in range(12)]
    fp12_all_two = [monty.TWO for _ in range(12)]

    # ADDITION
    assert(add(*fp12_zero, *fp12_zero) == (((0, 0), (0, 0), (0, 0)), ((0, 0), (0, 0), (0, 0))))
    assert(add(*fp12_zero, *fp12_all_one) == (((monty.ONE, monty.ONE), (monty.ONE, monty.ONE), (monty.ONE, monty.ONE)), ((monty.ONE, monty.ONE), (monty.ONE, monty.ONE), (monty.ONE, monty.ONE))))
    assert(add(*fp12_all_one, *fp12_zero) == (((monty.ONE, monty.ONE), (monty.ONE, monty.ONE), (monty.ONE, monty.ONE)), ((monty.ONE, monty.ONE), (monty.ONE, monty.ONE), (monty.ONE, monty.ONE))))
    assert(add(*fp12_all_one, *fp12_all_one) == (((monty.TWO, monty.TWO), (monty.TWO, monty.TWO), (monty.TWO, monty.TWO)), ((monty.TWO, monty.TWO), (monty.TWO, monty.TWO), (monty.TWO, monty.TWO))))

    # SUBTRACTION
    assert(sub(*fp12_zero, *fp12_zero) == (((0, 0), (0, 0), (0, 0)), ((0, 0), (0, 0), (0, 0))))
    assert(sub(*fp12_all_two, *fp12_all_one) == (((monty.ONE, monty.ONE), (monty.ONE, monty.ONE), (monty.ONE, monty.ONE)), ((monty.ONE, monty.ONE), (monty.ONE, monty.ONE), (monty.ONE, monty.ONE))))
    assert(sub(*fp12_all_one, *fp12_zero) == (((monty.ONE, monty.ONE), (monty.ONE, monty.ONE), (monty.ONE, monty.ONE)), ((monty.ONE, monty.ONE), (monty.ONE, monty.ONE), (monty.ONE, monty.ONE))))
    assert(sub(*fp12_all_one, *fp12_all_one) == (((0, 0), (0, 0), (0, 0)), ((0, 0), (0, 0), (0, 0))))

    # MULTIPLICATION BY 0
    assert(mul(*fp12_zero, *fp12_zero)) == (((0, 0), (0, 0), (0, 0)), ((0, 0), (0, 0), (0, 0)))
    assert(mul(*fp12_all_one, *fp12_zero)) == (((0, 0), (0, 0), (0, 0)), ((0, 0), (0, 0), (0, 0)))
    assert(mul(*fp12_zero, *fp12_all_two)) == (((0, 0), (0, 0), (0, 0)), ((0, 0), (0, 0), (0, 0)))

    # MULTIPLICATION BY 1
    assert(mul(*fp12_all_one, *fp12_one)) == (((monty.ONE, monty.ONE), (monty.ONE, monty.ONE), (monty.ONE, monty.ONE)), ((monty.ONE, monty.ONE), (monty.ONE, monty.ONE), (monty.ONE, monty.ONE)))
    assert(mul(*fp12_one, *fp12_all_two)) == (((monty.TWO, monty.TWO), (monty.TWO, monty.TWO), (monty.TWO, monty.TWO)), ((monty.TWO, monty.TWO), (monty.TWO, monty.TWO), (monty.TWO, monty.TWO)))

    # SQUARE OF 0 and 1
    assert(square(*fp12_zero) == (((0, 0), (0, 0), (0, 0)), ((0, 0), (0, 0), (0, 0))))
    assert(square(*fp12_one) == (((monty.ONE, 0), (0, 0), (0, 0)), ((0, 0), (0, 0), (0, 0))))

    # MULTIPLICATION AND SQUARE
    assert(mul(*fp12_one, *fp12_one) == square(*fp12_one))
    assert(mul(*fp12_all_one, *fp12_all_one) == square(*fp12_all_one))
    assert(mul(*fp12_all_two, *fp12_all_two) == square(*fp12_all_two))

    # MULTIPLY BY INVERSE
    assert(inv(*fp12_one) == (((monty.ONE, 0), (0, 0), (0, 0)), ((0, 0), (0, 0), (0, 0))))
    fp12_all_one_inverse = inv(*fp12_all_one)
    fp12_all_two_inverse = inv(*fp12_all_two)
    assert(mul(
        *fp12_all_one,
        *fp12_all_one_inverse[0][0],*fp12_all_one_inverse[0][1],*fp12_all_one_inverse[0][2],*fp12_all_one_inverse[1][0],*fp12_all_one_inverse[1][1],*fp12_all_one_inverse[1][2]
    ) == (((monty.ONE, 0), (0, 0), (0, 0)), ((0, 0), (0, 0), (0, 0))))
    assert(mul(
        *fp12_all_two_inverse[0][0],*fp12_all_two_inverse[0][1],*fp12_all_two_inverse[0][2],*fp12_all_two_inverse[1][0],*fp12_all_two_inverse[1][1],*fp12_all_two_inverse[1][2],
        *fp12_all_two,
    ) == (((monty.ONE, 0), (0, 0), (0, 0)), ((0, 0), (0, 0), (0, 0))))


if __name__ == '__main__':
    main()