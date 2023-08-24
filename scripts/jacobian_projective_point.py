import montgomery as monty

INFINITY = (0, 0, 0)

def from_affine(x, y):
    if x == 0 and y == 0:
        return INFINITY
    return x, y, monty.ONE

def into_affine(x, y, z):
    if is_infinity(x, y, z):
        return 0, 0
    t1 = monty.inv(z)
    t2 = monty.exp(t1, 2)

    x = monty.mul(x, t2)
    y = monty.mul(y, monty.mul(t1, t2))

    return x, y

def is_infinity(_x, _y, z):
    return z == 0

def neg(x, y, z):
    return x, monty.sub(0, y), z

def double(x, y, z):
    if is_infinity(x, y, z):
        return x, y, z
    if y == 0:
        return INFINITY
    xx = monty.mul(x, x)
    yy = monty.mul(y, y)
    zz = monty.mul(z, z)
    yyyy = monty.mul(yy, yy)

    zzzz = monty.mul(zz, zz)

    # All the following multiplications by scalars could be replaced by successive additions.
    s = monty.mul(monty.FOUR, monty.mul(x, yy))
    # y^2 = x^3 + ax + b with a == 0
    m = monty.mul(monty.THREE, xx)
    x0 = monty.sub(monty.exp(m, 2), monty.mul(monty.TWO, s))
    y0 = monty.sub(monty.mul(m, monty.sub(s, x0)), monty.mul(monty.EIGHT, yyyy))
    z0 = monty.mul(monty.mul(y, z), monty.TWO)

    return x0, y0, z0

def add(xp, yp, zp, xq, yq, zq):
    if is_infinity(xp, yp, zp):
        return xq, yq, zq
    elif is_infinity(xq, yq, zq):
        return xp, yp, zp
    else:
        zpzp = monty.mul(zp, zp)
        zqzq = monty.mul(zq, zq)

        t1 = monty.mul(xp, zqzq)
        t2 = monty.mul(xq, zpzp)

        s1 = monty.mul(yp, monty.mul(zq, zqzq))
        s2 = monty.mul(yq, monty.mul(zp, zpzp))

        if t1 == t2:
            if s1 != s2:
                return INFINITY
            else:
                return double(xp, yp, zp)
        else:
            h = monty.sub(t2, t1)
            r = monty.sub(s2, s1)

            hh = monty.mul(h, h)
            hhh = monty.mul(hh, h)
            x3 = monty.sub(monty.mul(r, r), hhh)
            x3 = monty.sub(x3, monty.mul(monty.mul(t1, hh), monty.TWO))
            y3 = monty.mul(r, monty.sub(monty.mul(t1, hh), x3))
            y3 = monty.sub(y3, monty.mul(s1, hhh))
            z3 = monty.mul(h, monty.mul(zp, zq))
            
            return x3, y3, z3

def sub(xp, yp, zp, xq, yq, zq):
    add(xp, yp, zp, neg(xq, yq, zq))

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
    jacobian_projective_p = from_affine(*affine_p)
    assert(jacobian_projective_p == (monty.ONE, monty.TWO, monty.ONE))
    assert(affine_p == into_affine(*jacobian_projective_p))

    # P + P = 2P
    projective_doubled_p = double(*jacobian_projective_p)
    affine_doubled_p = into_affine(*projective_doubled_p)
    assert((monty.out_of(affine_doubled_p[0]), monty.out_of(affine_doubled_p[1])) == (1368015179489954701390400359078579693043519447331113978918064868415326638035, 9918110051302171585080402603319702774565515993150576347155970296011118125764))

    # P + O = P = P * 1
    projective_addition = add(*jacobian_projective_p, *INFINITY)
    affine_addition = into_affine(*projective_addition)
    assert(affine_addition == (monty.ONE, monty.TWO))
    assert(mul(*jacobian_projective_p, 1) == jacobian_projective_p)
    assert(mul(*jacobian_projective_p, 1) == projective_addition)

    # O + P = P = P * 1
    projective_addition = add(*INFINITY, *jacobian_projective_p)
    affine_addition = into_affine(*projective_addition)
    assert(affine_addition == (monty.ONE, monty.TWO))
    assert(mul(*jacobian_projective_p, 1) == jacobian_projective_p)
    assert(mul(*jacobian_projective_p, 1) == projective_addition)

    # P + Q = R
    # P + 2P = 3P
    # 3353031288059533942658390886683067124040920775575537747144343083137631628272, 19321533766552368860946552437480515441416830039777911637913418824951667761761
    projective_addition = add(*jacobian_projective_p, *projective_doubled_p)
    affine_addition = into_affine(*projective_addition)
    assert((monty.out_of(affine_addition[0]), monty.out_of(affine_addition[1])) == (3353031288059533942658390886683067124040920775575537747144343083137631628272, 19321533766552368860946552437480515441416830039777911637913418824951667761761))
    assert(mul(*jacobian_projective_p, 3) == projective_addition)

if __name__ == '__main__':
    main()
