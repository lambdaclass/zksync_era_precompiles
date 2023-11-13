# Gas Consumption

> Disclaimer: The following values are approximate because contract calls were needed to print the values.

## Verifier

| Test case | Gas used |
| --------- | -------- |
| new_verifier_succeeds  | 32320282 |


## ecAdd

The test cases are a subset of Ethereum’s [General State Tests](https://github.com/ethereum/tests/tree/develop/GeneralStateTests)

| Test case | Gas used |
| --------- | -------- |
| ecadd_0_0_0_0_21000_0  | 53973 |
| ecadd_0_0_0_0_21000_64  | 53991 |
| ecadd_0_0_0_0_25000_128  | 53991 |
| ecadd_0_0_0_0_21000_128  | 53991 |
| ecadd_0_0_0_0_25000_192  | 53991 |
| ecadd_0_0_0_0_21000_192  | 53991 |
| ecadd_0_0_0_0_21000_80  | 53991 |
| ecadd_0_0_0_0_25000_64  | 53991 |
| ecadd_0_0_1_2_21000_128  | 54465 |
| ecadd_0_0_1_2_25000_192  | 54465 |
| ecadd_0_0_1_2_25000_128  | 54465 |
| ecadd_0_0_0_0_25000_80  | 53991 |
| ecadd_0_0_1_2_21000_192  | 54465 |
| ecadd_1145_3932_2969_1336_21000_128  | 90285 |
| ecadd_1145_3932_1145_4651_25000_192  | 54573 |
| ecadd_1145_3932_2969_1336_25000_128  | 90285 |
| ecadd_1145_3932_1145_4651_21000_192  | 54573 |
| ecadd_1_2_0_0_21000_128  | 54507 |
| ecadd_1_2_0_0_21000_192  | 54507 |
| ecadd_1_2_0_0_21000_64  | 54507 |
| ecadd_1_2_0_0_25000_128  | 54507 |
| ecadd_1_2_0_0_25000_64  | 54507 |
| ecadd_1_2_1_2_25000_128  | 92469 |
| ecadd_1_2_1_2_21000_192  | 92469 |
| ecadd_1_2_0_0_25000_192  | 54507 |
| ecadd_1_2_1_2_21000_128  | 92469 |
| ecadd_1_2_1_2_25000_192  | 92469 |
| ecadd_0_0_0_0_25000_0  | 53973 |


## ecMul

The test cases are a subset of Ethereum’s [General State Tests](https://github.com/ethereum/tests/tree/develop/GeneralStateTests)

| Test case | Gas used |
| --------- | -------- |
| ecmul_0_0_0_21000_96  | 54546 |
| ecmul_0_0_0_21000_64  | 54546 |
| ecmul_0_0_0_21000_128  | 54546 |
| ecmul_0_0_0_21000_0  | 54528 |
| ecmul_0_0_0_21000_40  | 54546 |
| ecmul_0_0_0_28000_0  | 54528 |
| ecmul_0_0_0_28000_128  | 54546 |
| ecmul_0_0_0_21000_80  | 54546 |
| ecmul_0_0_0_28000_40  | 54546 |
| ecmul_0_0_1_21000_96  | 54546 |
| ecmul_0_0_0_28000_80  | 54546 |
| ecmul_0_0_0_28000_96  | 54546 |
| ecmul_0_0_1_28000_96  | 54546 |
| ecmul_0_0_0_28000_64  | 54546 |
| ecmul_0_0_1_21000_128  | 54546 |
| ecmul_0_0_1_28000_128  | 54546 |
| ecmul_0_0_2_21000_128  | 54546 |
| ecmul_0_0_2_28000_128  | 54546 |
| ecmul_0_0_340282366920938463463374607431768211456_21000_128  | 54546 |
| ecmul_0_0_2_21000_96  | 54546 |
| ecmul_0_0_2_28000_96  | 54546 |
| ecmul_0_0_340282366920938463463374607431768211456_28000_128  | 54546 |
| ecmul_0_0_340282366920938463463374607431768211456_21000_80  | 54546 |
| ecmul_0_0_340282366920938463463374607431768211456_21000_96  | 54546 |
| ecmul_0_0_340282366920938463463374607431768211456_28000_80  | 54546 |
| ecmul_0_0_340282366920938463463374607431768211456_28000_96  | 54546 |
| ecmul_0_0_5616_21000_96  | 54546 |
| ecmul_0_0_5616_21000_128  | 54546 |
| ecmul_0_0_5616_28000_128  | 54546 |
| ecmul_0_0_5617_21000_128  | 54546 |
| ecmul_0_0_5617_28000_128  | 54546 |
| ecmul_0_0_5617_21000_96  | 54546 |
| ecmul_0_0_5617_28000_96  | 54546 |
| ecmul_0_0_5616_28000_96  | 54546 |
| ecmul_0_0_9935_21000_128  | 54546 |
| ecmul_0_0_9935_28000_128  | 54546 |
| ecmul_0_0_9935_21000_96  | 54546 |
| ecmul_0_0_9935_28000_96  | 54546 |
| ecmul_0_0_9_21000_128  | 54546 |
| ecmul_0_0_9_28000_128  | 54546 |
| ecmul_0_0_9_21000_96  | 54546 |
| ecmul_0_0_9_28000_96  | 54546 |
| ecmul_1_2_0_21000_128  | 54996 |
| ecmul_1_2_0_21000_64  | 54996 |
| ecmul_1_2_0_21000_80  | 54996 |
| ecmul_1_2_0_28000_128  | 54996 |
| ecmul_1_2_0_28000_80  | 54996 |
| ecmul_1_2_1_21000_128  | 55008 |
| ecmul_1_2_1_21000_96  | 55008 |
| ecmul_1_2_0_28000_64  | 54996 |
| ecmul_1_2_0_28000_96  | 54996 |
| ecmul_1_2_1_28000_128  | 55008 |
| ecmul_1_2_1_28000_96  | 55008 |
| ecmul_1_2_0_21000_96  | 54996 |
| ecmul_1_2_2_21000_128  | 93108 |
| ecmul_1_2_2_28000_128  | 93108 |
| ecmul_1_2_2_21000_96  | 93108 |
| ecmul_1_2_2_28000_96  | 93108 |
| ecmul_1_2_340282366920938463463374607431768211456_21000_96  | 239382 |
| ecmul_1_2_340282366920938463463374607431768211456_28000_128  | 239382 |
| ecmul_1_2_340282366920938463463374607431768211456_21000_80  | 239382 |
| ecmul_1_2_340282366920938463463374607431768211456_28000_80  | 239382 |
| ecmul_1_2_340282366920938463463374607431768211456_28000_96  | 239382 |
| ecmul_1_2_5616_21000_128  | 527424 |
| ecmul_1_2_5616_21000_96  | 527424 |
| ecmul_1_2_340282366920938463463374607431768211456_21000_128  | 239382 |
| ecmul_1_2_5616_28000_128  | 527424 |
| ecmul_1_2_5617_21000_96  | 493410 |
| ecmul_1_2_5617_28000_96  | 493410 |
| ecmul_1_2_5617_21000_128  | 493410 |
| ecmul_1_2_616_28000_96  | 527424 |
| ecmul_1_2_5617_28000_128  | 493410 |
| ecmul_1_2_9935_21000_128  | 753546 |
| ecmul_1_2_9935_21000_96  | 753546 |
| ecmul_1_2_9_21000_128  | 96390 |
| ecmul_1_2_9935_28000_128  | 753546 |
| ecmul_1_2_9935_28000_96  | 753546 |
| ecmul_1_2_9_21000_96  | 96390 |
| ecmul_1_2_9_28000_128  | 96390 |
| ecmul_1_2_9_28000_96  | 96390 |
| ecmul_7827_6598_0_21000_128  | 54996 |
| ecmul_7827_6598_0_28000_64  | 54996 |
| ecmul_7827_6598_0_21000_64  | 54996 |
| ecmul_7827_6598_0_28000_128  | 54996 |
| ecmul_7827_6598_0_21000_96  | 54996 |
| ecmul_7827_6598_0_21000_80  | 54996 |
| ecmul_7827_6598_0_28000_96  | 54996 |
| ecmul_7827_6598_1456_28000_128  | 239340 |
| ecmul_7827_6598_1456_21000_80  | 239340 |
| ecmul_7827_6598_1456_21000_96  | 239340 |
| ecmul_7827_6598_0_28000_80  | 54996 |
| ecmul_7827_6598_1456_21000_128  | 239340 |
| ecmul_7827_6598_1456_28000_80  | 239340 |
| ecmul_7827_6598_1456_28000_96  | 239340 |
| ecmul_7827_6598_1_21000_128  | 55008 |
| ecmul_7827_6598_1_28000_128  | 55008 |
| ecmul_7827_6598_1_21000_96  | 55008 |
| ecmul_7827_6598_1_28000_96  | 55008 |
| ecmul_7827_6598_2_21000_128  | 90840 |
| ecmul_7827_6598_2_21000_96  | 90840 |
| ecmul_7827_6598_5616_21000_128  | 526626 |
| ecmul_7827_6598_2_28000_128  | 90840 |
| ecmul_7827_6598_2_28000_96  | 90840 |
| ecmul_7827_6598_5616_21000_96  | 526626 |
| ecmul_7827_6598_5616_28000_128  | 526626 |
| ecmul_7827_6598_5616_28000_96  | 526626 |
| ecmul_7827_6598_5617_28000_128  | 493410 |
| ecmul_7827_6598_5617_21000_128  | 493410 |
| ecmul_7827_6598_5617_21000_96  | 493410 |
| ecmul_7827_6598_5617_28000_96  | 493410 |
| ecmul_7827_6598_9935_21000_128  | 754734 |
| ecmul_7827_6598_9935_21000_96  | 754734 |
| ecmul_7827_6598_9935_28000_96  | 754734 |
| ecmul_7827_6598_9935_28000_128  | 754734 |
| ecmul_7827_6598_9_21000_96  | 96822 |
| ecmul_7827_6598_9_21000_128  | 96822 |
| ecmul_7827_6598_9_28000_128  | 96822 |
| ecmul_7827_6598_9_28000_96  | 96822 |

<aside>
💡 *The second version of the optimization includes the usage of projective coordinates

</aside>

<aside>
💡 *The third version of the optimization includes the usage of wGLV multiplication (This is not a final version and is included in a development branch)

</aside>

## ecPairing

The test cases are a subset of Ethereum’s [General State Tests](https://github.com/ethereum/tests/tree/develop/GeneralStateTests)

| Test case | Gas used |
| --------- | -------- |
| ecpairing_one_point_fail  | 6675152 |
| ecpairing_empty_data_insufficient_gas  | 71566 |
| ecpairing_one_point_with_g1_zero  | 1559074 |
| ecpairing_empty_data  | 71566 |
| ecpairing_one_point_insufficient_gas  | 6675152 |
| ecpairing_one_point_with_g2_zero  | 72880 |
| ecpairing_three_point_match_1  | 13277910 |
| ecpairing_three_point_fail_1  | 19880182 |
| ecpairing_two_point_match_3  | 13277166 |
| ecpairing_two_point_fail_2  | 13277832 |
| ecpairing_two_point_fail_1  | 13278594 |
| ecpairing_two_point_match_1  | 13278732 |
| ecpairing_two_point_match_2  | 13278732 |
| ecpairing_two_points_with_one_g2_zero  | 6676184 |
| ecpairing_two_point_match_4  | 13276878 |
| ecpairing_two_point_oog  | 13278732 |
| ecpairing_two_point_match_5  | 1560106 |

## modexp

🏗️

The test cases are a subset of Ethereum’s [General State Tests](https://github.com/ethereum/tests/tree/develop/GeneralStateTests)

The L1 gas cost is calculated using the function provided in the [EIP-198](https://eips.ethereum.org/EIPS/eip-198).

| Test case | Gas used |
| --------- | -------- |
| modexp_one_limb_0_1_0  | 43707 |
| modexp_one_limb_1_1_0  | 43719 |
| modexp_one_limb_0_0_1  | 43707 |
| modexp_one_limb_1_1_1  | 43719 |
| modexp_one_limb_1_0_1  | 43719 |
| modexp_one_limb_0_1_1  | 43707 |
| modexp_one_limb_0_0_0  | 43707 |
| modexp_one_limb_1_0_0  | 43719 |
| modexp_one_limb_2_2_1  | 43719 |
| modexp_one_limb_2_2_2  | 44187 |
| modexp_one_limb_1_2_1  | 43719 |
| modexp_10  | 44504 |
| modexp_0  | 60581302 |
| modexp_12  | 44105 |
| modexp_14  | 44342 |
| modexp_15  | 43656 |
| modexp_16  | 573657 |
| modexp_11  | 44415 |
| modexp_1  | 44218 |
| modexp_13  | 44316 |
| modexp_18  | 44166 |
| modexp_19  | 44166 |
| modexp_17  | 573596 |
| modexp_23  | 44166 |
| modexp_20  | 44166 |
| modexp_21  | 44166 |
| modexp_22  | 44166 |
| modexp_25  | 1186170 |
| modexp_24  | 44093 |
| modexp_28  | 43583 |
| modexp_26  | 44415 |
| modexp_27  | 3806949 |
| modexp_3  | 2263287 |
| modexp_29  | 43403 |
| modexp_30  | 43403 |
| modexp_32  | 10801229 |
| modexp_33  | 6076467 |
| modexp_34  | 10859461 |
| modexp_31  | 19715945 |
| modexp_7  | 44402 |
| modexp_35  | 33306107 |
| modexp_4  | 2263287 |
| modexp_36  | 43583 |
| modexp_5  | 44116 |
| modexp_6  | 44329 |
| modexp_9  | 43656 |
| modexp_8  | 44116 |
| modexp_edge_cases_1  | 43385 |
| modexp_random_input_0  | 43656 |
| modexp_random_input_1  | 43656 |
| modexp_edge_cases_5  | 3722021 |
| modexp_edge_cases_2  | 46201 |
| modexp_edge_cases_4  | 44105 |
| modexp_edge_cases_3  | 46128 |
| modexp_tests_0  | 43403 |
| modexp_tests_10  | 91673 |
| modexp_tests_1  | 44032 |
| modexp_tests_103  | 44093 |
| modexp_tests_102  | 44032 |
| modexp_tests_104  | 43583 |
| modexp_tests_101  | 43583 |
| modexp_tests_106  | 44093 |
| modexp_tests_105  | 44032 |
| modexp_tests_109  | 44093 |
| modexp_tests_108  | 44032 |
| modexp_tests_107  | 43583 |
| modexp_tests_111  | 44032 |
| modexp_tests_11  | 12919255 |
| modexp_tests_110  | 43583 |
| modexp_tests_112  | 44093 |
| modexp_tests_115  | 183329 |
| modexp_tests_114  | 531464 |
| modexp_tests_116  | 496939 |
| modexp_tests_118  | 70844 |
| modexp_tests_117  | 496939 |
| modexp_tests_119  | 311436 |
| modexp_tests_122  | 496939 |
| modexp_tests_113  | 45008 |
| modexp_tests_120  | 43583 |
| modexp_tests_121  | 44032 |
| modexp_tests_123  | 44947 |
| modexp_tests_126  | 568856 |
| modexp_tests_125  | 719294 |
| modexp_tests_124  | 44947 |
| modexp_tests_17  | 43403 |
| modexp_tests_18  | 44032 |
| modexp_tests_23  | 44043 |
| modexp_tests_2  | 44093 |
| modexp_tests_22  | 44093 |
| modexp_tests_19  | 44093 |
| modexp_tests_20  | 44093 |
| modexp_tests_21  | 44093 |
| modexp_tests_24  | 44346 |
| modexp_tests_25  | 45008 |
| modexp_tests_27  | 91673 |
| modexp_tests_3  | 44093 |
| modexp_tests_26  | 44940 |
| modexp_tests_34  | 43403 |
| modexp_tests_35  | 44032 |
| modexp_tests_28  | 12919255 |
| modexp_tests_40  | 44093 |
| modexp_tests_37  | 44093 |
| modexp_tests_42  | 44346 |
| modexp_tests_41  | 44043 |
| modexp_tests_4  | 44093 |
| modexp_tests_38  | 44093 |
| modexp_tests_39  | 44093 |
| modexp_tests_36  | 44093 |
| modexp_tests_44  | 44940 |
| modexp_tests_43  | 45008 |
| modexp_tests_45  | 91673 |
| modexp_tests_5  | 44093 |
| modexp_tests_46  | 12919255 |
| modexp_tests_56  | 44043 |
| modexp_tests_52  | 44093 |
| modexp_tests_53  | 44093 |
| modexp_tests_54  | 44093 |
| modexp_tests_58  | 45008 |
| modexp_tests_60  | 91673 |
| modexp_tests_6  | 44043 |
| modexp_tests_59  | 44940 |
| modexp_tests_57  | 44346 |
| modexp_tests_68  | 44032 |
| modexp_tests_67  | 43583 |
| modexp_tests_7  | 44346 |
| modexp_tests_69  | 44093 |
| modexp_tests_61  | 12919255 |
| modexp_tests_70  | 44093 |
| modexp_tests_76  | 44940 |
| modexp_tests_74  | 44346 |
| modexp_tests_75  | 45008 |
| modexp_tests_73  | 44043 |
| modexp_tests_77  | 91673 |
| modexp_tests_72  | 44093 |
| modexp_tests_8  | 45008 |
| modexp_tests_71  | 44093 |
| modexp_tests_85  | 44032 |
| modexp_tests_84  | 43583 |
| modexp_tests_86  | 44093 |
| modexp_tests_78  | 12919255 |
| modexp_tests_88  | 44093 |
| modexp_tests_91  | 44346 |
| modexp_tests_89  | 44093 |
| modexp_tests_87  | 44093 |
| modexp_tests_9  | 44940 |
| modexp_tests_90  | 44043 |
| modexp_tests_92  | 45008 |
| modexp_tests_93  | 44940 |
| modexp_tests_94  | 91673 |
| modexp_tests_95  | 12919255 |

## P256VERIFY

| Testcase | Unoptimized | Optimized | Compiled with Os |
| --- | --- | --- | --- |
| p256verify_valid_signature_one | 2742770 | 1686801 | 1686801 |
| p256verify_valid_signature_two | 2729984 | 1684749 | 1684749 |
| p256verify_invalid_signature | 2681270 | 1677819 | 1677819 |
| p256verify_invalid_r | all | all | all |
| p256verify_invalid_s | all | all | all |
| p256verify_public_key_inf | all | all | all |
| p256verify_public_key_x_not_in_field | all | all | all |
| p256verify_public_key_y_not_in_field | all | all | all |
| p256verify_public_key_not_in_curve | all | all | all |

## secp256k1VERIFY

| Testcase | Unoptimized | Optimized | Compiled with Os |
| --- | --- | --- | --- |
| secp256k1verify_valid_signature_one | 2430944 | 1552429 | 1552429 |
| secp256k1verify_valid_signature_two | 2465108 | 1575361 | 1575361 |
| secp256k1verify_invalid_signature | 2456774 | 1574803 | 1574803 |
| secp256k1verify_invalid_r | all | all | all |
| secp256k1verify_invalid_s | all | all | all |
| secp256k1verify_public_key_inf | all | all | all |
| secp256k1verify_public_key_x_not_in_field | all | all | all |
| secp256k1verify_public_key_y_not_in_field | all | all | all |
| secp256k1verify_public_key_not_in_curve | all | all | all |
