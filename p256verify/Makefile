.PHONY: compile deploy

compile:
	python3 scripts/compile_p256verify_precompile.py

deploy: compile
	yarn hardhat deploy-zksync --network ${NET}
