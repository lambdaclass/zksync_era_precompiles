import math, unittest, random, pdb


# def modular_exponentiation(base: int, exponent: int, modulus: int) -> int:
#     r, k = calculate_r_constant_for(modulus)
#     result = 1
#     base = base % modulus

#     while exponent > 0:
#         if exponent % 2 == 1:
#             result = barrett_reduction(result * base, modulus)
#         base = barrett_reduction(base * base, modulus)
#         exponent >>= 1
#     return result

def log2_for_n(n: int) -> int:
    result = 0.
    while n >= 1:
       n = n >> 2 
       result = result + 1
    return result

# The r constant for Barret is r = 4**k / n. 
# Where k = log2(n), and n the modulo.
def calculate_r_constant_for(n: int) -> (int, int):
   # Since 4**k = (2**(2**k))
   # we can shift 1 2k times instead.
    k = int((log2_for_n(n)) % n)
    # 4**k
    four_to_the_power_of_k = (1 << 2*k)
    # Seems like this division cannot be avoided
    r = four_to_the_power_of_k // n
    return r,k

# Barret reduction, taking this blog post as reference:
# https://www.nayuki.io/page/montgomery-reduction-algorithm
def barrett_reduction(x: int, n: int) -> int:
    assert 0 <= x <= n**2
    r,k = calculate_r_constant_for(n)
    t = x - (((x*r)) >> (2*k))*n
    if t < n:
        reduction = t
    else:
        reduction = t - n
    return reduction

def modular_exponentiation(base: int, exponent: int, modulus: int) -> int:
    result = 1
    # base = barrett_reduction(base, modulus) 
    while exponent > 0:
        if exponent % 2 == 1:
            result = barrett_reduction(result*base, modulus)
        exponent = exponent >> 1
        base = barrett_reduction(base * base, modulus)
    return result

class BarretTester(unittest.TestCase):
        def test_basic(self) -> None:
                for _ in range(300):
                    x = random.randint(1, 2**64)
                    modulo: int = random.randrange(x**2, x**3)
                    expected: int = x % modulo
                    self.assertEqual(expected, barrett_reduction(x, modulo)) 
        def test_modular_exponentiation(self) -> None:
            for _ in range(100):
                exponent = random.randint(1, 5)
                base = random.randint(1, 2**10)
                modulo: int = random.randrange(base**exponent, base**(exponent+1))
                expected = (base**exponent)%modulo
                result = modular_exponentiation(base, exponent, modulo)

if __name__ == '__main__':
    unittest.main()
