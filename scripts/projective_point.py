import montgomery

INFINITY = (0, montgomery.ONE, 0)

def from_affine(x, y):
    if x == 0 and y == 0:
        return INFINITY
    return x, y, montgomery.ONE

def into_affine(x, y, z):
    if z == 0:
        return 0, 0
    return montgomery.div(x, z), montgomery.div(y, z)

def double(x, y, z):
    x_squared = montgomery.mul(x, x)
    t = montgomery.add(x_squared, montgomery.add(x_squared, x_squared))
    yz = montgomery.mul(y, z)
    u = montgomery.add(yz, yz)
    uxy = montgomery.mul(u, montgomery.mul(x, y))
    v = montgomery.add(uxy, uxy)
    w = montgomery.sub(montgomery.mul(t, t), montgomery.add(v, v))

    doubled_x = montgomery.mul(u, w)
    uy = montgomery.mul(u, y)
    uy_squared = montgomery.mul(uy, uy)
    doubled_y = montgomery.sub(montgomery.mul(t, montgomery.sub(v, w)), montgomery.add(uy_squared, uy_squared))
    doubled_z = montgomery.mul(u, montgomery.mul(u, u))

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

    t0 = montgomery.mul(yp, zq)
    t1 = montgomery.mul(yq, zp)
    t = montgomery.sub(t0, t1)
    u0 = montgomery.mul(xp, zq)
    u1 = montgomery.mul(xq, zp)
    u = montgomery.sub(u0, u1)
    u2 = montgomery.mul(u, u)
    u3 = montgomery.mul(u2, u)
    v = montgomery.mul(zp, zq)
    w = montgomery.sub(montgomery.mul(montgomery.mul(t, t), v), montgomery.mul(u2, montgomery.add(u0, u1)))

    xr = montgomery.mul(u, w)
    yr = montgomery.sub(montgomery.mul(t, montgomery.sub(montgomery.mul(u0, u2), w)), montgomery.mul(t0, u3))
    zr = montgomery.mul(u3, v)

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
    affine_p = (montgomery.ONE, montgomery.TWO)
    projective_p = from_affine(*affine_p)
    assert(projective_p == (montgomery.ONE, montgomery.TWO, montgomery.ONE))
    assert(affine_p == into_affine(*projective_p))

    # P + P = 2P
    projective_doubled_p = double(*projective_p)
    affine_doubled_p = into_affine(*projective_doubled_p)
    assert((montgomery.out_of(affine_doubled_p[0]), montgomery.out_of(affine_doubled_p[1])) == (1368015179489954701390400359078579693043519447331113978918064868415326638035, 9918110051302171585080402603319702774565515993150576347155970296011118125764))

    # P + O = P = P * 1
    projective_addition = add(*projective_p, *INFINITY)
    affine_addition = into_affine(*projective_addition)
    assert(affine_addition == (montgomery.ONE, montgomery.TWO))
    assert(mul(*projective_p, 1) == projective_p)
    assert(mul(*projective_p, 1) == projective_addition)

    # O + P = P = P * 1
    projective_addition = add(*INFINITY, *projective_p)
    affine_addition = into_affine(*projective_addition)
    assert(affine_addition == (montgomery.ONE, montgomery.TWO))
    assert(mul(*projective_p, 1) == projective_p)
    assert(mul(*projective_p, 1) == projective_addition)

    # P + Q = R
    # P + 2P = 3P
    # 3353031288059533942658390886683067124040920775575537747144343083137631628272, 19321533766552368860946552437480515441416830039777911637913418824951667761761
    projective_addition = add(*projective_p, *projective_doubled_p)
    affine_addition = into_affine(*projective_addition)
    assert((montgomery.out_of(affine_addition[0]), montgomery.out_of(affine_addition[1])) == (3353031288059533942658390886683067124040920775575537747144343083137631628272, 19321533766552368860946552437480515441416830039777911637913418824951667761761))
    assert(mul(*projective_p, 3) == projective_addition)

if __name__ == '__main__':
    main()