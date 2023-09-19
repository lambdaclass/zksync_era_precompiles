import fp2
import montgomery as monty

# Neg function for G2 in affine coordinates
def neg(x0,x1, y0, y1):
    y0,y1= fp2.neg(y0,y1)
    return (x0,x1,y0,y1)

# G2 function to go back and forth between affine and projective coordinates
def from_affine(x0,x1,y0,y1):
    if x0 == 0 and x1 == 0 and y0 == 0 and y1 == 0:
        return (monty.ONE, 0, monty.ONE, 0, 0, 0)
    
    z0 = monty.ONE
    z1 = 0
    return (x0,x1,y0,y1,z0,z1)

def into_affine(x0,x1,y0,y1,z0,z1):
    
    z0, z1 = fp2.inv(z0,z1)
    x0, x1 = fp2.mul(x0,x1,z0,z1)
    y0, y1 = fp2.mul(y0,y1,z0,z1)

    return (x0,x1,y0,y1)
