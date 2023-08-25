# zkSync Era Precompiles

DISCLAIMER: This implementation is still being developed and has not been reviewed or audited. Use at your own risk.

This is a precompile library implemented in Yul to speedup arithmetic operations of elliptic curves.
In the next weeks we will add more optimizations and benchmarks.

# Current Status

| Precompile | MVP | Optimized |
| --- | --- | --- |
| ecAdd | ✅ | ✅ |
| ecMul | ✅ | ✅ |
| ecPairing | 🏗️ | ❌ |
| modexp | ✅ | 🏗️ |

## Summary

- `ecAdd` is optimized with finite field arithmetic in Montgomery form and optimized modular inverse with a modification of the binary extended Euclidean algorithm that skips the Montgomery reduction step for inverting. There is not much more room for optimizations, maybe we could think of Montgomery squaring (SOS) to improve the finite field squaring.
- `ecMul` is optimized with finite field arithmetic in Montgomery form, optimized modular inverse with a modification of the binary extended Euclidean algorithm that skips the Montgomery reduction step for inverting, and the elliptic curve point arithmetic is being done in homogeneous projective coordinates. There are some other possible optimizations to implement, one is the one discussed in the Slack channel (endomorphism: GLV or wGLV), the [windowed method](https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication#Windowed_method), the [sliding-window method](https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication#Sliding-window_method), [wNAF (windowed non-adjacent form)](https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication#w-ary_non-adjacent_form_(wNAF)_method) to improve the elliptic curve point arithmetic, and Montgomery squaring (SOS) to improve the finite field squaring, Jacobian projective coordiantes (this would have similar performance and gas costs as working with the homogeneous projective coordinates but it would be free to add it since we need this representation for `ecPairing`).
- `modexp` status is detailed in this Slack message
    
    https://lambdaclass.slack.com/archives/C03GS78HS02/p1692141200550299
    
- `ecPairing` will be implemented as it is detailed in this document. We currently have the towered field extensions working and started working on the line functions for the addition and the double step of the miller loop.


# Used algorithms

|  | Unoptimized |  |  | Optimized |  |  |
| --- | --- | --- | --- | --- | --- | --- |
| Operation | ecAdd | ecMul | modexp | ecAdd | ecMul | modexp |
| Modular Addition | addmod | addmod | addmod | addmod + Montgomery form | addmod + Montgomery form | addmod + Montgomery form |
| Modular Subtraction | addmod | addmod | addmod | addmod + Montgomery form | addmod + Montgomery form | addmod + Montgomery form |
| Modular Multiplication | mulmod | mulmod | mulmod | Montgomery multiplication | Montgomery multiplication | Montgomery multiplication |
| Modular Exponentiation | Binary exponentiation | Binary exponentiation | Binary exponentiation | Binary exponentiation + Montgomery form | Binary exponentiation + Montgomery form | Binary exponentiation + Montgomery form |
| Modular Inversion | Fermat’s little theorem | Fermat’s little theorem | None | Binary Extended GCD + Montgomery form | Binary Extended GCD + Montgomery form |  |

## Resources

- [EVM precompiles list](https://www.evm.codes/precompiled?fork=shanghai)
- [EIP-196: Precompiled contracts for addition and scalar multiplication on the elliptic curve alt_bn128](https://eips.ethereum.org/EIPS/eip-196)
- [EIP-197: Precompiled contracts for optimal ate pairing check on the elliptic curve alt_bn128](https://eips.ethereum.org/EIPS/eip-197)
- [EIP-198: Big integer modular exponentiation](https://eips.ethereum.org/EIPS/eip-198)
- [EIP-1108: Reduce alt_bn128 precompile gas costs](https://eips.ethereum.org/EIPS/eip-1108)
- [EIP-2565: ModExp Gas Cost](https://eips.ethereum.org/EIPS/eip-2565)

## Development

Follow the instructions below to setup the repo and run a development L2 node.

### Setup the repo

```
make setup
```

### Update the submodules (if needed)

```
make update
```

### Run a development L2 node

```
make run
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
