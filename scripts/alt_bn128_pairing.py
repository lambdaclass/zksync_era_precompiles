import pairing_utils
import montgomery as monty
import fp2 as fp2
import fp12
import frobenius as frb
import g2
import pairing_utils as utils

def double_step(Xq0, Xq1, Yq0, Yq1, Zq0, Zq1):
    two_inv = monty.inv(monty.TWO)
    t0 = fp2.mul(Xq0,Xq1,Yq0,Yq1)
    A = fp2.scalar_mul(*t0, two_inv)
    B = fp2.mul(Yq0, Yq1, Yq0, Yq1)
    C = fp2.mul(Zq0, Zq1, Zq0, Zq1)
    D = fp2.add(*C, *C)
    D = fp2.add(*D, *C)
    E = fp2.mul(*D, *utils.TWISTED_CURVE_COEFFS)
    F = fp2.add(*E, *E)
    F = fp2.add(*F, *E)
    G = fp2.add(*B, *F)
    G = fp2.scalar_mul(*G, two_inv)
    H = fp2.add(Yq0, Yq1, Zq0, Zq1)
    H = fp2.mul(*H, *H)
    t1 = fp2.add(*B, *C)
    H = fp2.sub(*H, *t1)
    I = fp2.sub(*E, *B)
    J = fp2.mul(Xq0, Xq1, Xq0, Xq1)
    EE = fp2.mul(*E, *E)
    K = fp2.add(*EE,*EE)
    K = fp2.add(*K,*EE)

    Tx = fp2.sub(*B, *F)
    Tx = fp2.mul(*Tx, *A)

    Ty = fp2.mul(*G, *G)
    Ty = fp2.sub(*Ty, *K)

    Tz = fp2.mul(*B, *H)

    l0 = fp2.neg(*H)
    l1 = fp2.add(*J, *J)
    l1 = fp2.add(*l1, *J)
    l2 = I

    l = (*l0,0,0,0,0,*l1,*l2,0,0)
    T = Tx + Ty + Tz
    return l,T

def mixed_addition_step(Xq0, Xq1, Yq0, Yq1, Xt0, Xt1, Yt0, Yt1, Zt0, Zt1):
    temp = fp2.mul(Yq0,Yq1,Zt0,Zt1) 
    O = fp2.sub(Yt0,Yt1,*temp)
    temp = fp2.mul(Xq0,Xq1,Zt0,Zt1)
    L = fp2.sub(Xt0,Xt1,*temp)
    C = fp2.mul(*O,*O)
    D = fp2.mul(*L,*L)
    E = fp2.mul(*L,*D)
    F = fp2.mul(Zt0,Zt1,*C)
    G = fp2.mul(Xt0,Xt1,*D)
    temp = fp2.add(*G,*G)
    H = fp2.add(*E,*F)
    H = fp2.sub(*H,*temp) 
    temp = fp2.mul(Yt0, Yt1, *E) 

    Tx0, Tx1 = fp2.mul(*L,*H)
    Ty0, Ty1 = fp2.sub(*G,*H)
    Ty0, Ty1 = fp2.mul(Ty0,Ty1,*O)
    Ty0, Ty1 = fp2.sub(Ty0,Ty1,*temp)
    Tz0, Tz1 = fp2.mul(*E, Zt0, Zt1)

    temp = fp2.mul(*L,Yq0,Yq1)
    J = fp2.mul(Xq0,Xq1,*O) 
    J = fp2.sub(*J, *temp)
    
    l0 = L
    l1 = fp2.neg(*O)
    l2 = J

    l = (*l0,0,0,0,0,*l1,*l2,0,0)
    T = Tx0, Tx1, Ty0, Ty1, Tz0, Tz1

    return l, T

# Algorithm 6 from https://eprint.iacr.org/2015/192.pdf
def final_exponentiation(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121):
    f = (a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121)
    
    # First part
    t0 = fp12.conjugate(*f)
    f= fp12.inv(*f)
    t0 = fp12.mul(*t0, *f)
    f_aux = frb.frobenius_square(*t0)
    f = fp12.mul(*f_aux, *t0)

    # Second part
    t0 = fp12.expt(*f)
    t0 = fp12.conjugate(*t0)
    t0 = fp12.cyclotomic_square(*t0)
    t1 = fp12.cyclotomic_square(*t0)
    t1 = fp12.mul(*t0,*t1)
    t2 = fp12.expt(*t1)
    t2 = fp12.conjugate(*t2)
    t3 = fp12.conjugate(*t1)
    t1 = fp12.mul(*t2,*t3)
    t3 = fp12.cyclotomic_square(*t2)
    t4 = fp12.expt(*t3)
    t4 = fp12.mul(*t4,*t1) 
    t3 = fp12.mul(*t4,*t0) 
    t0 = fp12.mul(*t2,*t4) 
    t0 = fp12.mul(*t0,*f)
    t2 = frb.frobenius(*t3)
    t0 = fp12.mul(*t2,*t0) 
    t2 = frb.frobenius_square(*t4)
    t0 = fp12.mul(*t2,*t0)
    t2 = fp12.conjugate(*f)
    t2 = fp12.mul(*t2,*t3)
    t2 = frb.frobenius_cube(*t2)
    t0 = fp12.mul(*t2,*t0)

    return t0

def miller_loop(Xq0, Xq1, Yq0, Yq1, xp, yp):

    Q = Xq0, Xq1, Yq0, Yq1
    T = g2.from_affine(Xq0, Xq1, Yq0, Yq1)
    f = fp12.ONE

    for i in range(len(utils.S_NAF) - 2, -1, -1):
        f = fp12.square(*f)

        line_eval, point_double = double_step(*T)
        aux = list(line_eval)
        aux[0], aux[1] = fp2.scalar_mul(aux[0], aux[1], yp)
        aux[6], aux[7] = fp2.scalar_mul(aux[6], aux[7], xp)
        line_eval = tuple(aux)
        f = fp12.mul(*f,*line_eval)
        T = point_double

        if pairing_utils.S_NAF[i] == -1:
            minus_Q = g2.neg(*Q)
            line_eval, point_adding = mixed_addition_step(*minus_Q, *T)
            aux = list(line_eval)
            aux[0], aux[1] = fp2.scalar_mul(aux[0], aux[1], yp)
            aux[6], aux[7] = fp2.scalar_mul(aux[6], aux[7], xp)
            line_eval = tuple(aux)
            f = fp12.mul(*f, *line_eval)
            T = point_adding

        elif pairing_utils.S_NAF[i] == 1:
            line_eval, point_adding = mixed_addition_step(*Q,*T)
            aux = list(line_eval)
            aux[0], aux[1] = fp2.scalar_mul(aux[0], aux[1], yp)
            aux[6], aux[7] = fp2.scalar_mul(aux[6], aux[7], xp)
            line_eval = tuple(aux)
            f = fp12.mul(*f,*line_eval)
            T = point_adding

    # Q1 <- pi_p(Q)
    X_q0, X_q1 = fp2.conjugate(Xq0, Xq1)
    Y_q0, Y_q1 = fp2.conjugate(Yq0, Yq1)
    X_q0, X_q1 = frb.mul_by_gamma_1_2(X_q0, X_q1)
    Y_q0, Y_q1 = frb.mul_by_gamma_1_3(Y_q0, Y_q1)
    Q1 = X_q0, X_q1, Y_q0, Y_q1

    # Q2 <- pi_p_square(Q)
    X_q20, X_q21 = frb.mul_by_gamma_2_2(Xq0, Xq1)
    Y_q20, Y_q21 = frb.mul_by_gamma_2_3(Yq0, Yq1)
    Y_q20, Y_q21 = fp2.neg(Y_q20, Y_q21)
    Q2 = X_q20, X_q21, Y_q20, Y_q21
    
    line_eval, point_adding = mixed_addition_step(*Q1,*T)
    aux = list(line_eval)
    aux[0], aux[1] = fp2.scalar_mul(aux[0], aux[1], yp)
    aux[6], aux[7] = fp2.scalar_mul(aux[6], aux[7], xp)
    line_eval = tuple(aux)
    f = fp12.mul(*f,*line_eval)
    T = point_adding

    line_eval, point_adding = mixed_addition_step(*Q2,*T)
    aux = list(line_eval)
    aux[0], aux[1] = fp2.scalar_mul(aux[0], aux[1], yp)
    aux[6], aux[7] = fp2.scalar_mul(aux[6], aux[7], xp)
    line_eval = tuple(aux)
    f = fp12.mul(*f,*line_eval)
    T = point_adding

    return f

def pair(xp, yp, Xq0, Xq1, Yq0, Yq1):
    f = miller_loop(Xq0, Xq1, Yq0, Yq1, xp, yp)
    f = final_exponentiation(*f)
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

    xp0 = monty.into(12873740738727497448187997291915224677121726020054032516825496230827252793177)
    yp0 = monty.into(21804419174137094775122804775419507726154084057848719988004616848382402162497)
    Xq0 = monty.into(2146841959437886920191033516947821737903543682424168472444605468016078231160)
    Xq1 = monty.into(14752851163271972921165116810778899752274893127848647655434033030151679466487)
    Yq0 = monty.into(8159591693044959083845993640644415462154314071906244874217244895511876957520)
    Yq1 = monty.into(19774899457345372253936887903062884289284519982717033379297427576421785416781)

    assert(utils.is_in_curve(xp0, yp0))
    assert(utils.is_in_twisted_curve(Xq0, Xq1, Yq0, Yq1))

    xp1 = monty.into(7742452358972543465462254569134860944739929848367563713587808717088650354556)
    yp1 = monty.into(14563720768440487558151020426243236708567496944263114635856508834497000371217)
    Xt0 = monty.into(10857046999023057135944570762232829481370756359578518086990519993285655852781)
    Xt1 = monty.into(11559732032986387107991004021392285783925812861821192530917403151452391805634)
    Yt0 = monty.into(8495653923123431417604973247489272438418190587263600148770280649306958101930)
    Yt1 = monty.into(4082367875863433681332203403145435568316851327593401208105741076214120093531)

    assert(utils.is_in_curve(xp1, yp1))
    assert(utils.is_in_twisted_curve(Xt0, Xt1, Yt0, Yt1))


    # Pairing Test
    a = pair(xp0, yp0, Xq0, Xq1, Yq0, Yq1)
    b = pair(xp1, yp1, Xt0, Xt1, Yt0, Yt1)
    result = fp12.mul(*a, *b)
    assert(result == fp12.ONE)
    pass

if __name__ == '__main__':
    main()
