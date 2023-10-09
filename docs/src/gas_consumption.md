# Gas Consumption

> Disclaimer: The following values are approximate because contract calls were needed to print the values
> 

## ecAdd

The test cases are a subset of Ethereum’s [General State Tests](https://github.com/ethereum/tests/tree/develop/GeneralStateTests)

| Test Case | L1 | Unoptimized L2 | Optimized L2 | Improvement |
| --- | --- | --- | --- | --- |
| (0, 0) + (0, 0) | 500 | 7631 | 90 | 84:1 |
| (1, 2) + (0, 0) | 500 | 8417 | 882 | 9,54:1 |
| (0, 0) + (1, 2) | 500 | 8375 | 852 |  |
| (1, 2) + (1, 2) | 500 | 114971 | 39672 |  |
| (1, 3) + (0, 0) | all | all | all | - |
| (0, 0) + (1, 3) | all | all | all | - |
| (6, 9) + (19274124, 124124) | all | all | all | - |
| (0, 3) + (1, 2) | all | all | all | - |
| (10744596414106452074759370245733544594153395043370666422502510773307029471145, 848677436511517736191562425154572367705380862894644942948681172815252343932) + (10744596414106452074759370245733544594153395043370666422502510773307029471145, 21039565435327757486054843320102702720990930294403178719740356721829973864651) | 500 | 9239 | 1716 |  |
| (10744596414106452074759370245733544594153395043370666422502510773307029471145, 848677436511517736191562425154572367705380862894644942948681172815252343932) + (1624070059937464756887933993293429854168590106605707304006200119738501412969, 3269329550605213075043232856820720631601935657990457502777101397807070461336) | 500 | 115289 | 37314 |  |

## ecMul

The test cases are a subset of Ethereum’s [General State Tests](https://github.com/ethereum/tests/tree/develop/GeneralStateTests)

| Test Case | Operation | L1 | Unoptimized L2 | Optimized L2 | Optimized L2 v2* | Optimzed L2 V3* |
| --- | --- | --- | --- | --- | --- | --- |
| 1_3_n | (1, 3) * n | all | all | all | all | all |
| 0_3_n | (0, 3) * n | all | all | all | all | all |
| 1_2_5617 | (1 ,2) * 21888242871839275222246405745257275088548364400416034343698204186575808495617 | 40000 | 37370993 | 12414062 | 437753 | 434969 |
| 7827_6598_5616 | (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) * 21888242871839275222246405745257275088548364400416034343698204186575808495616 | 40000 | 37349429 | 12408464 | 470951 | 469205 |
| 1_2_340282366920938463463374607431768211456 | (1, 2) * 340282366920938463463374607431768211456 | 40000 | 13666379 | 4532132 | 183425 | 211433 |
| 1_2_9935 | (1, 2) * 115792089237316195423570985008687907853269984665640564039457584007913129639935 | 40000 | 54052937 | 17960468 | 700655 | 562049 |
| 1_2_5617 | (1, 2) * 21888242871839275222246405745257275088548364400416034343698204186575808495617 | 40000 | 37370993 | 12402404 | 437753 | 434969 |
| 1_2_2 | (1, 2) * 2 | 40000 | 108023 | 38594 | 38669 | 38681 |
| 7827_6598_1456 | (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) * 340282366920938463463374607431768211456 | 40000 | 13666421 | 4539146 | 183383 | 211391 |
| 7827_6598_0 | (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) * 0 | 40000 | 2615 | 920 | 557 | 569 |
| 7827_6598_9935 | (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) * 115792089237316195423570985008687907853269984665640564039457584007913129639935 | 40000 | 54020201 | 17939828 | 701843 | 562379 |
| 7827_6598_1 | (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) * 1 | 40000 | 2627 | 932 | 569 | 581 |
| 1_2_9 | (1, 2) * 9 | 40000 | 530891 | 182684 | 41951 | 92903 |
| 7827_6598_2 | (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) * 2 | 40000 | 107933 | 34850 | 36401 | 36413 |
| 7827_6598_5617 | (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) * 21888242871839275222246405745257275088548364400416034343698204186575808495617 | 40000 | 37361489 | 12416594 | 437753 | 434969 |
| 7827_6598_9 | (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) * 9 | 40000 | 532079 | 173864 | 42383 | 93335 |
| 1_2_5616 | (1, 2) * 21888242871839275222246405745257275088548364400416034343698204186575808495616 | 40000 | 37376663 | 12414062 | 471749 | 467423 |
| 7827_6598_5616 | (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) * 21888242871839275222246405745257275088548364400416034343698204186575808495616 | 40000 | 37349429 | 12408464 | 470951 | 469205 |
| 0_0_n | (0, 0) * n | 40000 | 1817 | 116 | 107 | 101 |

<aside>
💡 *The second version of the optimization includes the usage of projective coordinates

</aside>

<aside>
💡 *The third version of the optimization includes the usage of wGLV multiplication (This is not a final version and is included in a development branch)

</aside>

## ecPairing

The test cases are a subset of Ethereum’s [General State Tests](https://github.com/ethereum/tests/tree/develop/GeneralStateTests)

| Test Case | Operation | L1 | Unomptimized L2 |
| --- | --- | --- | --- |
| ecpairing_one_point_not_in_subgroup |  | 260000 |  |
| ecpairing_one_point_insufficient_gas |  | 260000 | 3814424 |
| ecpairing_bad_length_191 |  | all | all |
| ecpairing_empty_data |  | 100000 | 31 |
| ecpairing_one_point_with_g1_zero |  | 260000 | 586 |
| ecpairing_bad_length_193 |  | all | all |
| ecpairing_empty_data_insufficient_gas |  | 100000 | 31 |
| ecpairing_one_point_fail |  | 260000 | 3814424 |
| ecpairing_perturb_g2_by_one |  | 260000 | all |
| ecpairing_one_point_with_g2_zero |  | 260000 | 1726 |
| ecpairing_one_point_with_g2_zero_and_g1_invalid |  | all | all |
| ecpairing_perturb_g2_by_curve_order |  | 260000 | all |
| ecpairing_perturb_g2_by_field_modulus_again |  | 260000 | all |
| ecpairing_perturb_g2_by_field_modulus |  | 260000 | all |
| ecpairing_perturb_zeropoint_by_curve_order |  | all | all |
| ecpairing_three_point_fail_1 |  | 580000 | 11439640 |
| ecpairing_two_point_fail_1 |  | 420000 | 7628628 |
| ecpairing_three_point_match_1 |  | 580000 | 7626942 |
| ecpairing_perturb_zeropoint_by_one |  | all | all |
| ecpairing_two_point_fail_2 |  | 420000 | 7625634 |
| ecpairing_perturb_zeropoint_by_field_modulus |  | all | all |
| ecpairing_two_point_match_1 |  | 420000 | 7628760 |
| ecpairing_two_point_match_2 |  | 420000 | 7628760 |
| ecpairing_two_point_match_3 |  | 420000 | 7626984 |
| ecpairing_two_point_match_4 |  | 420000 | 7625568 |
| ecpairing_two_point_match_5 |  | 420000 | 1960 |
| ecpairing_two_point_oog |  | 420000 | 7628760 |
| ecpairing_two_points_with_one_g2_zero |  | 420000 | 3815798 |

## modexp

🏗️

The test cases are a subset of Ethereum’s [General State Tests](https://github.com/ethereum/tests/tree/develop/GeneralStateTests)

The L1 gas cost is calculated using the function provided in the [EIP-198](https://eips.ethereum.org/EIPS/eip-198).

| Test Case | Lengths | Operation | L1 | Unoptimized L2 |
| --- | --- | --- | --- | --- |
| modexp_0 | length_of_BASE = 1
length_of_EXPONENT = 32
length_of_MODULUS = 32 | 3 ** 115792089237316195423570985008687907853269984665640564039457584007908834671662 % 115792089237316195423570985008687907853269984665640564039457584007908834671663 | 13056 | 169866 |
| modexp_1 | length_of_BASE = 0
length_of_EXPONENT = 32
length_of_MODULUS = 32 | 0 ** 115792089237316195423570985008687907853269984665640564039457584007908834671662 % 115792089237316195423570985008687907853269984665640564039457584007908834671663 | 13056 | 218 |
| modexp_3 | length_of_BASE = 1
length_of_EXPONENT = 32
length_of_MODULUS = 32 | 3 ** 65535 % 57896044618658097711785492504343953926634992332820282019728792003956564819968 | 768 | 10741 |
| modexp_4 | length_of_BASE = 1
length_of_EXPONENT = 32
length_of_MODULUS = 32 | 3 ** 65535 % 57896044618658097711785492504343953926634992332820282019728792003956564819968 | 768 | 10741 |
| modexp_5 | length_of_BASE = 1
length_of_EXPONENT = 32
length_of_MODULUS = 32 | 3 ** 0 % 0 | 51 | 275 |
| modexp_6 | length_of_BASE = 1
length_of_EXPONENT = 0
length_of_MODULUS = 32 | 3 ** 0 % 57896044618658097711785492504343953926634992332820282019728792003956564819968 | 52 | 140 |
| modexp_7 | length_of_BASE = 1
length_of_EXPONENT = 1
length_of_MODULUS = 32 | 0 ** 0 % 57896044618658097711785492504343953926634992332820282019728792003956564819968 | 52 | 348 |
| modexp_8 | length_of_BASE = 1
length_of_EXPONENT = 1
length_of_MODULUS = 32 | 0 ** 0 % 0 | 51 | 275 |
| modexp_9 | length_of_BASE = 1
length_of_EXPONENT = 1
length_of_MODULUS = 0 | 1 ** 1 % 0 | 0 | 200 |
| modexp_10 | length_of_BASE = 1
length_of_EXPONENT = 1
length_of_MODULUS = 1 | 0 ** 3 % 4 | 0 | 355 |
| modexp_11 | length_of_BASE = 1
length_of_EXPONENT = 1
length_of_MODULUS = 1 | 2 ** 0 % 4 | 0 | 373 |
| modexp_12 | length_of_BASE = 1
length_of_EXPONENT = 1
length_of_MODULUS = 1 | 2 ** 3 % 0 | 0 | 300 |
| modexp_13 | length_of_BASE = 0
length_of_EXPONENT = 1
length_of_MODULUS = 1 | 0 ** 3 % 4 | 0 | 268 |
| modexp_14 | length_of_BASE = 1
length_of_EXPONENT = 0
length_of_MODULUS = 1 | 2 ** 0 % 4 | 0 | 165 |
| modexp_15 | length_of_BASE = 1
length_of_EXPONENT = 1
length_of_MODULUS = 0 | 2 ** 3 % 0 | 0 | 213 |
| modexp_16 | length_of_BASE = 1
length_of_EXPONENT = 1
length_of_MODULUS = 32 | 2 ** 3 % 6 | 51 | 854 |
| modexp_17 | length_of_BASE = 1
length_of_EXPONENT = 1
length_of_MODULUS = 1 | 2 ** 3 % 6 | 0 | 854 |
| modexp_18 | length_of_BASE = 1
length_of_EXPONENT = 1
length_of_MODULUS = 32 | 2 ** 3 % 0 | 51 | 300 |
| modexp_19 | length_of_BASE = 1
length_of_EXPONENT = 1
length_of_MODULUS = 32 | 2 ** 3 % 0 | 51 | 300 |
| modexp_20 | length_of_BASE = 1
length_of_EXPONENT = 1
length_of_MODULUS = 32 | 2 ** 3 % 0 | 51 | 300 |
| modexp_21 | length_of_BASE = 1
length_of_EXPONENT = 2
length_of_MODULUS = 32 | 2 ** 12291 % 0 | 664 | 300 |
| modexp_22 | length_of_BASE = 1
length_of_EXPONENT = 2
length_of_MODULUS = 32 | 2 ** 12288 % 0 | 665 | 300 |
| modexp_23 | length_of_BASE = 1
length_of_EXPONENT = 2
length_of_MODULUS = 2 | 2 ** 0 % 0 | 0 | 300 |
| modexp_24 | length_of_BASE = 1
length_of_EXPONENT = 2
length_of_MODULUS = 2 | 0 ** 0 % 0 | 0 | 300 |
| modexp_25 | length_of_BASE = 3
length_of_EXPONENT = 2
length_of_MODULUS = 1 | 4097 ** 256 % 2 | 3 | 1346 |
| modexp_26 | length_of_BASE = 1
length_of_EXPONENT = 1
length_of_MODULUS = 1 | 0 ** 0 % 64 | 0 | 373 |
| modexp_27 | length_of_BASE = 1
length_of_EXPONENT = 257
length_of_MODULUS = 2 | 2 ** 3 % 6 | 360 | 2620 |
| modexp_29 | length_of_BASE = 0
length_of_EXPONENT = 0
length_of_MODULUS =  | 0 ** 0 % 0 |  | 108 |
| modexp_30 | length_of_BASE = 0
length_of_EXPONENT = 64
length_of_MODULUS = 0 | 0 ** 0 % 0 | 0 | 126 |
| modexp_31 | length_of_BASE = 33
length_of_EXPONENT = 16
length_of_MODULUS = 16 | 390298093899999943928098409885853890809480289080848908498808490890809858888590 ** 328010176336108753607932954472681594880 % 328083392909999939299399093209090192209 | 6915 | 10930 |
| modexp_32 | length_of_BASE = 5
length_of_EXPONENT = 12
length_of_MODULUS = 12 | 932908908098 ** 9999988732868956521427275408 % 9999989403808488488858939083 | 82 | 8432 |
| modexp_33 | length_of_BASE = 6
length_of_EXPONENT = 6
length_of_MODULUS = 6 | 9098908831021 ** 75950175031200 % 98390809882211 |  | 8648 |
| modexp_34 | length_of_BASE = 5
length_of_EXPONENT = 13
length_of_MODULUS = 13 | 9987654321 ** 98765432198765432198765432110 % 98765432198765432198765432111 | 811 | 8648 |
| modexp_35 | length_of_BASE = 16
length_of_EXPONENT = 18
length_of_MODULUS = 18 | 9999803280800994289908318818890988333 ** 90789237521978178359484890498490858842220 % 90789237521978178359484890498490858842221 | 2203 | 70904 |
| modexpRandomInput_0 | length_of_BASE = 227
length_of_EXPONENT = 0
length_of_MODULUS = 0 | 0 ** 0 % 0 | 1580 | 108 |

## P256VERIFY

| Testcase | Gas Consumption |
| --- | --- |
| p256verify_valid_signature_one | 2742770 |
| p256verify_valid_signature_two | 2729984 |
| p256verify_invalid_signature | 2681270 |
| p256verify_invalid_r | all |
| p256verify_invalid_s | all |
| p256verify_public_key_inf | all |
| p256verify_public_key_x_not_in_field | all |
| p256verify_public_key_y_not_in_field | all |
| p256verify_public_key_not_in_curve | all |

## secp256k1VERIFY

| Testcase | Gas Consumption |
| --- | --- |
| secp256k1verify_valid_signature_one | 2430944 |
| secp256k1verify_valid_signature_two | 2465108 |
| secp256k1verify_invalid_signature | 2456774 |
| secp256k1verify_invalid_r | all |
| secp256k1verify_invalid_s | all |
| secp256k1verify_public_key_inf | all |
| secp256k1verify_public_key_x_not_in_field | all |
| secp256k1verify_public_key_y_not_in_field | all |
| secp256k1verify_public_key_not_in_curve | all |
