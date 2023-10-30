# This script uses Daimo's test vectors, you can find the original files here:
# https://github.com/daimo-eth/p256-verifier/blob/master/test-vectors/vectors_wycheproof.jsonl
# https://github.com/daimo-eth/p256-verifier/blob/master/test-vectors/vectors_random_valid.jsonl

import io
import json

TESTS_PATHS = [
    "assets/vectors_random_valid.json",
    "assets/vectors_wycheproof.json"
]

def write_reference(test_file: io.TextIOWrapper):
    test_file.write("/*\n")
    test_file.write("\tThese tests were generated using Daimo's test vectors, you can find the original files here:\n")
    test_file.write("\thttps://github.com/daimo-eth/p256-verifier/blob/master/test-vectors/vectors_wycheproof.jsonl\n")
    test_file.write("\thttps://github.com/daimo-eth/p256-verifier/blob/master/test-vectors/vectors_random_valid.jsonl\n")
    test_file.write("\thttps://github.com/daimo-eth/p256-verifier/blob/master/test-vectors/vectors_scure_base64url.jsonl\n")
    test_file.write("*/\n")
    test_file.write("\n")

def write_imports(test_file: io.TextIOWrapper, precompile):
    test_file.write("use hex;\n")
    test_file.write(f"use zksync_web3_rs::types::{{Address, Bytes, H160}};\n")
    test_file.write("\n")
    test_file.write("mod test_utils;\n")
    test_file.write("use test_utils::era_call;\n")
    test_file.write("\n")

def write_constants(test_file: io.TextIOWrapper):
    test_file.write("pub const P256VERIFTY_PRECOMPILE_ADDRESS: Address = H160([\n")
    test_file.write("\t0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,\n")
    test_file.write("\t0x00, 0x00, 0x00, 0x19,\n")
    test_file.write("]);\n")
    test_file.write("\n")
    test_file.write("const RESPONSE_VALID: [u8; 32] = [\n")
    test_file.write("\t0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,\n")
    test_file.write("];\n")
    test_file.write("\n")
    test_file.write("const RESPONSE_INVALID: [u8; 32] = [\n")
    test_file.write("\t0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\n")
    test_file.write("];\n")
    test_file.write("\n")

def write_test_case(precompile, test_case_data, test_file: io.TextIOWrapper):
    if test_case_data["comment"]:
        test_file.write(f"// {test_case_data['comment']}\n")
    test_file.write("#[tokio::test]\n")
    test_file.write("async fn " + test_case_data["name"] + "() {\n")
    test_file.write(f"\tlet era_response = era_call({precompile}, None, Some(Bytes::from(hex::decode(\"{test_case_data['calldata']}\").unwrap()))).await.unwrap();\n".replace("\'", "\""))
    if test_case_data["valid"]:
        test_file.write(f"\tassert_eq!(era_response, Bytes::from(RESPONSE_VALID));\n")
    else:
        test_file.write(f"\tassert_eq!(era_response, Bytes::from(RESPONSE_INVALID));\n")
    test_file.write("}\n")
    test_file.write("\n")

def write_test_suit(test_suit_data, test_file: io.TextIOWrapper):
    write_reference(test_file)
    write_imports(test_file, "P256VERIFTY_PRECOMPILE_ADDRESS")
    write_constants(test_file)
    for test_case in test_suit_data:
        write_test_case("P256VERIFTY_PRECOMPILE_ADDRESS", test_case, test_file)

def main():
    test_case_data = []
    for test_path in TESTS_PATHS:
        with open(test_path, "r") as entry_file:
            data = json.load(entry_file)
            i = 0
            for test_case in data:
                hash = test_case["hash"]
                r = test_case["r"]
                s = test_case["s"]
                x = test_case["x"]
                y = test_case["y"]

                calldata = hash + r + s + x + y

                if "wycheproof" in entry_file.name:    
                    name = f"wycheproof_{i}"
                    comment = test_case["comment"]
                    valid = test_case["valid"]
                    i += 1
                else:
                    name = "_".join(test_case["comment"].split(" "))
                    valid = True
                    comment = None

                test_case_data.append({"name": name,"calldata": calldata, "comment": comment, "valid": valid})

            write_test_suit(test_case_data, open("tests/tests/p256verify_daimo_tests.rs", "w"))

if __name__ == "__main__":
    main()
