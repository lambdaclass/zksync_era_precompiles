N = 21888242871839275222246405745257275088696311157297823662689037894645226208583

def add(augend, addend):
    return (augend + addend) % N

def sub(minuend, subtrahend):
    return add(minuend, N - subtrahend, N)

def mul(multiplicand, multiplier):
    return (multiplicand * multiplier) % N

def div(dividend, divisor):
    return mul(dividend, inv(divisor, N), N)

def inv(base):
    return exp(base, N - 2, N)

def exp(base, exponent):
    return pow(base, N - 2, N)
