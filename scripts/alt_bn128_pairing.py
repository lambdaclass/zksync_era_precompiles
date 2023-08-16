import montgomery as monty
import quadratic_extension_field_arithmetic as fp2

def double_step(ixt, xt, iyt, yt, izt, zt, xp, yp):
    '''Double over E'(Fp^2)'''
    six = monty.into(6)
    four = monty.into(4)
    eight = monty.into(8)
    yt_squared, iyt_squared = fp2.mul(yt, iyt, yt, yt)
    xt_yt_squared, ixt_yt_squared = fp2.mul(xt, ixt, yt_squared, iyt_squared)
    four_xt_yt_squared, ifour_xt_yt_squared = fp2.mul(four, 0, xt_yt_squared, ixt_yt_squared)
    three_xt_squared, ithree_xt_squared = fp2.add(fp2.add(xt_squared, ixt_squared, xt_squared, ixt_squared), xt_squared, ixt_squared)
    nine_xt_quartic, inine_xt_quartic = fp2.mul(three_xt_squared, ithree_xt_squared, three_xt_squared, ithree_xt_squared)
    
    xr, ixr = fp2.sub(nine_xt_quartic, inine_xt_quartic, fp2.add(four_xt_yt_squared, ifour_xt_yt_squared, four_xt_yt_squared, ifour_xt_yt_squared))
    
    xt_squared, ixt_squared = fp2.mul(xt, ixt, xt, ixt)
    yt_quartic, iyt_quartic = fp2.mul(yt_squared, iyt_squared, yt_squared, iyt_squared)
    
    yr, iyr = fp2.sub(fp2.mul(three_xt_squared, ithree_xt_squared, fp2.sub(four_xt_yt_squared, ifour_xt_yt_squared, xr, ixr)), fp2.mul(eight, 0, yt_quartic, iyt_quartic))
    
    ytzt, iytzt = fp2.mul(yt, iyt, zt, izt)

    zr, izr = fp2.add(ytzt, iytzt, ytzt, iytzt)

    '''Line evaluation'''
    zt_squared, izt_squared = fp2.mul(zt, izt, zt, izt)
    zr_zt_squared_yp, izr_zt_squared_yp = fp2.mul(fp2.mul(zr, izr, zt_squared, izt_squared), yp, 0)
    e0, ie0 = fp2.add(zr_zt_squared_yp, izr_zt_squared_yp, zr_zt_squared_yp, izr_zt_squared_yp)
    six_xt_squared, isix_xt_squared = fp2.mul(six, 0, xt_squared, 0)
    e1, ie1 = fp2.sub(0, 0, fp2.mul(fp2.mul(six_xt_squared, isix_xt_squared, zt_squared, izt_squared), xp, 0))
    six_xt_qubed, isix_xt_qubed = fp2.mul(six_xt_squared, isix_xt_squared, xt, ixt)
    four_yt_squared, ifour_yt_squared = fp2.mul(four, 0, yt_squared, iyt_squared)
    e2, ie2 = fp2.sub(six_xt_qubed, isix_xt_qubed, four_yt_squared, ifour_yt_squared)

    return xr, ixr, yr, iyr, zr, izr, e0, ie0, e1, ie1, e2, ie2

def addition_step(xt, ixt, yt, iyt, zt, izt, xq, ixq, yq, iyq, zq, izq, xp, yp):
    four = monty.into(4)
    '''Addition over E'(Fp^2)'''
    # XqZt^2
    zt_squared, izt_squared = fp2.mul(zt, izt, zt, izt)
    # Zt^2
    zt_cubed, izt_cubed = fp2.mul(zt_squared, izt_squared, zt, izt)
    # YqZt^3
    yq_zt_qubed, iyq_zt_qubed = fp2.mul(yq, iyq, zt_cubed, izt_cubed)
    # 2YqZt^3
    two_yq_zt_qubed, itwo_yq_zt_qubed = fp2.add(yq_zt_qubed, iyq_zt_qubed, yq_zt_qubed, iyq_zt_qubed)
    # XqZt^2 - Xt
    xq_zt_squared_minus_xt, ixq_zt_squared_minus_xt = fp2.sub(fp2.mul(xq, ixq, zt_squared, izt_squared), xt, ixt)
    # (XqZt^2 - Xt)^2
    xq_zt_squared_minus_xt_squared, ixq_zt_squared_minus_xt_squared = fp2.mul(xq_zt_squared_minus_xt, ixq_zt_squared_minus_xt, xq_zt_squared_minus_xt, ixq_zt_squared_minus_xt)
    # 4(XqZt^2 - Xt)^2
    four_xq_zt_squared_minus_xt_squared, ifour_xq_zt_squared_minus_xt_squared = fp2.mul(four, 0, xq_zt_squared_minus_xt_squared, ixq_zt_squared_minus_xt_squared)
    # 8(XqZt^2 - Xt)^2
    eight_xq_zt_squared_minus_xt_squared, ieight_xq_zt_squared_minus_xt_squared = fp2.add(four_xq_zt_squared_minus_xt_squared, ifour_xq_zt_squared_minus_xt_squared, four_xq_zt_squared_minus_xt_squared, ifour_xq_zt_squared_minus_xt_squared)
    # 4(XqZt^2 - Xt)^3
    four_xq_zt_squared_minus_xt_cubed, ifour_xq_zt_squared_minus_xt_cubed = fp2.mul(four_xq_zt_squared_minus_xt_squared, ifour_xq_zt_squared_minus_xt_squared, xq_zt_squared_minus_xt, ixq_zt_squared_minus_xt)
    # 8(XqZt^2 - Xt)^3
    eight_xq_zt_squared_minus_xt_cubed, ieight_xq_zt_squared_minus_xt_cubed = fp2.add(four_xq_zt_squared_minus_xt_cubed, ifour_xq_zt_squared_minus_xt_cubed, four_xq_zt_squared_minus_xt_cubed, ifour_xq_zt_squared_minus_xt_cubed)
    # 2YqZt^3 - 2Yt
    two_yq_zt_qubed_minus_two_yt, itwo_yq_zt_qubed_minus_two_yt = fp2.sub(two_yq_zt_qubed, itwo_yq_zt_qubed, fp2.add(yt, iyt, yt, iyt))
    # (2YqZt^3 - 2Yt)^2
    two_yq_zt_qubed_minus_two_yt_squared, itwo_yq_zt_qubed_minus_two_yt_squared = fp2.mul(two_yq_zt_qubed_minus_two_yt, itwo_yq_zt_qubed_minus_two_yt, two_yq_zt_qubed_minus_two_yt, itwo_yq_zt_qubed_minus_two_yt)

    xr, ixr = fp2.sub(two_yq_zt_qubed_minus_two_yt_squared, itwo_yq_zt_qubed_minus_two_yt_squared, fp2.sub(four_xq_zt_squared_minus_xt_cubed, ifour_xq_zt_squared_minus_xt_cubed, fp2.mul(eight_xq_zt_squared_minus_xt_squared, ieight_xq_zt_squared_minus_xt_squared, xt, ixt)))

    # 8Yt(XqZt^2 - Xt)^3
    eight_yt_xq_zt_squared_minus_xt_cubed, ieight_yt_xq_zt_squared_minus_xt_cubed = fp2.mul(eight_xq_zt_squared_minus_xt_cubed, ieight_xq_zt_squared_minus_xt_cubed, yt, iyt)
    # 4(XqZt^2 - Xt)^2*Xt - Xr
    four_xq_zt_squared_minus_xt_squared_xt_minus_xr, ifour_xq_zt_squared_minus_xt_squared_xt_minus_xr = fp2.sub(fp2.mul(four_xq_zt_squared_minus_xt_squared, ifour_xq_zt_squared_minus_xt_squared, xt, ixt), xr, ixr)
    
    yr, iyr = fp2.sub(fp2.mul(two_yq_zt_qubed_minus_two_yt, itwo_yq_zt_qubed_minus_two_yt, four_xq_zt_squared_minus_xt_squared_xt_minus_xr, ifour_xq_zt_squared_minus_xt_squared_xt_minus_xr), eight_yt_xq_zt_squared_minus_xt_cubed, ieight_yt_xq_zt_squared_minus_xt_cubed)
    
    zt_xq_zt_squared_minus_xt, izt_xq_zt_squared_minus_xt = fp2.mul(xq_zt_squared_minus_xt, ixq_zt_squared_minus_xt, zt, izt)

    zr, izr = fp2.add(zt_xq_zt_squared_minus_xt, izt_xq_zt_squared_minus_xt, zt_xq_zt_squared_minus_xt, izt_xq_zt_squared_minus_xt)
    
    '''Line evaluation'''
    # ZrYp
    zr_yp, izr_yp = fp2.mul(zr, izr, yp, 0)
    # 2ZrYp
    e0, ie0 = fp2.add(zr_yp, izr_yp, zr_yp, izr_yp)
    # -4Xp(YqZtˆ3 + Yt)
    e1, ie1 = fp2.sub(0, 0, fp2.mul(four, 0, fp2.mul(fp2.add(yq_zt_qubed, iyq_zt_qubed, yt, iyt), xp, 0)))
    # YqZtˆ3Xq
    yq_zt_qubed_xq, iyq_zt_qubed_xq = fp2.mul(yq_zt_qubed, iyq_zt_qubed, xq, ixq)
    # (YqZtˆ3Xq-Yt)
    yq_zt_qubed_xq_minus_yt, iyq_zt_qubed_xq_minus_yt = fp2.sub(yq_zt_qubed_xq, iyq_zt_qubed_xq, yt, iyt)
    # 4Xq
    four_xq, ifour_xq = fp2.mul(four, 0, xq, ixq)
    # 4Xq(YqZtˆ3Xq-Yt)
    four_xq_yq_zt_qubed_xq_minus_yt, ifour_xq_yq_zt_qubed_xq_minus_yt = fp2.mul(four_xq, ifour_xq, yq_zt_qubed_xq_minus_yt, iyq_zt_qubed_xq_minus_yt)
    # YqZt
    yq_zr, iyq_zr = fp2.mul(yq, iyq, zr, izr)
    # 2YqZt
    two_xq_zr, itwo_xq_zr = fp2.add(yq_zr, iyq_zr, yq_zr, iyq_zr)
    # 4Xq(YqZtˆ3Xq-Yt)-2YqZt
    e2, ie2 = fp2.sub(four_xq_yq_zt_qubed_xq_minus_yt, ifour_xq_yq_zt_qubed_xq_minus_yt, two_xq_zr, itwo_xq_zr)

    return xr, ixr, yr, iyr, zr, izr, e0, ie0, e1, ie1, e2, ie2
    
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