.PHONY: compile deploy

setup:
	yarn install

compile:
	python3 scripts/compile_p256verify_precompile.py

deploy-local: compile
	yarn hardhat deploy-zksync --script deploy/deploy.ts --network inMemoryNode

deploy-testnet: compile
	yarn hardhat deploy-zksync --script deploy/deploy.ts --network zkSyncTestnet
