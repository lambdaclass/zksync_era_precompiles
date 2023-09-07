import montgomery as monty
import fp6
import fp2
import frobenius as frb

ZERO = (0,0,0,0,0,0,0,0,0,0,0,0)
ONE = [monty.ONE] + [0 for _ in range(11)]

# Algorithm 18 from https://eprint.iacr.org/2010/354.pdf
def add(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121, b_000, b_001, b_010, b_011, b_020, b_021, b_100, b_101, b_110, b_111, b_120, b_121):
    c0 = fp6.add(a_000, a_001, a_010, a_011, a_020, a_021, b_000, b_001, b_010, b_011, b_020, b_021)
    c1 = fp6.add(a_100, a_101, a_110, a_111, a_120, a_121, b_100, b_101, b_110, b_111, b_120, b_121)
    return c0 + c1

# Algorithm 19 from https://eprint.iacr.org/2010/354.pdf
def sub(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121, b_000, b_001, b_010, b_011, b_020, b_021, b_100, b_101, b_110, b_111, b_120, b_121):
    c0 = fp6.sub(a_000, a_001, a_010, a_011, a_020, a_021, b_000, b_001, b_010, b_011, b_020, b_021)
    c1 = fp6.sub(a_100, a_101, a_110, a_111, a_120, a_121, b_100, b_101, b_110, b_111, b_120, b_121)
    return c0 + c1

# Algorithm 20 from https://eprint.iacr.org/2010/354.pdf
def mul(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121, b_000, b_001, b_010, b_011, b_020, b_021, b_100, b_101, b_110, b_111, b_120, b_121):
    t0 = fp6.mul(a_000, a_001, a_010, a_011, a_020, a_021, b_000, b_001, b_010, b_011, b_020, b_021)
    t1 = fp6.mul(a_100, a_101, a_110, a_111, a_120, a_121, b_100, b_101, b_110, b_111, b_120, b_121)
    t2 = fp6.mul_by_gamma(*t1)
    c0 = fp6.add(*t0,*t2)
    t3 = fp6.add(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121)
    t4 = fp6.add(b_000, b_001, b_010, b_011, b_020, b_021, b_100, b_101, b_110, b_111, b_120, b_121)
    c1 = fp6.mul(*t3,*t4)
    c1 = fp6.sub(*c1,*t0)
    c1 = fp6.sub(*c1,*t1)
    return c0 + c1

# Algorithm 22 from https://eprint.iacr.org/2010/354.pdf
def square(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121):
    t1 = fp6.sub(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121)
    t2 = fp6.mul_by_gamma(a_100, a_101, a_110, a_111, a_120, a_121)
    t3 = fp6.sub(a_000, a_001, a_010, a_011, a_020, a_021,*t2)
    t4 = fp6.mul(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121)
    t5 = fp6.mul(*t1,*t3)
    t6 = fp6.add(*t4,*t5)
    c1 = fp6.add(*t4,*t4)
    t8 = fp6.mul_by_gamma(*t4)
    c0 = fp6.add(*t6,*t8)
    return c0 + c1

# Algorithm 23 from https://eprint.iacr.org/2010/354.pdf
def inv(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121):
    t0 = fp6.square(a_000, a_001, a_010, a_011, a_020, a_021)
    t1 = fp6.square(a_100, a_101, a_110, a_111, a_120, a_121)
    t2 = fp6.mul_by_gamma(*t1)
    t0 = fp6.sub(*t0,*t2)
    t1 = fp6.inv(*t0)
    c0 = fp6.mul(a_000, a_001, a_010, a_011, a_020, a_021, *t1)
    minus_one = fp6.sub(*fp6.ZERO, *fp6.ONE)
    c1 = fp6.mul(*minus_one, a_100, a_101, a_110, a_111, a_120, a_121)
    c1 = fp6.mul(*c1,*t1)
    return c0 + c1

def conjugate(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121):
    return (a_000, a_001, a_010, a_011, a_020, a_021) + fp6.neg(a_100, a_101, a_110, a_111, a_120, a_121)

def cyclotomic_square(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121):
    t0 = fp2.mul(a_110, a_111, a_110, a_111)
    t1 = fp2.mul(a_000, a_001, a_000, a_001)
    t6 = fp2.add(a_110, a_111, a_000, a_001)
    t6 = fp2.mul(*t6, *t6)
    t6 = fp2.sub(*t6, *t0)
    t6 = fp2.sub(*t6, *t1)
    t2 = fp2.mul(a_020, a_021, a_020, a_021)
    t3 = fp2.mul(a_100, a_101, a_100, a_101)
    t7 = fp2.add(a_020, a_021, a_100, a_101)
    t7 = fp2.mul(*t7, *t7)
    t7 = fp2.sub(*t7, *t2)
    t7 = fp2.sub(*t7, *t3)
    t4 = fp2.mul(a_120, a_121, a_120, a_121)
    t5 = fp2.mul(a_010, a_011, a_010, a_011)
    t8 = fp2.add(a_120, a_121, a_010, a_011)
    t8 = fp2.mul(*t8, *t8)
    t8 = fp2.sub(*t8, *t4)
    t8 = fp2.sub(*t8, *t5)
    t8 = fp2.mul_by_xi(*t8)
    t0 = fp2.mul_by_xi(*t0)
    t0 = fp2.add(*t0, *t1)
    t2 = fp2.mul_by_xi(*t2)
    t2 = fp2.add(*t2, *t3)
    t4 = fp2.mul_by_xi(*t4)
    t4 = fp2.add(*t4, *t5)
    
    c0c0 = fp2.sub(*t0, a_000, a_001)
    c0c0 = fp2.add(*c0c0, *c0c0)
    c0c0 = fp2.add(*c0c0, *t0)

    c0c1 = fp2.sub(*t2, a_010, a_011)
    c0c1 = fp2.add(*c0c1, *c0c1)
    c0c1 = fp2.add(*c0c1, *t2)

    c0c2 = fp2.sub(*t4, a_020, a_021)
    c0c2 = fp2.add(*c0c2, *c0c2)
    c0c2 = fp2.add(*c0c2, *t4)

    c1c0 = fp2.add(*t8, a_100, a_101)
    c1c0 = fp2.add(*c1c0, *c1c0)
    c1c0 = fp2.add(*c1c0, *t8)

    c1c1 = fp2.add(*t6, a_110, a_111)
    c1c1 = fp2.add(*c1c1, *c1c1)
    c1c1 = fp2.add(*c1c1, *t6)

    c1c2 = fp2.add(*t7, a_120, a_121)
    c1c2 = fp2.add(*c1c2, *c1c2)
    c1c2 = fp2.add(*c1c2, *t7)

    c0 = c0c0 + c0c1 + c0c2
    c1 = c1c0 + c1c1 + c1c2

    return c0 + c1

def n_square(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121, n):
    out = a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121

    for i in range(0, n):
        out = cyclotomic_square(*out)

    return out

# def is_in_subgroup(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121):
#     a = frb.frobenius(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121)
#     b = exponentiation(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121)
#     b = exponentiation(*b)
#     b = cyclotomic_square(*b)
#     b2 = cyclotomic_square(*b)
#     b = mul(*b, *b2)
#     return a == b

def exponentiation(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121):
    t3 = cyclotomic_square(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121)
    t5 = cyclotomic_square(*t3)
    result = cyclotomic_square(*t5)
    t0 = cyclotomic_square(*result)
    t2 = mul(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121, *t0)
    t0 = mul(*t2, *t3)
    t1 = mul(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121, *t0)
    t4 = mul(*result, *t2)
    t6 = cyclotomic_square(*t2)
    t1 = mul(*t1, *t0)
    t0 = mul(*t1, *t3)
    t6 = n_square(*t6, 6)
    t5 = mul(*t5, *t6)
    t5 = mul(*t4, *t5)
    t5 = n_square(*t5, 7)
    t4 = mul(*t4, *t5)
    t4 = n_square(*t4, 8)
    t4 = mul(*t4, *t0)
    t3 = mul(*t3, *t4)
    t3 = n_square(*t3, 6)
    t2 = mul(*t2, *t3)
    t2 = n_square(*t2, 8)
    t2 = mul(*t0, *t2)
    t2 = n_square(*t2, 6)
    t2 = mul(*t0, *t2)
    t2 = n_square(*t2, 10)
    t1 = mul(*t1, *t2)
    t1 = n_square(*t1, 6)
    t0 = mul(*t0, *t1)
    result = mul(*result, *t0)
    return result

def main():

    fp12_zero = tuple([0 for _ in range(12)])
    fp12_one = tuple([monty.ONE] + [0 for _ in range(11)])
    fp12_two = tuple([monty.TWO] + [0 for _ in range(11)])
    fp12_all_one = tuple([monty.ONE for _ in range(12)])
    fp12_all_two = tuple([monty.TWO for _ in range(12)])
    ffp12_random = (monty.ONE, monty.TWO, monty.ONE, monty.TWO, monty.ONE, monty.TWO, monty.ONE, monty.TWO, monty.ONE, monty.TWO, monty.ONE, monty.TWO)

    # ADDITION
    assert(add(*fp12_zero, *fp12_zero) == fp12_zero)
    assert(add(*fp12_zero, *fp12_all_one) == fp12_all_one)
    assert(add(*fp12_all_one, *fp12_zero) == fp12_all_one)
    assert(add(*fp12_all_one, *fp12_all_one) == fp12_all_two)

    # SUBTRACTION
    assert(sub(*fp12_zero, *fp12_zero) == fp12_zero)
    assert(sub(*fp12_all_two, *fp12_all_one) == fp12_all_one)
    assert(sub(*fp12_all_one, *fp12_zero) == fp12_all_one)
    assert(sub(*fp12_all_one, *fp12_all_one) == fp12_zero)

    # MULTIPLICATION BY 0
    assert(mul(*fp12_zero, *fp12_zero) == fp12_zero)
    assert(mul(*fp12_all_one, *fp12_zero) == fp12_zero)
    assert(mul(*fp12_zero, *fp12_all_two) == fp12_zero)

    # MULTIPLICATION BY 1
    assert(mul(*fp12_all_one, *fp12_one) == fp12_all_one)
    assert(mul(*fp12_one, *fp12_all_two) == fp12_all_two)

    # MULTIPLICATION BY 2
    assert(mul(*fp12_all_one, *fp12_two) == add(*fp12_all_one, *fp12_all_one))
    assert(mul(*fp12_two, *fp12_all_two) == add(*fp12_all_two, *fp12_all_two))

    # SQUARE OF 0 and 1
    assert(square(*fp12_zero) == fp12_zero)
    assert(square(*fp12_one) == fp12_one)

    # MULTIPLICATION AND SQUARE
    assert(mul(*fp12_one, *fp12_one) == square(*fp12_one))
    assert(mul(*fp12_all_one, *fp12_all_one) == square(*fp12_all_one))
    assert(mul(*fp12_all_two, *fp12_all_two) == square(*fp12_all_two))

    # MULTIPLY BY INVERSE
    assert(inv(*fp12_one) == fp12_one)
    fp12_all_one_inverse = inv(*fp12_all_one)
    fp12_all_two_inverse = inv(*fp12_all_two)
    assert(mul(*fp12_all_one,*fp12_all_one_inverse) == fp12_one)
    assert(mul(*fp12_all_two_inverse, *fp12_all_two) == fp12_one)


    # CYCLOTOMIC SQUARE
    b = conjugate(*ffp12_random)
    a = inv(*ffp12_random)
    b = mul(*b, *a)
    a = frb.frobenius_square(*b)
    a = mul(*a, *b)
    c = square(*a)
    d = cyclotomic_square(*a)
    assert(c == d)

if __name__ == '__main__':
    main()
