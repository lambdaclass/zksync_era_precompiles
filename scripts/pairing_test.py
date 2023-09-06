import json
from functools import reduce
import montgomery as monty
import alt_bn128_pairing as pairing
import fp12

json_file_path = "pairing_eth_test.json"

tests = []

with open(json_file_path, "r") as json_file:
    data = json.load(json_file)
    tests = []
    for element in data:
        input_data = element["Input"]
        expected_data = element["Expected"]

        chunks = [monty.into(int(input_data[i:i+64], 16)) for i in range(0, len(input_data), 64)]
        sublistas = [chunks[i:i+6] for i in range(0, len(chunks), 6)]

        for sublista in sublistas:
            temp = sublista[2]
            sublista[2] = sublista[3]
            sublista[3] = temp

            temp = sublista[4]
            sublista[4] = sublista[5]
            sublista[5] = temp

        tests.append({
            "Input": sublistas,
            "Expected": int(element["Expected"], 16)
        })

for test in tests:
    result = []
    for i in test["Input"]:
        result.append(pairing.pair(*i))
    try:
        resultado = reduce(lambda x, y: fp12.mul(*x,*y), result)
        if resultado == fp12.ONE:
            resultado = 1
        else:
            resultado = 0

        print(resultado == test["Expected"])
    except:
        print("Error")
