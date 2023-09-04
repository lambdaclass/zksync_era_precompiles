import pairing_utils
import montgomery as monty
import fp2 as fp2
import fp12
import frobenius as frb
import g2
import pairing_utils as utils

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
    Xt = fp2.scalar_mul(*t3, monty.TWO)
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
    t3 = fp2.scalar_mul(*t3, xp)
    t1_times_4 = fp2.scalar_mul(*t1,monty.FOUR)
    t6 = fp2.mul(*t6,*t6)
    t6 = fp2.sub(*t6,*t0)
    t6 = fp2.sub(*t6,*t5)
    t6 = fp2.sub(*t6,*t1_times_4)
    t0 = fp2.mul(*Zt,*Zq_squared)
    t0 = fp2.add(*t0,*t0)
    t0 = fp2.scalar_mul(*t0,yp)
    T = Xt + Yt + Zt
    l = (*t0,0,0,0,0,*t3,*t6,0,0)
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

    T = X_T + Y_T + Z_T
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

def miller_loop(Xq0, Xq1, Yq0, Yq1, Zq0, Zq1, xp, yp):
    T = Xq0, Xq1, Yq0, Yq1, Zq0, Zq1
    f = fp12.ONE

    for i in range(len(utils.S_NAF) - 1, -1, -1):
        line_eval, double_step = point_doubling_and_line_evaluation(*T, xp, yp)
        f = fp12.square(*f)
        f = fp12.mul(*f,*line_eval)
        T = double_step

        if pairing_utils.S_NAF[i] == -1:
            minus_Q = g2.neg(Xq0, Xq1, Yq0, Yq1, Zq0, Zq1)
            line_eval, add_step = point_addition_and_line_evaluation(*minus_Q, *T, xp,yp)
            f = fp12.mul(*f, *line_eval)
            T = add_step

        elif pairing_utils.S_NAF[i] == 1:
            line_eval, add_step = point_addition_and_line_evaluation(Xq0, Xq1, Yq0, Yq1, Zq0, Zq1,*T,xp,yp)
            f = fp12.mul(*f,*line_eval)
            T = add_step

    # Q1 <- pi_p(Q)
    X_q0, X_q1 = fp2.conjugate(Xq0, Xq1)
    Y_q0, Y_q1 = fp2.conjugate(Yq0, Yq1)
    X_q0, X_q1 = frb.mul_by_gamma_1_2(X_q0, X_q1)
    Y_q0, Y_q1 = frb.mul_by_gamma_1_3(Y_q0, Y_q1)
    Q1 = g2.from_affine(X_q0, X_q1, Y_q0, Y_q1)

    # Q2 <- pi_p_square(Q)
    X_q20, X_q21 = frb.mul_by_gamma_2_2(Xq0, Xq1)
    Y_q20, Y_q21 = frb.mul_by_gamma_2_3(Yq0, Yq1)
    Q2 = g2.from_affine(X_q20, X_q21, Y_q20, Y_q21)
    Q2 = g2.neg(*Q2)
    
    line_eval, add_step = point_addition_and_line_evaluation(*Q1,*T,xp,yp)
    f = fp12.mul(*f,*line_eval)
    T = add_step

    line_eval, add_step = point_addition_and_line_evaluation(*Q2,*T,xp,yp)
    f = fp12.mul(*f,*line_eval)

    return f

def pair(xp, yp, Xq0, Xq1, Yq0, Yq1):
    f = miller_loop(Xq0, Xq1, Yq0, Yq1, monty.ONE, 0, xp, yp)
    # This should be final exponentiation
    f = fp12.exponentiation(*f, 552484233613224096312617126783173147097382103762957654188882734314196910839907541213974502761540629817009608548654680343627701153829446747810907373256841551006201639677726139946029199968412598804882391702273019083653272047566316584365559776493027495458238373902875937659943504873220554161550525926302303331747463515644711876653177129578303191095900909191624817826566688241804408081892785725967931714097716709526092261278071952560171111444072049229123565057483750161460024353346284167282452756217662335528813519139808291170539072125381230815729071544861602750936964829313608137325426383735122175229541155376346436093930287402089517426973178917569713384748081827255472576937471496195752727188261435633271238710131736096299798168852925540549342330775279877006784354801422249722573783561685179618816480037695005515426162362431072245638324744480)
    return f

def main():

    # From Ethereum tests
    # 1c76476f4def4bb94541d57ebba1193381ffa7aa76ada664dd31c16024c43f59 -> Xp1
    # 3034dd2920f673e204fee2811c678745fc819b55d3e9d294e45c9b03a76aef41 -> Yp1

    # 209dd15ebff5d46c4bd888e51a93cf99a7329636c63514396b4a452003a35bf7 -> Xq11
    # 04bf11ca01483bfa8b34b43561848d28905960114c8ac04049af4b6315a41678 -> Xq10
    # 2bb8324af6cfc93537a2ad1a445cfd0ca2a71acd7ac41fadbf933c2a51be344d -> Yq11
    # 120a2a4cf30c1bf9845f20c6fe39e07ea2cce61f0c9bb048165fe5e4de877550 -> Yq10

    # 111e129f1cf1097710d41c4ac70fcdfa5ba2023c6ff1cbeac322de49d1b6df7c -> Xp2
    # 2032c61a830e3c17286de9462bf242fca2883585b93870a73853face6a6bf411 -> Yp2

    # 198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2 -> Xq21
    # 1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed -> Xq20
    # 090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b -> Yq21
    # 12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa -> Yq20

    xp = monty.into(12873740738727497448187997291915224677121726020054032516825496230827252793177)
    yp = monty.into(21804419174137094775122804775419507726154084057848719988004616848382402162497)
    Xq0 = monty.into(2146841959437886920191033516947821737903543682424168472444605468016078231160)
    Xq1 = monty.into(14752851163271972921165116810778899752274893127848647655434033030151679466487)
    Yq0 = monty.into(8159591693044959083845993640644415462154314071906244874217244895511876957520)
    Yq1 = monty.into(19774899457345372253936887903062884289284519982717033379297427576421785416781)
    Zq0 = monty.ONE
    Zq1 = 0

    assert(utils.is_in_curve(xp, yp))
    assert(utils.is_in_twisted_curve(Xq0, Xq1, Yq0, Yq1))

    xp = monty.into(7742452358972543465462254569134860944739929848367563713587808717088650354556)
    yp = monty.into(14563720768440487558151020426243236708567496944263114635856508834497000371217)
    Xt0 = monty.into(10857046999023057135944570762232829481370756359578518086990519993285655852781)
    Xt1 = monty.into(11559732032986387107991004021392285783925812861821192530917403151452391805634)
    Yt0 = monty.into(8495653923123431417604973247489272438418190587263600148770280649306958101930)
    Yt1 = monty.into(4082367875863433681332203403145435568316851327593401208105741076214120093531)
    Zt0 = monty.ONE
    Zt1 = 0

    assert(utils.is_in_curve(xp, yp))
    assert(utils.is_in_twisted_curve(Xt0, Xt1, Yt0, Yt1))

    # Point doubling and line evaluation
    line_evaluation, double = point_doubling_and_line_evaluation(Xq0, Xq1, Yq0, Yq1, Zq0, Zq1, xp, yp)

    # Xr = 9 Xt ** 4 - 8 Xt Yt **2
    Xr_a = fp2.exp(Xq0,Xq1,4)
    Xr_a = fp2.scalar_mul(*Xr_a,monty.NINE)
    Xr_b = fp2.exp(Yq0,Yq1,2)
    Xr_b = fp2.mul(Xq0,Xq1, *Xr_b)
    Xr_b = fp2.scalar_mul(*Xr_b,monty.EIGHT)
    Xr = fp2.sub(*Xr_a,*Xr_b)
    assert((double[0], double[1]) == Xr)

    # Yr = 3 * (Xt ** 2) * (4 * (Xt ** 2) * (Yt ** 2) - Xr) - 8 * (Yt ** 4)
    Xq_squared = fp2.mul(Xq0,Xq1,Xq0,Xq1)
    Yq_squared = fp2.mul(Yq0,Yq1,Yq0,Yq1)
    Yr_a = fp2.scalar_mul(*Xq_squared, monty.THREE)
    Yr_b = fp2.scalar_mul(Xq0,Xq1, monty.FOUR)
    Yr_b = fp2.mul(*Yr_b, *Yq_squared)
    Yr_b = fp2.sub(*Yr_b,*Xr)
    Yr_c = fp2.mul(*Yq_squared,*Yq_squared)
    Yr_c = fp2.scalar_mul(*Yr_c, monty.EIGHT)
    Yr = fp2.mul(*Yr_a, *Yr_b)
    Yr = fp2.sub(*Yr, *Yr_c)
    assert((double[2], double[3]) == Yr)

    # Zr = 2 * Yt * Zt
    Zr = fp2.mul(Yq0,Yq1,Zq0,Zq1)
    Zr = fp2.scalar_mul(*Zr,monty.TWO)
    assert((double[4], double[5]) == Zr)

    # l_tt_x = 2 * Zr * Zt^2 * yp
    l_tt_x = fp2.mul(Zq0, Zq1, Zq0, Zq1)
    l_tt_x = fp2.mul(*l_tt_x, *Zr)
    l_tt_x = fp2.scalar_mul(*l_tt_x, yp)
    l_tt_x = fp2.scalar_mul(*l_tt_x, monty.TWO)
    assert((line_evaluation[0], line_evaluation[1]) == l_tt_x)

    # l_tt_y = 6 * Xt^2 * Zt^2 * xp
    l_tt_y = fp2.mul(Xq0, Xq1, Xq0, Xq1)
    t0 = fp2.mul(Zq0, Zq1, Zq0, Zq1)
    l_tt_y = fp2.mul(*l_tt_y, *t0)
    l_tt_y = fp2.scalar_mul(*l_tt_y, xp)
    l_tt_y = fp2.scalar_mul(*l_tt_y, monty.SIX)
    l_tt_y = fp2.neg(*l_tt_y)
    # We ignore the 0 between the fp2 in line evaluation like the paper does
    assert((line_evaluation[6], line_evaluation[7]) == l_tt_y)

    # l_tt_z = 6 * Xt^3 - 4 * Yt^2
    l_tt_z = fp2.mul(Xq0, Xq1, Xq0, Xq1)
    l_tt_z = fp2.mul(*l_tt_z, Xq0, Xq1)
    l_tt_z = fp2.scalar_mul(*l_tt_z, monty.SIX)
    t0 = fp2.mul(Yq0, Yq1, Yq0, Yq1)
    t0 = fp2.scalar_mul(*t0, monty.FOUR)
    l_tt_z = fp2.sub(*l_tt_z, *t0)
    # We ignore the 0 between the fp2 in line evaluation like the paper does
    assert((line_evaluation[8], line_evaluation[9]) == l_tt_z)

    # Point addition and line evaluation
    Xq = Xq0, Xq1
    Yq = Yq0, Yq1
    Zq = Zq0, Zq1
    Xt = Xt0, Xt1
    Yt = Yt0, Yt1
    Zt = Zt0, Zt1

    line_evaluation, addition = point_addition_and_line_evaluation(*Xq, *Yq, *Zq, *Xt, *Yt, *Zt, xp, yp)

    # Xr
    Zt_squared = fp2.mul(*Zt,*Zt)
    Xr_a = fp2.mul(*Zt_squared,*Zt)
    Xr_a = fp2.mul(*Xr_a,*Yq)
    Xr_a = fp2.scalar_mul(*Xr_a, monty.TWO)
    Xr_a2 = fp2.scalar_mul(*Yt, monty.TWO)
    Xr_a = fp2.sub(*Xr_a,*Xr_a2)
    Xr_af = fp2.mul(*Xr_a,*Xr_a)
    Xr_b = fp2.mul(*Xq,*Zt_squared)
    Xr_b = fp2.sub(*Xr_b,*Xt)
    Xr_bf = fp2.exp(*Xr_b, 3)
    Xr_bf = fp2.scalar_mul(*Xr_bf, monty.FOUR)
    Xr_c = fp2.mul(*Xr_b,*Xr_b)
    Xr_c = fp2.mul(*Xr_c,*Xt)
    Xr_c = fp2.scalar_mul(*Xr_c, monty.FOUR)
    Xr_cf = fp2.scalar_mul(*Xr_c, monty.TWO)
    Xr = fp2.sub(*Xr_af,*Xr_bf)
    Xr = fp2.sub(*Xr,*Xr_cf)
    assert((addition[0],addition[1]) == Xr)

    # Yr
    Yr_a = fp2.sub(*Xr_c,*Xr)
    Yr_a = fp2.mul(*Xr_a,*Yr_a)
    Yr_b = fp2.scalar_mul(*Xr_bf, monty.TWO)
    Yr_b = fp2.mul(*Yr_b,*Yt)
    Yr = fp2.sub(*Yr_a, *Yr_b)
    assert((addition[2],addition[3]) == Yr)

    # Zr
    Zr = fp2.mul(*Xq,*Zt_squared)
    Zr = fp2.sub(*Zr,*Xt)
    Zr = fp2.mul(*Zr,*Zt)
    Zr = fp2.scalar_mul(*Zr, monty.TWO)
    assert((addition[4],addition[5]) == Zr)

    # l_tq_x = 2 * Zr * yp
    l_tq_x = fp2.add(*Zr,*Zr)
    l_tq_x = fp2.scalar_mul(*l_tq_x, yp)
    assert((line_evaluation[0],line_evaluation[1]) == l_tq_x)

    # l_tq_y = - (4 * xp * (Yq * Zt^3 - Yt))
    # Change respect to the paper, the algorithm use sub and not add
    Zt_cubed = fp2.mul(*Zt_squared, *Zt)
    l_tq_y = fp2.mul(*Yq, *Zt_cubed)
    # l_tq_y = fp2.add(*l_tq_y, *Yt)
    l_tq_y = fp2.sub(*l_tq_y, *Yt)
    l_tq_y = fp2.scalar_mul(*l_tq_y, monty.FOUR)
    l_tq_y = fp2.scalar_mul(*l_tq_y, xp)
    l_tq_y = fp2.neg(*l_tq_y)
    assert((line_evaluation[6],line_evaluation[7]) == l_tq_y)

    # l_tq_z = 4 * Xq * (Yq * Zt^3 − Yt ) − 2 * Yq * Zr
    # Change respect to the paper, the algorithm does not multiply by Xq
    l_tq_z = fp2.mul(*Yq, *Zt_cubed)
    #l_tq_z = fp2.mul(*l_tq_z, *Xq)
    l_tq_z = fp2.sub(*l_tq_z, *Yt)
    l_tq_z = fp2.scalar_mul(*l_tq_z, monty.FOUR)
    l_tq_z = fp2.mul(*l_tq_z, *Xq)
    t0 = fp2.scalar_mul(*Yq, monty.TWO)
    t0 = fp2.mul(*t0,*Zr)
    l_tq_z = fp2.sub(*l_tq_z, *t0)
    assert((line_evaluation[8],line_evaluation[9]) == l_tq_z)

    # Pairing Test
    # Should be 1
    a = pair(xp, yp, Xq0, Xq1, Yq0, Yq1)
    b = pair(xp, yp, Xt0, Xt1, Yt0, Yt1)
    result = fp12.mul(*a, *b)
    assert(result == fp12.ONE)

if __name__ == '__main__':
    main()
