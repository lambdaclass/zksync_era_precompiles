import fp2
import montgomery as monty

def neg(x0,x1, y0, y1, z0, z1):
    y0,y1= fp2.neg(y0,y1)
    return (x0,x1,y0,y1,z0,z1)

def from_affine(x0,x1,y0,y1):
    z0 = monty.ONE
    z1 = 0
    return (x0,x1,y0,y1,z0,z1)
