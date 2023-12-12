# P256Verify

## DISCLAIMER

1. To be able to compile the precompile to deploy with a random address, you need to have both `zksolc` and `solc` compiler binaries in the `/usr/local/bin/` directory.
2. From now on, "verifier" refers to the precompile contract, and "validator" refers to the contract that calls the precompile.

## Setup

```
make setup
```

## Deploying the verifier on the in-memory node

1. Run the in-memory node:
    ```
    make run-node
    ```
2. Add a rich wallet private key in `.env` file.
3. Deploy the verifier on the in-memory node:
    ```
    make deploy-verifier-local
    ```

## Deploying the verifier on testnet

1. Add a funded wallet wallet private key in `.env` file.
2. Deploy the verifier on the in-memory node:
    ```
    make deploy-verifier-testnet
    ```

## Deploying the validator on the in-memory node

1. Run the in-memory node:
    ```
    make run-node
    ```
2. Add a rich wallet private key in `.env` file.
3. Deploy the verifier on testnet.
    ```
    make deploy-verifier-local
    ```
4. Hardcode its address in `contracts/Validator.sol`'s `P256_VERIFIER` constant.
5. Deploy the validator on the in-memory node:
    ```
    make deploy-validator-local
    ```

## Deploying the validator on the testnet

1. Add a funded wallet wallet private key in `.env` file.
2. Deploy the verifier on testnet.
    ```
    make deploy-verifier-testnet
    ```
3. Hardcode its address in `contracts/Validator.sol`'s `P256_VERIFIER` constant.
4. Deploy the validator on testnet:
    ```
    make deploy-validator-testnet
    ```
