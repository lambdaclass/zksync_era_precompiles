import montgomery as monty
import fp2 as fp2

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
    Zt = fp2.sub(*Zt,Zq_squared)
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
    T = (Xt, Yt, Zt)
    l = (*t3,0,0,0,0,*t3,*t6,0,0)
    return l, T

# Algorithm 27 from https://eprint.iacr.org/2010/354.pdf
# P belongs to curve E over Fp in affine coordinates: P = (xp, yp)
# Q belongs to curve E' over Fp2 in Jacobian coordinates: Q = (Xq, Yq, Zq)
# R belongs to curve E' over Fp2 in Jacobian coordinates: R = (Xr, Yr, Zr)
def line_function_add_point(xq0, xq1, yq0, yq1, _zq0, _zq1, xr0, xr1, yr0, yr1, zr0, zr1, xp, yp, _zp):
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

    T = *X_T, *Y_T, *Z_T
    return l, T

# TODO
def miller_loop(xp, yp, ixq, xq, iyq, yq, izq, zq):
    T = ixq, xq, iyq, yq, izq, zq
    f = ((0, 0), (0, 0), (1, 0))
    f = ((0, 1), (0, 0), (0, 0))

    for i in range(L-2, 0, -1):
        xr, yr, zr, e0, e1, e2 = double_step(*T, *P)
        # f <- f^2 * l(T, T, P)
        # TODO
        # T <- 2T
        T = xr, yr, zr
        if s[i] == -1:
            xr, yr, zr, e0, e1, e2 = addition_step(*T, *Q, *P)
            # f <- f * l(T, -Q, P)
            # TODO
            # T <- T - Q
            T = xr, yr, zr
        elif s[i] == 1:
            Q_neg = Q[0], monty.sub(0, Q[1]), Q[2]
            xr, yr, zr, e0, e1, e2 = addition_step(*T, *Q_neg, *P)
            # f <- f * l(T, Q, P)
            # TODO
            # T <- T + Q
            T = xr, yr, zr


def main():
    pass

if __name__ == '__main__':
    main()
