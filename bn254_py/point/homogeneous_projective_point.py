import bn254_py.montgomery as monty

INFINITY = (0, monty.ONE, 0)

def from_affine(x, y):
    if x == 0 and y == 0:
        return INFINITY
    return x, y, monty.ONE

def into_affine(x, y, z):
    if z == 0:
        return 0, 0
    return monty.div(x, z), monty.div(y, z)

def is_infinity(_x, _y, z):
    return z == 0

def double(x, y, z):
    x_squared = monty.mul(x, x)
    t = monty.add(x_squared, monty.add(x_squared, x_squared))
    yz = monty.mul(y, z)
    u = monty.add(yz, yz)
    uxy = monty.mul(u, monty.mul(x, y))
    v = monty.add(uxy, uxy)
    w = monty.sub(monty.mul(t, t), monty.add(v, v))

    doubled_x = monty.mul(u, w)
    uy = monty.mul(u, y)
    uy_squared = monty.mul(uy, uy)
    doubled_y = monty.sub(monty.mul(t, monty.sub(v, w)), monty.add(uy_squared, uy_squared))
    doubled_z = monty.mul(u, monty.mul(u, u))

    return doubled_x, doubled_y, doubled_z

# P + Q = R
# xp, yp, zp, xq, yq, zq, xr, yr, zr are all in Montgomery form
def add(xp, yp, zp, xq, yq, zq):
    if zp == 0:
        return xq, yq, zq
    if zq == 0:
        return xp, yp, zp 
    if xp == xq and yp == yq:
        return double(xp, yp, zp)

    t0 = monty.mul(yp, zq)
    t1 = monty.mul(yq, zp)
    t = monty.sub(t0, t1)
    u0 = monty.mul(xp, zq)
    u1 = monty.mul(xq, zp)
    u = monty.sub(u0, u1)
    u2 = monty.mul(u, u)
    u3 = monty.mul(u2, u)
    v = monty.mul(zp, zq)
    w = monty.sub(monty.mul(monty.mul(t, t), v), monty.mul(u2, monty.add(u0, u1)))

    xr = monty.mul(u, w)
    yr = monty.sub(monty.mul(t, monty.sub(monty.mul(u0, u2), w)), monty.mul(t0, u3))
    zr = monty.mul(u3, v)

    return xr, yr, zr

def mul(x, y, z, scalar):
    x_res, y_res, z_res = INFINITY

    while scalar > 0:
        if scalar & 1 != 0:
            x_res, y_res, z_res = add(x_res, y_res, z_res, x, y, z)
        x, y, z = double(x, y, z)
        scalar >>= 1

    return x_res, y_res, z_res

def main():
    affine_p = (monty.ONE, monty.TWO)
    projective_p = from_affine(*affine_p)
    assert(projective_p == (monty.ONE, monty.TWO, monty.ONE))
    assert(affine_p == into_affine(*projective_p))

    # P + P = 2P
    projective_doubled_p = double(*projective_p)
    affine_doubled_p = into_affine(*projective_doubled_p)
    assert((monty.out_of(affine_doubled_p[0]), monty.out_of(affine_doubled_p[1])) == (1368015179489954701390400359078579693043519447331113978918064868415326638035, 9918110051302171585080402603319702774565515993150576347155970296011118125764))

    # P + O = P = P * 1
    projective_addition = add(*projective_p, *INFINITY)
    affine_addition = into_affine(*projective_addition)
    assert(affine_addition == (monty.ONE, monty.TWO))
    assert(mul(*projective_p, 1) == projective_p)
    assert(mul(*projective_p, 1) == projective_addition)

    # O + P = P = P * 1
    projective_addition = add(*INFINITY, *projective_p)
    affine_addition = into_affine(*projective_addition)
    assert(affine_addition == (monty.ONE, monty.TWO))
    assert(mul(*projective_p, 1) == projective_p)
    assert(mul(*projective_p, 1) == projective_addition)

    # P + Q = R
    # P + 2P = 3P
    # 3353031288059533942658390886683067124040920775575537747144343083137631628272, 19321533766552368860946552437480515441416830039777911637913418824951667761761
    projective_addition = add(*projective_p, *projective_doubled_p)
    affine_addition = into_affine(*projective_addition)
    assert((monty.out_of(affine_addition[0]), monty.out_of(affine_addition[1])) == (3353031288059533942658390886683067124040920775575537747144343083137631628272, 19321533766552368860946552437480515441416830039777911637913418824951667761761))
    assert(mul(*projective_p, 3) == projective_addition)

if __name__ == '__main__':
    main()
