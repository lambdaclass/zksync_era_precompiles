import pairing_utils
import montgomery as monty
import fp2 as fp2
import fp12
import frobenius as frb
import g2

# Algorithm 26. https://eprint.iacr.org/2010/354.pdf
# P belongs to curve E over Fp in affine coordinates: P = (xp, yp)
# Q belongs to curve E' over Fp2 in Jacobian coordinates: Q = (Xq, Yq, Zq)
def point_doubling_and_line_evaluation(Xq0, Xq1, Yq0, Yq1, Zq0, Zq1, xp, yp):
    t0 = fp2.mul(Xq0,Xq1,Xq0,Xq1)
    t1 = fp2.mul(Yq0,Yq1,Yq0,Yq1)
    t2 = fp2.mul(*t1,*t1)
    # TODO: This could be an optimization in the future, make sure to test it
    # t3 = fp2.mul(*t1,Xq0,Xq1)
    # t3 = fp2.add(*t3, *t3)
    t3 = fp2.add(*t1,Xq0,Xq1)
    t3 = fp2.mul(*t3,*t3)
    t3 = fp2.sub(*t3,*t0)
    t3 = fp2.sub(*t3,*t2)
    t3 = fp2.add(*t3,*t3)
    t4 = fp2.scalar_mul(*t0,monty.THREE)
    t6 = fp2.add(Xq0,Xq1,*t4)
    t5 = fp2.mul(*t4,*t4)
    Xt = fp2.scalar_mul(*t3,2)
    Xt = fp2.sub(*t5,*Xt)
    Zq_squared = fp2.mul(Zq0,Zq1,Zq0,Zq1)
    # TODO: This could be an optimization in the future, make sure to test it
    # Zt = fp2.mul(Yq0,Yq1,Zq0,Zq1 )
    # Zt = fp2.add(*Zt, *Zt)
    Zt = fp2.add(Yq0,Yq1,Zq0,Zq1)
    Zt = fp2.mul(*Zt,*Zt)
    Zt = fp2.sub(*Zt,*t1)
    Zt = fp2.sub(*Zt, *Zq_squared)
    t2_times_eight = fp2.scalar_mul(*t2,monty.EIGHT)
    Yt = fp2.sub(*t3,*Xt)
    Yt = fp2.mul(*Yt,*t4)
    Yt = fp2.sub(*Yt,*t2_times_eight)
    t3 = fp2.mul(*Zq_squared,*t4)
    t3 = fp2.add(*t3,*t3)
    t3 = fp2.sub(0,0,*t3) # multiply by -1
    t3 = fp2.scalar_mul(*t3,xp)
    t1_times_4 = fp2.scalar_mul(*t1,monty.FOUR)
    t6 = fp2.mul(*t6,*t6)
    t6 = fp2.sub(*t6,*t0)
    t6 = fp2.sub(*t6,*t5)
    t6 = fp2.sub(*t6,*t1_times_4)
    t0 = fp2.mul(*Zt,*Zq_squared)
    t0 = fp2.add(*t0,*t0)
    t0 = fp2.scalar_mul(*t0,yp)
    T = Xt, Yt, Zt
    l = (*t3,0,0,0,0,*t3,*t6,0,0)
    return l, T

# Algorithm 27 from https://eprint.iacr.org/2010/354.pdf
# P belongs to curve E over Fp in affine coordinates: P = (xp, yp)
# Q belongs to curve E' over Fp2 in Jacobian coordinates: Q = (Xq, Yq, Zq)
# R belongs to curve E' over Fp2 in Jacobian coordinates: R = (Xr, Yr, Zr)
def point_addition_and_line_evaluation(xq0, xq1, yq0, yq1, _zq0, _zq1, xr0, xr1, yr0, yr1, zr0, zr1, xp, yp):
    zr_squared = fp2.mul(zr0, zr1, zr0, zr1)
    yq_squared = fp2.mul(yq0, yq1, yq0, yq1)
    yr_doubled = fp2.add(yr0, yr1, yr0, yr1)
    t0 = fp2.mul(xq0, xq1, *zr_squared)

    # TODO: This could be an optimization in the future, make sure to test it
    # t1 = fp2.mul(yq0, yq1, zr0, zr1)
    # t1 = fp2.add(*t1, *t1)
    t1 = fp2.add(yq0, yq1, zr0, zr1)
    t1 = fp2.mul(*t1, *t1)
    t1 = fp2.sub(*t1, *yq_squared)
    t1 = fp2.sub(*t1, *zr_squared)
    t1 = fp2.mul(*t1, *zr_squared)
    
    t2 = fp2.sub(*t0, xr0, xr1)
    t3 = fp2.mul(*t2, *t2)
    t4 = fp2.add(*t3, *t3)
    t4 = fp2.add(*t4, *t4)
    t5 = fp2.mul(*t4, *t2)
    t6 = fp2.sub(*t1, *yr_doubled)
    t9 = fp2.mul(*t6, xq0, xq1)
    t7 = fp2.mul(xr0, xr1, *t4)
    X_T = fp2.mul(*t6, *t6)
    X_T = fp2.sub(*X_T, *t5)
    X_T = fp2.sub(*X_T, *fp2.add(*t7, *t7))

    # TODO: This could be an optimization in the future, make sure to test it
    # Z_T = fp2.mul(zr0, zr1, *t2)
    # Z_T = fp2.add(*Z_T, *Z_T)
    Z_T = fp2.add(zr0, zr1, *t2)
    Z_T = fp2.mul(*Z_T, *Z_T)
    Z_T = fp2.sub(*Z_T, *zr_squared)
    Z_T = fp2.sub(*Z_T, *t3)

    t10 = fp2.add(yq0, yq1, *Z_T)
    t8 = fp2.sub(*t7, *X_T)
    t8 = fp2.mul(*t8, *t6)
    t0 = fp2.mul(yr0, yr1, *t5)
    t0 = fp2.add(*t0, *t0)
    Y_T = fp2.sub(*t8, *t0)

    # TODO: This could be an optimization in the future, make sure to test it
    # t10 = fp2.mul(yq0, yq1, *Z_T)
    # t10 = fp2.add(*t10, *t10)
    t10 = fp2.mul(*t10, *t10)
    t10 = fp2.sub(*t10, *yq_squared)
    t10 = fp2.sub(*t10, *fp2.mul(*Z_T, *Z_T))

    t9 = fp2.add(*t9, *t9)
    t9 = fp2.sub(*t9, *t10)
    t10 = fp2.scalar_mul(*Z_T, yp)
    t10 = fp2.add(*t10, *t10)
    t6 = fp2.neg(*t6)
    t1 = fp2.scalar_mul(*t6, xp)
    t1 = fp2.add(*t1, *t1)

    l0 = t10[0], t10[1], 0, 0, 0, 0
    l1 = t1[0], t1[1], t9[0], t9[1], 0, 0
    l = l0 + l1

    T = X_T, Y_T, Z_T
    return l, T

# Algorithm 31 from https://eprint.iacr.org/2010/354.pdf
def final_exponentiation(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121):
    
    f = (a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121)
    # First part
    f1 = fp12.conjugate(*f)
    f2 = fp12.inv(*f)
    f = fp12.mul(*f1, *f2)
    f_aux = frb.frobenius_square(*f)
    f = fp12.mul(*f_aux, *f)

    # Second part
    ft_1 = fp12.exponentiation(*f)
    ft_2 = fp12.square(*ft_1)
    ft_3 = fp12.mul(*ft_2, *ft_1)

    fp_1 = frb.frobenius(*f)
    fp_2 = frb.frobenius_square(*f)
    fp_3 = frb.frobenius_cube(*f)

    y0 = fp12.mul(*fp_1, *fp_2)
    y0 = fp12.mul(*y0, *fp_3)
    
    y1 = f1
    y2 = frb.frobenius_square(*ft_2)
    y3 = frb.frobenius(*ft_1)
    y3 = fp12.conjugate(*y3)
    y4 = frb.frobenius(*ft_2)
    y4 = fp12.mul(*y4, *ft_1)
    y4 = fp12.conjugate(*y4)
    y5 = fp12.conjugate(*ft_2)
    y6 = frb.frobenius(*ft_3)
    y6 = fp12.mul(*y6, *ft_3)
    y6 = fp12.conjugate(*y6)

    t0 = fp12.square(*y6)
    t0 = fp12.mul(*t0, *y4)
    t0 = fp12.mul(*t0, *y5)

    t1 = fp12.mul(*y3, *y5)
    t1 = fp12.mul(*t1, *t0)

    t0 = fp12.mul(*t0, *y2)

    t1 = fp12.square(*t1)
    t1 = fp12.mul(*t1, *t0)
    t1 = fp12.square(*t1)

    t0 = fp12.mul(*t1, *y1)
    t1 = fp12.mul(*t1, *y0)
    t0 = fp12.square(*t0)
    f = fp12.mul(*t0, *t1)

    return f

def miller_loop(xp, yp, Xq0, Xq1, Yq0, Yq1, Zq0, Zq1):
    T = (Xq0, Xq1, Yq0, Yq1, Zq0, Zq1)
    f = fp12.ONE
    
    for i in range(64, -1, -1):
        double_step = point_doubling_and_line_evaluation(xp,yp,*T)
        f = fp12.square(*f)
        f = fp12.mul(*f,*double_step[0])
        T = double_step[1]

        if pairing_utils.S_NAF[i] == -1: 
            minus_Q = g2.neg(Xq0, Xq1, Yq0, Yq1, Zq0, Zq1)
            add_step = point_addition_and_line_evaluation(*minus_Q,*T,xp,yp)
            f = fp12.mul(*f,*add_step[0])
            T = add_step[1]

        elif pairing_utils.S_NAF[i] == 1:
            add_step = point_addition_and_line_evaluation(Xq0, Xq1, Yq0, Yq1, Zq0, Zq1,*T,xp,yp)
            f = fp12.mul(*f,*add_step[0])
            T = add_step[1]

    # Q1 <- pi_p(Q)
    Xq1 = fp2.conj(Xq0, Xq1)
    Yq1 = fp2.conj(Yq0, Yq1)
    Xq1 = frb.mul_by_gamma_1_2(*Xq1)
    Yq1 = frb.mul_by_gamma_1_3(*Xq1)
    Q1 = g2.from_affine(*Xq1, *Yq1)

    # Q2 <- pi_p_square(Q)
    Xq2 = frb.mul_by_gamma_2_2(Xq0, Xq1)
    Yq2 = frb.mul_by_gamma_2_3(Yq0, Yq1)
    Q2 = g2.from_affine(*Xq2, *Yq2)
    Q2 = g2.neg(Q2)
    
    add_step = point_addition_and_line_evaluation(*Q1,*T,xp,yp)
    f = fp12.mul(*f,*add_step[0])
    T = add_step[1]

    add_step = point_addition_and_line_evaluation(*Q2,*T,xp,yp)
    f = fp12.mul(*f,*add_step[0])

    return f

def main():
    # Test 1
    fp12_a = (monty.ONE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    result = final_exponentiation(*fp12_a)
    assert(result == fp12_a)

    # Test 2
    # This test won't pass
    # fp12_b = (monty.ONE, monty.TWO, monty.ONE, monty.TWO, monty.ONE, monty.TWO, monty.ONE, monty.TWO, monty.ONE, monty.TWO, monty.ONE, monty.TWO)
    # result = final_exponentiation(*fp12_b)
    # assert(not fp12.is_in_subgroup(*fp12_b))
    # assert(fp12.is_in_subgroup(*result))

if __name__ == '__main__':
    main()
