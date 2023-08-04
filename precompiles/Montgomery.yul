object "Montgomery" {
    code { }
    object "Montgomery_deployed" {
        code {
            ////////////////////////////////////////////////////////////////
            //                      CONSTANTS
            ////////////////////////////////////////////////////////////////

            function ZERO() -> zero {
                zero := 0x0
            }

            function ONE() -> one {
                one := 0x1
            }

            function THREE() -> three {
                three := 0x3
            }

            // Group order of alt_bn128, see https://eips.ethereum.org/EIPS/eip-196
            function ALT_BN128_GROUP_ORDER() -> ret {
                ret := 21888242871839275222246405745257275088696311157297823662689037894645226208583
            }

            function R() -> r_low, r_high {
                r_low := 0x0
                r_high := 0x1
            }

            // function R2() -> r {
            //       r := 13407807929942597099574024998205846127479365820592393377723561443721764030073546976801874298166903427690031858186486050853753882811946569946433649006084096
            // }

            function R2_mod_ALT_BN128_GROUP_ORDER() -> ret {
                ret := 3096616502983703923843567936837374451735540968419076528771170197431451843209
            }

            function ALT_BN128_GROUP_ORDER_INVERSE() -> ret {
                ret := 4759646384140481320982610724935209484903937857060724391493050186936685796471
            }

            // CONSOLE.LOG Caller
            // It prints 'val' in the node console and it works using the 'mem'+0x40 memory sector
            function console_log(mem, val) -> {
                let log_address := 0x000000000000000000636F6e736F6c652e6c6f67
                // load the free memory pointer
                let freeMemPointer := mload(mem)
                // store the function selector of log(uint256) in memory
                mstore(freeMemPointer, 0xf82c50f1)
                // store the first argument of log(uint256) in the next memory slot
                mstore(add(freeMemPointer, 0x20), val)
                // call the console.log contract
                if iszero(staticcall(gas(),log_address,add(freeMemPointer, 28),add(freeMemPointer, 0x40),0x00,0x00)) {
                    revert(0,0)
                }
            }

            function getHighestHalfOfMultiplication(multiplicand, multiplier) -> ret {
                ret := verbatim_2i_1o("mul_high", multiplicand, multiplier)
            }

            // https://en.wikipedia.org/wiki/Montgomery_modular_multiplication//The_REDC_algorithm
            function REDC(lowest_half_of_T, higher_half_of_T) -> S {
                let q := mul(lowest_half_of_T, ALT_BN128_GROUP_ORDER_INVERSE())
                let a := add(higher_half_of_T, getHighestHalfOfMultiplication(q, ALT_BN128_GROUP_ORDER()))

                switch or(gt(a, ALT_BN128_GROUP_ORDER()), eq(a, ALT_BN128_GROUP_ORDER()))
                case 0 {
                    S := sub(ALT_BN128_GROUP_ORDER(), a)
                }
                case 1 {
                    S := sub(a, ALT_BN128_GROUP_ORDER())
                }
            }

            // Transforming into the Montgomery form -> REDC((a mod N)(R2 mod N))
            function intoMontgomeryForm(a) -> ret {
                    let higher_half_of_a := getHighestHalfOfMultiplication(mod(a, ALT_BN128_GROUP_ORDER()), R2_mod_ALT_BN128_GROUP_ORDER())
                    let lowest_half_of_a := mul(mod(a, ALT_BN128_GROUP_ORDER()), R2_mod_ALT_BN128_GROUP_ORDER())
                    ret := REDC(lowest_half_of_a, higher_half_of_a)
            }

            // Transforming out of the Montgomery form -> REDC(a * R mod N)
            function outOfMontgomeryForm(m) -> ret {
                    let higher_half_of_m := ZERO()
                    let lowest_half_of_m := m 
                    ret := REDC(lowest_half_of_m, higher_half_of_m)
            }

            // Multipling field elements in Montgomery form -> REDC((a * R mod N)(b * R mod N))
            function montgomeryMul(multiplicand, multiplier) -> ret {
                let higher_half_of_product := getHighestHalfOfMultiplication(multiplicand, multiplier)
                let lowest_half_of_product := mul(multiplicand, multiplier)
                ret := REDC(lowest_half_of_product, higher_half_of_product)
            }

            let a := THREE()
            let a_mont := intoMontgomeryForm(a)

            // a
            console_log(0x00, a)
            // a in montgomery form
            console_log(0x40, a_mont)
            // a in montgomery form into regular form
            console_log(0x80, outOfMontgomeryForm(a_mont))

            /* Addition */
            let sum_mont := addmod(a_mont, a_mont, ALT_BN128_GROUP_ORDER())
            console_log(0xc0, add(a, a))
            // a * a in montgomery form
            console_log(0x100, sum_mont)
            // a * a in montgomery form into montgomery form
            console_log(0x140, outOfMontgomeryForm(sum_mont))

            /* Multiplication */

            let prod_mont := montgomeryMul(a_mont, a_mont)
            console_log(0x180, mul(a, a))
            // a * a in montgomery form
            console_log(0x1c0, prod_mont)
            // a * a in montgomery form into montgomery form
            console_log(0x200, outOfMontgomeryForm(prod_mont))
        }
    }
}
