# How to add and test your own precompile

> **DISCLAIMER**: This guide assumes you’re developing in the `zksync_era_precompiles` repo, if not, step one should be done differently.


1. Create a file in `precompiles/`.
2. Add the precompile name to the refresh precompiles script in the `era-test-node` submodule `submodules/era-test-node/scripts/refresh_precompiles.sh`
3. Wiring the precompile to the node
    1. Assign an address to it in `submodules/era-test-node/src/deps/system_contracts.rs`.
    2. Add it to the `yul_contracts` array inside `COMPILED_IN_SYSTEM_CONTRACTS`  in `submodules/era-test-node/src/deps/system_contracts.rs`.
4. Now, running `make run` should run the node with your added precompile.
