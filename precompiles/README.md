# How to add and test your own precompile

1. Create a *.yul file in '/precompile'
2. Create an address for your precompile after 'submodules/era-test-node/src/deps/system_contracts.rs:44 starting from address( ..., 0x01, 0xFF, 0xFF)
3. Add your precompile to the `yul_contracts` list in the same file.
4. Add your specific tests at 'tests/tests/factory'
