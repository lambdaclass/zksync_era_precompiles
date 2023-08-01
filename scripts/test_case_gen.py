import io
import os
import json
import enum
import re

TEST_DIRS = ['/Users/ivanlitteri/Lambda/tests/GeneralStateTests/stZeroKnowledge', '/Users/ivanlitteri/Lambda/tests/GeneralStateTests/stZeroKnowledge2']

ParserState = enum.Enum('ParserState', ['INPUT', 'NOT_INPUT'])

def write_imports(test_file: io.TextIOWrapper, precompile):
    test_file.write("use hex;\n")
    test_file.write(f"use zksync_web3_rs::{{zks_utils::{precompile}, types::Bytes}};\n")
    test_file.write("\n")
    test_file.write("mod test_utils;\n")
    test_file.write("use test_utils::{eth_call, era_call};\n")
    test_file.write("\n")

def write_test_case(precompile, test_case_data, test_file: io.TextIOWrapper):
    test_file.write("// " + test_case_data["comment"] + "\n")
    test_file.write("#[tokio::test]\n")
    test_file.write("async fn " + test_case_data["name"] + "() {\n")
    test_file.write(f"\tlet eth_response = eth_call({precompile}, None, Some(Bytes::from(hex::decode(\"{test_case_data['calldata']}\").unwrap()))).await.unwrap();\n".replace("\'", "\""))
    test_file.write(f"\tlet era_response = era_call({precompile}, None, Some(Bytes::from(hex::decode(\"{test_case_data['calldata']}\").unwrap()))).await.unwrap();\n".replace("\'", "\""))
    test_file.write(f"\tassert_eq!(eth_response, era_response, \"{test_case_data['comment']}\");\n")
    test_file.write("}\n")
    test_file.write("\n")

def write_test_suit(precompile: str, test_suit_data, test_file: io.TextIOWrapper):
    precompile_address = "ECADD_PRECOMPILE_ADDRESS" if precompile == "ecadd" else "ECMUL_PRECOMPILE_ADDRESS" if precompile == "ecmul" else "ECPAIRING_PRECOMPILE_ADDRESS"
    write_imports(test_file, precompile_address)
    for test_case in test_suit_data:
        write_test_case(precompile_address, test_case, test_file)

def main():
    tests_data: dict(str, list) = {}
    # Open a json file
    for test_dir in TEST_DIRS:
        for entry in os.scandir(test_dir):
            if entry.is_dir():
                continue
            with open(test_dir + '/' + entry.name, 'r') as entry_file:
                data = json.load(entry_file)

                test_name = list(data.keys())[0]
                precompile = "ecadd" if "ecadd" in test_name else "ecmul" if "ecmul" in test_name else "ecpairing"
                comment: str = data[test_name]["_info"]["comment"]
                parameters = []
                calldata = data[test_name]["transaction"]["data"][0]

                # Parse ecadd input
                if precompile == "ecadd":
                    # points = re.findall(r"\([0-9]+, [0-9]+\)", comment)
                    # for point in points:
                    #     x, y = point[1:-1].split(", ")
                    #     parameters.append(x)
                    #     parameters.append(y)

                    # Skips "0x" and the first 136 bytes
                    calldata = calldata[138:]
                # Parse ecmul input
                elif precompile == "ecmul":
                    # point = re.findall(r"\([0-9]+, [0-9]+\)", comment)[0]
                    # factor = re.findall(r"factor [0-9]+ into", comment)[0].replace("factor ", "").replace(" into", "")
                    # x, y = point[1:-1].split(", ")
                    # parameters.append(x)
                    # parameters.append(y)
                    # parameters.append(factor)

                    # Skips "0x" and the first 136 bytes
                    calldata = calldata[138:]
                elif precompile == "ecpairing":
                    continue

                if precompile not in tests_data:
                    tests_data[precompile] = []
                tests_data[precompile].append({
                    "name": test_name.replace("-", "_"),
                    "comment": comment,
                    "parameters": parameters,
                    "calldata": calldata,
                })

    for precompile, precompile_test_data in tests_data.items():
        with open(f'/Users/ivanlitteri/Lambda/zksync_era_precompiles/tests/tests/{precompile}_tests.rs', 'w') as test_file:
            write_test_suit(precompile, precompile_test_data, test_file)

if __name__ == '__main__':
    main()