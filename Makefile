OPT ?= 3

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
	sed -i '' -e 's/--optimization [123sz]/--optimization ${OPT}/' submodules/era-test-node/etc/system-contracts/scripts/compile-yul.ts
	cd submodules/era-test-node && make build-precompiles

run: build-precompiles
	cd submodules/era-test-node && cargo run -- --show-calls=all --resolve-hashes run

test:
	cd tests && \
	cargo test ${PRECOMPILE}

docs:
	cd docs && mdbook serve --open
