.PHONY: compile deploy

setup:
	yarn install

compile:
	python3 scripts/compile_p256verify_precompile.py

deploy: compile
	yarn hardhat deploy-zksync --network ${NET} --script deploy/deploy.ts
