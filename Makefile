.PHONY: setup update run test docs

SOLC = solc
SRC = .
PRECOMPILES_DIR = $(SRC)/precompiles
PRECOMPILES = $(wildcard $(PRECOMPILES_DIR)/*.yul)

debug:
	@echo "PRECOMPILES_DIR = $(PRECOMPILES_DIR)"
	@echo "PRECOMPILES = $(PRECOMPILES)"

setup:
	git submodule update --init && \
	cp -r precompiles/ submodules/era-test-node/etc/system-contracts/contracts/precompiles && \
	cd submodules/era-test-node && \
	make build-contracts

update:
	git submodule update

run:
	cp -r precompiles/ submodules/era-test-node/etc/system-contracts/contracts/precompiles && \
	cd submodules/era-test-node && \
	make build-precompiles && \
	cargo run -- --show-calls=all --resolve-hashes run

test:
	cd tests && \
	cargo test ${PRECOMPILE}

docs:
	cd docs && mdbook serve --open

# ╔════════════════════════════════════════════════════════════════════════╗
# ║ Automated checks and tests                                             ║
# ╚════════════════════════════════════════════════════════════════════════╝

# Checks that zksolc is able to compile an individual Yul contract.
# Usage example: make check.compiles.EcAdd.yul
check.compiles.%: $(PRECOMPILES_DIR)/%
	./scripts/check-that-yul-file-compiles "$^"

# Checks that zksolc is able to build every file under the $(PRECOMPILES_DIR) dir
check.compiles: $(PRECOMPILES:$(PRECOMPILES_DIR)/%=check.compiles.%)
	@echo "All YUL files compiled successfully."
