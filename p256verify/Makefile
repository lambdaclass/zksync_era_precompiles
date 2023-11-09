.PHONY: compile deploy

setup:
	yarn install

run-node:
	cd .. && make run

compile-verifier:
	python3 scripts/compile_p256verify_precompile.py

deploy-verifier-local: compile-verifier
	yarn hardhat deploy-zksync --script deploy/deploy.ts --network inMemoryNode

deploy-verifier-testnet: compile-verifier
	yarn hardhat deploy-zksync --script deploy/deploy.ts --network zkSyncTestnet

compile-validator:
	yarn hardhat compile

deploy-validator-local: compile-validator
	yarn hardhat deploy-zksync --script deploy/deploy-validator.ts --network inMemoryNode

deploy-validator-testnet: compile-validator
	yarn hardhat deploy-zksync --script deploy/deploy-validator.ts --network zkSyncTestnet
