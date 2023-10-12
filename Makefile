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

run: build-precompiles
	cd submodules/era-test-node && cargo run -- --show-calls=all --resolve-hashes run

test:
	cd tests && \
	cargo test ${PRECOMPILE}

docs:
	cd docs && mdbook serve --open
