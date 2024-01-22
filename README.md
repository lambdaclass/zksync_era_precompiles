# zkSync Era Precompiles

DISCLAIMER: This implementation is still being developed and has not been reviewed or audited. Use at your own risk.

This is a precompile library implemented in Yul to speed up arithmetic operations of elliptic curves.
In the next weeks, we will add more optimizations and benchmarks.

# Current Status

| Precompile | MVP | Optimized | Optional Future Optimizations | Audited | Comments |
| --- | --- | --- | --- | --- | --- |
| ecAdd | ✅ | ✅ | Montgomery SOS Squaring | ✅ | - |
| ecMul | ✅ | ✅ | Montgomery SOS Squaring + Mul GLV | ✅ | - |
| ecPairing | ✅ | ✅ | - | 🏗️ | - |
| modexp | ✅ | ✅ | - | 🏗️ | - |
| P256VERIFY | ✅ | ✅ | Montgomery SOS Squaring | ✅ | - |
| secp256k1VERIFY | ✅ | ✅ | Montgomery SOS Squaring | ✅ | - |

## Summary

- `ecAdd` is optimized with finite field arithmetic in Montgomery form and optimized modular inverse with a modification of the binary extended Euclidean algorithm that skips the Montgomery reduction step for inverting. There is not much more room for optimizations, maybe we could think of Montgomery squaring (SOS) to improve the finite field squaring. *This precompile has been audited a first time and it is currently being audited a second time (after the fixes).*
- `ecMul` is optimized with finite field arithmetic in Montgomery form, optimized modular inverse with a modification of the binary extended Euclidean algorithm that skips the Montgomery reduction step for inverting, and the elliptic curve point arithmetic is being done in homogeneous projective coordinates. There are some other possible optimizations to implement, one is the one discussed in the Slack channel (endomorphism: GLV or wGLV), the [windowed method](https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication#Windowed_method), the [sliding-window method](https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication#Sliding-window_method), [wNAF (windowed non-adjacent form)](https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication#w-ary_non-adjacent_form_(wNAF)_method) to improve the elliptic curve point arithmetic, and Montgomery squaring (SOS) to improve the finite field squaring, Jacobian projective coordinates (this would have similar performance and gas costs as working with the homogeneous projective coordinates but it would be free to add it since we need this representation for `ecPairing`). *This precompile has been audited a first time and it is currently being audited a second time (after the fixes).*
- `modexp` has been updated to support Big Int arithmetic. This means it is now fully compatible with [EIP-198](https://eips.ethereum.org/EIPS/eip-198)'s specification and all the tests are passing, however the gas costs are really high. As an example, passing a modulus with three limbs (three `uint256`s) will most certainly make it run out of gas. The big cost is in the finite field `div_rem` function, which we need to have a modulo operator on big ints, taking around 80/90% of all the gas cost when calling the precompile. The gas cost skyrockets pretty quickly the more limbs numbers have. We are looking into optimization opportunities but gas costs may still remain really high. *This precompile has not been audited yet.*
- `ecPairing`:
    We have based our algorithm implementation primarily on the guidelines presented in the paper ["High-Speed Software Implementation of the Optimal Ate Pairing over Barreto–Naehrig Curves"](https://eprint.iacr.org/2010/354.pdf) . This implementation includes the utilization of Tower Extension Field Arithmetic and the Frobenius Operator.

    To enhance the performance of the Miller loop, we have incorporated specific optimizations, we have optimized line evaluation based on the techniques outlined in ["The Realm of the Pairings"](https://eprint.iacr.org/2013/722.pdf) . Also, instead of using Jacobian coordinates, we have adopted projective coordinates. This choice is particularly advantageous given the large inversion/multiplication ratio in this context.

    In the final exponentiation phase, we have integrated the methods presented in ["Memory-saving computation of the pairing final exponentiation on BN curves"](https://eprint.iacr.org/2015/192.pdf). This includes the Fuentes et al. method and the addition chain. We have also applied Faster Squaring in the Cyclotomic Subgroup, as described in [”Faster Squaring in the Cyclotomic Subgroup of Sixth Degree Extensions”](https://eprint.iacr.org/2009/565.pdf).

    **Remaining Optimizations:** While our implementation has achieved notable results, there are still some straightforward optimizations that can be implemented:

    - **Optimizing Accumulated Value:** We are currently naively multiplying two fp12 elements, which contain many zeros. Modifying this calculation could enhance efficiency. *This is in WIP.*

    **Future Investigations:**  We need to investigate the reliability of additional optimizations, such as the application of the GLV method for multiplication of rational points of elliptic curves.
- `P256VERIFY` is already working and optimized with Shamir’s trick. *This precompile has been audited a first time and it is currently being audited a second time (after the fixes).*
- `secp256k1VERIFY` is already working and optimized with Shamir’s trick. *This precompile has been audited a first time and it is currently being audited a second time (after the fixes).*

## [Gas Consumption](./docs/src/gas_consumption.md)

## Used Algorithms

|  |  | **Precompile** |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- |
| **Arithmetic** | **Operation** | **ecAdd** | **ecMul** | **modexp** | **P256VERIFY** | **secp256k1VERIFY** |
| **Prime Field Arithmetic** | **Addition** | Montgomery Modular Addition | Montgomery Modular Addition | Big Unsigned Integer Addition | Montgomery Modular Addition | Montgomery Modular Addition |
|  | **Subtraction** | Montgomery Modular Subtraction | Montgomery Modular Subtraction | Big Unsigned Integer Subtraction With Borrow | Montgomery Modular Subtraction | Montgomery Modular Subtraction |
|  | **Multiplication** | Montgomery Modular Multiplication | Montgomery multiplication | Big Unsigned Integer Multiplication | Montgomery multiplication | Montgomery multiplication |
|  | **Exponentiation** | - | - | Binary exponentiation | - | - |
|  | **Inversion** | Modified Binary Extended GCD (adapted for Montgomery Form) | Modified Binary Extended GCD (adapted for Montgomery Form) | - | Modified Binary Extended GCD (adapted for Montgomery Form) | Modified Binary Extended GCD (adapted for Montgomery Form) |
| **Elliptic Curve Arithmetic** | **Addition** | Addition in Affine Form | Addition in Homogeneous Projective Form | - | Addition in Homogeneous Projective Form | Addition in Homogeneous Projective Form |
|  | **Double** | Double in Affine Form | Double in Homogeneous Projective Form | - | Double in Homogeneous Projective Form | Double in Homogeneous Projective Form |
|  | **Scalar Multiplication** | - | Double-and-add | - | Double-and-add | Double-and-add |

## Resources

You can find a curated list of helpful resources that we've used for guiding our implementations in [References](./References.md)

## Development

Follow the instructions below to setup the repo and run a development L2 node.

### Setup the repo

```
make install
```

### Running an era-test-node

Once built, run one of the following commands to have a working test node.

```
make run-node
make run-node-light # no call trace, no hash resolving, and no gas details
```

### Must run after every change in a precompile

Our precompiles are located in `precompiles/` but as they are there, they're no being tracked by our `era-test-node` clone. We need to always copy our precompiles into the `era-test-node` repo for it to be able to track and compile them for later testing.

```
make build-node
```

### Run the tests

If you want to run all the tests:

```
make test
```

If you want to run a specific test:

```
make test PRECOMPILE=<precompile_name>
```
