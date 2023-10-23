import random, unittest

class BarrettReducerTest(unittest.TestCase):
        
        def test_basic(self) -> None:
                for _ in range(10000):
                        mod: int = BarrettReducerTest.random_modulus()
                        modsqr: int = mod**2
                        for _ in range(100):
                                x: int = random.randrange(modsqr)
                                expected = x%mod
                                actual = barret_reduce(x, mod)
                                print(f"Expected: {expected} Got: {actual}")
                                if barret_reduce(x, mod) != x % mod:
                                        raise AssertionError()        
        
        @staticmethod
        def random_modulus() -> int:
                bitlen: int = random.randint(2, 100)
                return random.randint((1 << bitlen) + 1, (2 << bitlen) - 1)

        
def barret_reduce(x: int, mod: int) -> int:
        if mod <= 0:
                raise ValueError("Modulus must be positive")
        if mod & (mod - 1) == 0:
                raise ValueError("Modulus must not be a power of 2")
        assert 0 <= x < mod**2
        print(f"Calculating: {x} % {mod}")
        # This can be calculated once for a modexp loop.
        shift = mod.bit_length()*2
        factor = (1 << shift) // mod
        print(f"Factor: {factor}")
        print(f"Shift: {shift}")
        result = mul(x, factor)
        print(f"Result times factor: {result}")
        result = shift_right_n_times(shift, result)
        print(f"Result shifted: {result}")
        result = mul(result, mod)
        print(f"Result shifted times modulo: {result}")
        result = sub(x, result)
        print(f"Result shifted times modulo and then subbed: {result}")
        return result if (result < mod) else (result - mod)

def sub(x: int, y: int) -> int:
        return x - y

def shift_right_n_times(times_to_shift: int, number_to_shift: int) -> int:
        return number_to_shift >> times_to_shift

def mul(x: int, y: int) -> int:
        return x*y
# barret_reduce(10, 6)
