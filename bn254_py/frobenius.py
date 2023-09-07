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
# TODO: Verify the precomputed numbers. 

# GAMMA_1_i

def mul_by_gamma_1_1(a0, a1):
    g0 = monty.into(8376118865763821496583973867626364092589906065868298776909617916018768340080)
    g1 = monty.into(16469823323077808223889137241176536799009286646108169935659301613961712198316)
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_1_2(a0, a1):
    g0 = monty.into(21575463638280843010398324269430826099269044274347216827212613867836435027261)
    g1 = monty.into(10307601595873709700152284273816112264069230130616436755625194854815875713954)
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_1_3(a0, a1):
    g0 = monty.into(2821565182194536844548159561693502659359617185244120367078079554186484126554)
    g1 = monty.into(3505843767911556378687030309984248845540243509899259641013678093033130930403)
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_1_4(a0, a1):
    g0 = monty.into(2581911344467009335267311115468803099551665605076196740867805258568234346338)
    g1 = monty.into(19937756971775647987995932169929341994314640652964949448313374472400716661030)
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_1_5(a0, a1):
    g0 = monty.into(685108087231508774477564247770172212460312782337200605669322048753928464687)
    g1 = monty.into(8447204650696766136447902020341177575205426561248465145919723016860428151883)
    return fp2.mul(a0, a1, g0, g1)

# GAMMA_2_i

def mul_by_gamma_2_1(a0, a1):
    g0 = monty.into(21888242871839275220042445260109153167277707414472061641714758635765020556617)
    return fp2.scalar_mul(a0, a1, g0)

def mul_by_gamma_2_2(a0, a1):
    g0 = monty.into(21888242871839275220042445260109153167277707414472061641714758635765020556616)
    return fp2.scalar_mul(a0, a1, g0)

def mul_by_gamma_2_3(a0, a1):
    g0 = monty.into(21888242871839275222246405745257275088696311157297823662689037894645226208582)
    return fp2.scalar_mul(a0, a1, g0)

def mul_by_gamma_2_4(a0, a1):
    g0 = monty.into(2203960485148121921418603742825762020974279258880205651966)
    return fp2.scalar_mul(a0, a1, g0)

def mul_by_gamma_2_5(a0, a1):
    g0 = monty.into(2203960485148121921418603742825762020974279258880205651967)
    return fp2.scalar_mul(a0, a1, g0)

# GAMMA_3_i

def mul_by_gamma_3_1(a0, a1):
    g0 = monty.into(11697423496358154304825782922584725312912383441159505038794027105778954184319)
    g1 = monty.into(303847389135065887422783454877609941456349188919719272345083954437860409601)
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_3_2(a0, a1):
    g0 = monty.into(3772000881919853776433695186713858239009073593817195771773381919316419345261)
    g1 = monty.into(2236595495967245188281701248203181795121068902605861227855261137820944008926)
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_3_3(a0, a1):
    g0 = monty.into(19066677689644738377698246183563772429336693972053703295610958340458742082029)
    g1 = monty.into(18382399103927718843559375435273026243156067647398564021675359801612095278180)
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_3_4(a0, a1):
    g0 = monty.into(5324479202449903542726783395506214481928257762400643279780343368557297135718)
    g1 = monty.into(16208900380737693084919495127334387981393726419856888799917914180988844123039)
    return fp2.mul(a0, a1, g0, g1)

def mul_by_gamma_3_5(a0, a1):
    g0 = monty.into(8941241848238582420466759817324047081148088512956452953208002715982955420483)
    g1 = monty.into(10338197737521362862238855242243140895517409139741313354160881284257516364953)
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
