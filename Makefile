.PHONY: clean

current_dir := ${CURDIR}
era_test_node_base_path := $(current_dir)/submodules/era-test-node
era_test_node := $(era_test_node_base_path)/target/release/era_test_node
era_test_node_makefile := $(era_test_node_base_path)/Makefile
precompile_dst_path := $(era_test_node_base_path)/etc/system-contracts/contracts/precompiles

precompiles_source = $(wildcard $(current_dir)/precompiles/*.yul)
precompiles_dst = $(patsubst $(current_dir)/precompiles/%, $(precompile_dst_path)/%, $(precompiles_source))

run-node: $(era_test_node) $(precompiles_dst)
	$(era_test_node) --show-calls=all --resolve-hashes --show-gas-details=all run

run-node-light: $(era_test_node)
	$(era_test_node) run

# We could make a better rule for copied_precompiles, as to avoid running the cp everytime and building the contracts, but it's not very relevant. Doing this the precompiles are always updated
$(era_test_node): $(era_test_node_makefile)
	cd $(era_test_node_base_path) && make rust-build
	
## precompile source is added just to avoid recompiling if they haven't changed
$(precompiles_dst): $(precompiles_source)
	cp precompiles/*.yul $(precompile_dst_path) && cd $(era_test_node_base_path) && make build-contracts

$(era_test_node_makefile):
	mkdir -p submodules && \
	cd submodules && \
	git clone git@github.com:LambdaClass/era-test-node.git --branch lambdaclasss_precompiles

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
