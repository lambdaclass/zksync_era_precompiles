import json
import subprocess

ZKSOLC_PATH = "/usr/local/bin/zksolc"
SOLC_PATH = "/usr/local/bin/solc"
P256VERIFY_PRECOMPILE_PATH = "../precompiles/P256VERIFY.yul"

def main():
    artifact = {
        "_format": "hh-zksolc-artifact-1",
        "contractName": "P256VERIFY",
        "sourceName": "contracts/P256VERIFY.sol",
        "abi": [
            {
                "stateMutability": "nonpayable",
                "type": "fallback"
            }
        ],
        "bytecode": None,
        "deployedBytecode": None,
        "linkReferences": {},
        "deployedLinkReferences": {},
        "factoryDeps": {}
    }
    bin = subprocess \
        .run([ZKSOLC_PATH, "--solc", SOLC_PATH, "--system-mode", "-Oz", "--yul", P256VERIFY_PRECOMPILE_PATH, "--bin"], stdout=subprocess.PIPE) \
        .stdout \
        .decode("utf-8") \
        .split("bytecode: ")[1] \
        .strip()
    
    artifact["bytecode"] = bin
    artifact["deployedBytecode"] = bin

    with open("artifacts-zk/contracts/P256VERIFY/P256VERIFY.json", "w") as f:
        json.dump(artifact, f, indent=4)

if __name__ == "__main__":
    main()
