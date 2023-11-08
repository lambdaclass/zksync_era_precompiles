# P256Verify

## DISCLAIMER

To be able to compile the precompile to deploy with a random address, you need to have both `zksolc` and `solc` compiler binaries in the `/usr/local/bin/` directory.

## How to deploy on testnet

1. Install dependencies

```bash
yarn install
```

2. Deploy

```bash
make deploy NET=zkSyncTestnet
```

## How to deploy on the in-memory node

1. Install dependencies

```bash
yarn install
```

2. Run the in-memory node

```bash
make run-node
```

3. Deploy

```bash
make deploy NET=inMemoryNode
```
