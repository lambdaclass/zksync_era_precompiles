#!/usr/bin/env python3

import subprocess
import requests
import time

def main():
    optimization = ["2"]

    headers = {
        # Already added when you pass json=
        # 'content-type': 'application/json',
    }

    json_data = {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'zks_L1BatchNumber',
        'params': [],
    }

    for opt in optimization:
        popen = subprocess.Popen(["make", "run", "OTP={opt}"])
        while True:
            try:
                response = requests.post('http://localhost:8011', headers=headers, json=json_data)
                if response.status_code == 200:
                    break
                time.sleep(5)
            except:
                time.sleep(5)
        subprocess.run(["make", "test"])  
        subprocess.run(["mv", "./tests/gas_reports", f"./tests/gas_reports_{opt}"])

if __name__ == '__main__':
    main()
