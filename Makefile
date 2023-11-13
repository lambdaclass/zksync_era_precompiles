.PHONY: setup update run test docs

setup:
	git submodule update --init && \
	cp -r precompiles/ submodules/era-test-node/etc/system-contracts/contracts/precompiles && \
	cd submodules/era-test-node && \
	make build-contracts

update:
	git submodule update

.PHONY: copy-precompiles
copy-precompiles:
	cp precompiles/*.yul submodules/era-test-node/etc/system-contracts/contracts/precompiles/

.PHONY: build-precompiles
build-precompiles: copy-precompiles
	cd submodules/era-test-node && make build-precompiles

build-test-node:
	cd submodules/era-test-node && cargo +nightly build

run: build-precompiles
	cd submodules/era-test-node && cargo +nightly run -- --show-calls=all --resolve-hashes --show-gas-details=all run

test:
	cd tests && \
	cargo test ${PRECOMPILE}

docs:
	cd docs && mdbook serve --open

clean:
	rm submodules/era-test-node/src/deps/contracts/*.yul.zbin submodules/era-test-node/etc/system-contracts/contracts/precompiles/*.yul
