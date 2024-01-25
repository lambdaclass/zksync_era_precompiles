import glob
import json
from eth_utils import function_abi_to_4byte_selector

for file_path in glob.glob('*.json'):
    with open(file_path, 'r') as file:
        json_data = json.load(file)

    for function_abi in json_data["abi"]:
        if function_abi["type"] != "function":
            continue
        function_name = function_abi['name']
        function_signature = function_abi_to_4byte_selector(function_abi).hex()

        inputs = function_abi.get('inputs', [])
        arg_types = [input_data['type'] for input_data in inputs]
        arg_string = ', '.join(arg_types)

        print(
            f"[\"0x{function_signature}\", \"{function_name}({arg_string})\"],"
        )
