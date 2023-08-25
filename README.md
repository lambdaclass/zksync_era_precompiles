# zkSync Era Precompiles

DISCLAIMER: This implementation is still being developed and has not been reviewed or audited. Use at your own risk.

This is a precompile library implemented in Yul to speedup arithmetic operations of elliptic curves.

## Precompiles

| Name | Supported | optimized | audited |
| ---| --- | --- | --- |
| `ecAdd` | ✅ | 🏗 | 🏗 |
| `ecMul` | ✅ | 🏗 |  🏗 |
| `modExp` |  🏗  | ❌ | ❌ |
| `ecPairing` | ❌ | ❌ | ❌ |
| `P256` | ❌ | ❌ | ❌ |
| `secp256r1` | ❌ | ❌ | ❌ |
| `secp256q1` | ❌ | ❌ | ❌ |
## Observations

### `ecAdd`

- `invmod` needs to be optimized
- Points addition performance should be improved by using Projective Coordinates 
- The code still needs some refactoring

### `ecMul`

- `invmod` needs to be optimized
- The implementation is naive, a double and add algorithm could be used instead
- Points addition performance should be improved by using Projective Coordinates 
- The code still needs some refactoring

### Gas Usage
- Define the gas model. Should we follow eth eip's specification? or used a custom zksync gas for each operation instead? 
- We need to discuss how this piece of code should be implemented for each precompile:
```
let precompileParams := unsafePackPrecompileParams(
      0, // input offset in words
      // TODO: Double check that the input length is 4 because it could be 2
      // if the input points are packed in a single word (points as tuples of coordinates)
      3, // input length in words (x, y, scalar)
      0, // output offset in words
      // TODO: Double check that the input length is 4 because it could be 1
      // if the input points are packed in a single word (points as tuples of coordinates)
      2, // output length in words (x, y)
      0  // No special meaning, ecMul circuit doesn't check this value
)
let gasToPay := ECMUL_GAS_COST()

// Check whether the call is successfully handled by the ecMul circuit
let success := precompileCall(precompileParams, gasToPay)
let internalSuccess := mload(0)

switch and(success, internalSuccess)
case 0 {
      return(0, 0)
}
default {
      return(0, 64)
}
```
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
