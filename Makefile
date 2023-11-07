.PHONY: setup update run test docs clean compilers get-zksolc get-zkvyper benches

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
	cd submodules/era-test-node && cargo +nightly run -- --show-calls=all --resolve-hashes --show-gas-details=all run

test:
	cd tests && \
	cargo test ${PRECOMPILE}

docs:
	cd docs && mdbook serve --open

clean:
	rm submodules/era-test-node/src/deps/contracts/*.yul.zbin submodules/era-test-node/etc/system-contracts/contracts/precompiles/*.yul

compilers: get-zksolc get-zkvyper
	
get-zksolc:
	wget 'https://github.com/matter-labs/zksolc-bin/raw/main/macosx-arm64/zksolc-macosx-arm64-v1.3.14' -O '/usr/local/bin/zksolc'

get-zkvyper:
	wget 'https://github.com/matter-labs/zkvyper-bin/blob/main/macosx-arm64/zkvyper-macosx-arm64-v1.3.13' -O '/usr/local/bin/zkvyper'

benches:
	make test PRECOMPILE=p256verify_bench
