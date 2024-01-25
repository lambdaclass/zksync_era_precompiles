.PHONY: clean

current_dir := ${CURDIR}
era_test_node_base_path := $(current_dir)/test-node-subtree
era_test_node := $(era_test_node_base_path)/target/release/era_test_node
era_test_node_makefile := $(era_test_node_base_path)/Makefile
precompile_dst_path := $(era_test_node_base_path)/etc/system-contracts/contracts/precompiles

precompiles_source = $(wildcard $(current_dir)/precompiles/*.yul)
precompiles_dst = $(patsubst $(current_dir)/precompiles/%, $(precompile_dst_path)/%, $(precompiles_source))

run-node: $(era_test_node) $(precompiles_dst)
	$(era_test_node) --show-calls=all --resolve-hashes --show-gas-details=all run

run-node-light: $(era_test_node) $(precompiles_dst)
	$(era_test_node) run

$(era_test_node): $(era_test_node_makefile)
	cd $(era_test_node_base_path) && make rust-build
	
## precompile source is added just to avoid recompiling if they haven't changed
$(precompiles_dst): $(precompiles_source)
	cp precompiles/*.yul $(precompile_dst_path) && cd $(era_test_node_base_path) && make build-contracts

build-precompiles: $(precompiles_dst)

# Node Commands
update-node: era_test_node
	cd $(era_test_node_base_path) && git pull && make rust-build

test:
	cd tests && \
	cargo test ${PRECOMPILE}

docs:
	cd docs && mdbook serve --open

clean:
	rm $(era_test_node_base_path)/src/deps/contracts/*.yul.zbin $(era_test_node_base_path)/etc/system-contracts/contracts/precompiles/*.yul
