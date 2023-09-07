import fp2
import montgomery as monty

def frobenius(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121):
    t1 = fp2.conjugate(a_000, a_001)
    t2 = fp2.conjugate(a_100, a_101)
    t3 = fp2.conjugate(a_010, a_011)
    t4 = fp2.conjugate(a_110, a_111)
    t5 = fp2.conjugate(a_020, a_021)
    t6 = fp2.conjugate(a_120, a_121)

    t2 = mul_by_gamma_1_1(*t2)
    t3 = mul_by_gamma_1_2(*t3)
    t4 = mul_by_gamma_1_3(*t4)
    t5 = mul_by_gamma_1_4(*t5)
    t6 = mul_by_gamma_1_5(*t6)

    c0 = t1[0], t1[1], t3[0], t3[1], t5[0], t5[1]
    c1 = t2[0], t2[1], t4[0], t4[1], t6[0], t6[1]

    return c0 + c1

def frobenius_square(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121):
    t1 = a_000, a_001
    t2 = mul_by_gamma_2_1(a_100, a_101)
    t3 = mul_by_gamma_2_2(a_010, a_011)
    t4 = mul_by_gamma_2_3(a_110, a_111)
    t5 = mul_by_gamma_2_4(a_020, a_021)
    t6 = mul_by_gamma_2_5(a_120, a_121)

    c0 = t1[0], t1[1], t3[0], t3[1], t5[0], t5[1]
    c1 = t2[0], t2[1], t4[0], t4[1], t6[0], t6[1]

    return c0 + c1 

def frobenius_cube(a_000, a_001, a_010, a_011, a_020, a_021, a_100, a_101, a_110, a_111, a_120, a_121):
    t1 = fp2.conjugate(a_000, a_001)
    t2 = fp2.conjugate(a_100, a_101)
    t3 = fp2.conjugate(a_010, a_011)
    t4 = fp2.conjugate(a_110, a_111)
    t5 = fp2.conjugate(a_020, a_021)
    t6 = fp2.conjugate(a_120, a_121)

    t2 = mul_by_gamma_3_1(*t2)
    t3 = mul_by_gamma_3_2(*t3)
    t4 = mul_by_gamma_3_3(*t4)
    t5 = mul_by_gamma_3_4(*t5)
    t6 = mul_by_gamma_3_5(*t6)

    c0 = t1[0], t1[1], t3[0], t3[1], t5[0], t5[1]
    c1 = t2[0], t2[1], t4[0], t4[1], t6[0], t6[1]

    return c0 + c1

# Implement the precomputed constant multiplications for utilizing the Frobenius Operator.
# Note: gn values are in Montgomery form.

# GAMMA_1_i

def mul_by_gamma_1_1(a0, a1):
    g0 = 1334504125441109323775816677333762124980877086439557453392802825656291576071
    g1 = 7532670101108748540749979597679923402841328813027773483599019704565791010162
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_1_2(a0, a1):
    g0 = 11461073415658098971834280704587444395456423268720245247603935854280982113072
    g1 = 17373957475705492831721812124331982823197004514106338927670775596783233550167
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_1_3(a0, a1):
    g0 = 16829996427371746075450799880956928810557034522864196246648550205375670302249
    g1 = 20140510615310063345578764457068708762835443761990824243702724480509675468743
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_1_4(a0, a1):
    g0 = 9893659366031634526915473325149983243417508801286144596494093251884139331218
    g1 = 16514792769865828027011044701859348114858257981779976519405133026725453154633
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_1_5(a0, a1):
    g0 = 8443299194457421137480282511969901974227997168695360756777672575877693116391
    g1 = 21318636632361225103955470331868462398471880609949088574192481281746934874025
    return fp2.mul(a0, a1, g0, g1)

# GAMMA_2_i

def mul_by_gamma_2_1(a0, a1):
    g0 = 1881798392815877688876180778159931906057091683336018750908411925848733129714
    return fp2.scalar_mul(a0, a1, g0)

def mul_by_gamma_2_2(a0, a1):
    g0 = 17419166386535333598783630241015674584964973961482396687585055285806960741276
    return fp2.scalar_mul(a0, a1, g0)

def mul_by_gamma_2_3(a0, a1):
    g0 = 15537367993719455909907449462855742678907882278146377936676643359958227611562
    return fp2.scalar_mul(a0, a1, g0)

def mul_by_gamma_2_4(a0, a1):
    g0 = 20006444479023397533370224967097343182639219473961804911780625968796493078869
    return fp2.scalar_mul(a0, a1, g0)

def mul_by_gamma_2_5(a0, a1):
    g0 = 4469076485303941623462775504241600503731337195815426975103982608838265467307
    return fp2.scalar_mul(a0, a1, g0)

# GAMMA_3_i

def mul_by_gamma_3_1(a0, a1):
    g0 = 3649295186494431467217240962842301358951278585756714214031945394966344685949
    g1 = 17372117152826387298350653207345606612066102743297871578090761045572893546809
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_3_2(a0, a1):
    g0 = 14543349330631744552586812320441124107441202078168618766450326117520897829805
    g1 = 4646831431411403714092965637071058625728899792817054432901795759277546050476
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_3_3(a0, a1):
    g0 = 5058246444467529146795605864300346278139276634433627416040487689269555906334
    g1 = 1747732256529211876667641288188566325860867395306999418986313414135550739840
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_3_4(a0, a1):
    g0 = 3025265262868802913511075437173590487338001780554453930995247874855578067679
    g1 = 10425289180741305073643362413949631488281652900778689227251281048515799234257
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_3_5(a0, a1):
    g0 = 9862576063628467829192720579684130652367741026604221989510773554027227469215
    g1 = 16681752610922605480353377694363181135019829138759259603037557916788351015335
    return fp2.mul(a0, a1, g0, g1)

def main():
    fp12_a = (monty.ONE, monty.TWO, monty.ONE, monty.TWO, monty.ONE, monty.TWO, monty.ONE, monty.TWO, monty.ONE, monty.TWO, monty.ONE, monty.TWO)
    result = frobenius(*fp12_a)
    result = frobenius(*result)
    result = frobenius(*result)
    result = frobenius(*result)
    result = frobenius(*result)
    result = frobenius(*result)
    result = frobenius(*result)
    result = frobenius(*result)
    result = frobenius(*result)
    result = frobenius(*result)
    result = frobenius(*result)
    result = frobenius(*result)

    assert(result[0] == fp12_a[0])
    assert(result[1] == fp12_a[1])
    assert(result[2] == fp12_a[2])
    assert(result[3] == fp12_a[3])
    assert(result[4] == fp12_a[4])
    assert(result[5] == fp12_a[5])
    assert(result[6] == fp12_a[6])
    assert(result[7] == fp12_a[7])
    assert(result[8] == fp12_a[8])
    assert(result[9] == fp12_a[9])
    assert(result[10] == fp12_a[10])
    assert(result[11] == fp12_a[11])

    result = frobenius_square(*fp12_a)
    result = frobenius_square(*result)
    result = frobenius_square(*result)
    result = frobenius_square(*result)
    result = frobenius_square(*result)
    result = frobenius_square(*result)

    assert(result[0] == fp12_a[0])
    assert(result[1] == fp12_a[1])
    assert(result[2] == fp12_a[2])
    assert(result[3] == fp12_a[3])
    assert(result[4] == fp12_a[4])
    assert(result[5] == fp12_a[5])
    assert(result[6] == fp12_a[6])
    assert(result[7] == fp12_a[7])
    assert(result[8] == fp12_a[8])
    assert(result[9] == fp12_a[9])
    assert(result[10] == fp12_a[10])
    assert(result[11] == fp12_a[11])
    
    result = frobenius_cube(*fp12_a)
    result = frobenius_cube(*result)
    result = frobenius_cube(*result)
    result = frobenius_cube(*result)

    assert(result[0] == fp12_a[0])
    assert(result[1] == fp12_a[1])
    assert(result[2] == fp12_a[2])
    assert(result[3] == fp12_a[3])
    assert(result[4] == fp12_a[4])
    assert(result[5] == fp12_a[5])
    assert(result[6] == fp12_a[6])
    assert(result[7] == fp12_a[7])
    assert(result[8] == fp12_a[8])
    assert(result[9] == fp12_a[9])
    assert(result[10] == fp12_a[10])
    assert(result[11] == fp12_a[11])
    
if __name__ == '__main__':
    main()
