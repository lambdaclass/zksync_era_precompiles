import fp2
import montgomery as monty

# Algorithm 26. https://eprint.iacr.org/2010/354.pdf
# P belongs to curve E over Fp in affine coordinates: P = (xp, yp)
# Q belongs to curve E' over Fp2 in Jacobian coordinates: Q = (Xq, Yq, Zq)
def point_doubling_and_line_evaluation(xp, yp, Xq0, Xq1, Yq0, Yq1, Zq0, Zq1):
    temp0 = fp2.mul(Xq0,Xq1,Xq0,Xq1)
    temp1 = fp2.mul(Yq0,Yq1,Yq0,Yq1)
    temp2 = fp2.mul(*temp1,*temp1)
    temp3 = fp2.add(*temp1,Xq0,Xq1)
    temp3 = fp2.mul(*temp3,*temp3)
    temp3 = fp2.sub(*temp3,*temp0)
    temp3 = fp2.sub(*temp3,*temp2)
    temp3 = fp2.add(*temp3,*temp3)
    temp4 = fp2.scalar_mul(*temp0,monty.THREE)
    temp6 = fp2.add(Xq0,Xq1,*temp4)
    temp5 = fp2.mul(*temp4,*temp4)
    Xt = fp2.scalar_mul(*temp3,2)
    Xt = fp2.sub(*temp5,*Xt)
    Zq_squared = fp2.mul(Zq0,Zq1,Zq0,Zq1)
    Zt = fp2.add(Yq0,Yq1,Zq0,Zq1)
    Zt = fp2.mul(*Zt,*Zt)
    Zt = fp2.sub(*Zt,*temp1)
    Zt = fp2.sub(*Zt,Zq_squared)
    temp2_times_eight = fp2.scalar_mul(*temp2,monty.EIGHT)
    Yt = fp2.sub(*temp3,*Xt)
    Yt = fp2.mul(*Yt,*temp4)
    Yt = fp2.sub(*Yt,*temp2_times_eight)
    temp3 = fp2.mul(Zq0,Zq1,Zq0,Zq1)
    temp3 = fp2.mul(*temp3,*temp4)
    temp3 = fp2.add(*temp3,*temp3)
    temp3 = fp2.sub(0,0,*temp3) # multiply by -1
    temp3 = fp2.scalar_mul(*temp3,xp)
    temp1_times_4 = fp2.scalar_mul(*temp1,monty.FOUR)
    temp6 = fp2.mul(*temp6,*temp6)
    temp6 = fp2.sub(*temp6,*temp0)
    temp6 = fp2.sub(*temp6,*temp5)
    temp6 = fp2.sub(*temp6,*temp1_times_4)
    temp0 = fp2.mul(Zq0,Zq1,Zq0,Zq1)
    temp0 = fp2.mul(*temp0,*temp0)
    temp0 = fp2.add(*temp0,*temp0)
    temp0 = fp2.scalar_mul(*temp0,yp)
    T = (Xt, Yt, Zt)
    l = (temp3,0,0,temp3,temp6,0)
    return T,l





