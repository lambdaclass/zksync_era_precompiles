# Introduction

On top of having a set of opcodes to choose from, the EVM also offers a set of more advanced functionalities through precompiled contracts. These are a special kind of contracts that are bundled with the EVM at fixed addresses, and can be called with a determined gas cost. The addresses start from 1, and increment for each contract. New hardforks may introduce new precompiled contracts. They are called from the opcodes like regular contracts, with instructions like CALL. The gas cost mentioned here is purely the cost of the contract, and does not consider the cost of the call itself nor the instructions to put the parameters in memory.

For Go-Ethereum, the code being run is written in Go, the gas costs are defined in each precompile spec. 

In the case of zkSync Era, precompiles are written in Yul for two reasons: the main one is because the zkEVM needs to be able to prove their execution (and at the moment it cannot do that if the code being run is executed outside the VM) and the second one is because the cost in gas needs to be as cheap as possible.

Today zkSync Era supports `Keccak256`, `SHA256` and `ecrecover` precompiles and the ones to be written (and the ones we are working on) are: `ecAdd` for elliptic curve point addition, `ecMul` for elliptic curve point scalar multiplication and `ecPairing` bilinear function on groups on the curve alt_bn128; `modexp` for modular exponentiation; and elliptic curve support for `P256`, `secp256r1` and `secp256k1`.

By adding these precompiles we're improving the compatibility between the EVM and the zkEVM.
