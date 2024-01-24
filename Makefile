.PHONY: install run copy-precompiles build-precompiles download-node build-node setup-node update-node run-node run-node-light test docs clean

# Main commands

install: setup-node
	cp -r precompiles/ submodules/era-test-node/etc/system-contracts/contracts/precompiles && \
	cd submodules/era-test-node && \
	make build-contracts

# Precompiles commands

copy-precompiles:
	cp precompiles/*.yul submodules/era-test-node/etc/system-contracts/contracts/precompiles/

build-precompiles: copy-precompiles
	cd submodules/era-test-node && \
	make build-contracts

# Node Commands

download-node:
	cd submodules && \
	[ -d "./era-test-node" ] || git clone git@github.com:LambdaClass/era-test-node.git --branch lambdaclasss_precompiles

build-node:
	cd submodules/era-test-node && make rust-build && make build-contracts

setup-node: download-node build-node

update-node:
	cd submodules/era-test-node && git pull && make rust-build

run-node:
	./submodules/era-test-node/target/release/era_test_node --show-calls=all --resolve-hashes --show-gas-details=all run

run-node-light:
	./submodules/era-test-node/target/release/era_test_node run

# Other commands

test:
	cd tests && \
	cargo test ${PRECOMPILE}

docs:
	cd docs && mdbook serve --open

clean:
	rm submodules/era-test-node/src/deps/contracts/*.yul.zbin submodules/era-test-node/etc/system-contracts/contracts/precompiles/*.yul
