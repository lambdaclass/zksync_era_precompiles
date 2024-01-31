// use zksync_web3_rs::{types::Bytes, zks_utils::ECADDG2_PRECOMPILE_ADDRESS};

mod test_utils;
use test_utils::{era_call, parse_call_result, write_ecmul_g2_gas_result};
use zksync_web3_rs::types::{Address, Bytes, H160};

pub const ECMUL_G2_PRECOMPILE_ADDRESS: Address = H160([
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x0B,
]);

const EXECUTION_REVERTED: &str =
    "(code: 3, message: execution reverted, data: Some(String(\"0x\")))";

#[tokio::test]
async fn ecmul_g2_valid_1() {

    // P * k = R
    // P = [(1536b2e79d6f2116ce8f06e33cb7997612d2514df64a41e1e5fae866b1c0d779 + 1f60381668f1c1d04cc11964dd3937c2ef0b11db4bbac18501c3ccd53ec87c6e * u),
    //      (2dfe2cb093eafecb76994ca8cabb488d3171747c4e9fe6b3afc2123e31ac9c6f + 1bddcd8f468cc2657ef23699b3bc07a16c314cd67d46c8dbb9372985c2dcc8ec * u)]
    // k = 13f483281822f1f4ba278675eae97895cd9b6b056cffa37636891b1e9bfb3e72
    // R = [(2a7e83535a70165447e7584d7142d71b0fe5313ac82e9cf408f0cbce98469863 + 2f44732f100e995e3722d8fbb88c42e20e3ce9753a086bd53b20138c436ac5e1 * u),
    //      (2e4c0e61b6e578ab82f606305ac376aa2edd4ee66d04c2cc75d6cd18888c551b + 29ab1b2867c93a6f64b59f14505dd8bb2c03df0fcf031e08a7dfe4754db78590 * u)]

    let era_response = era_call(ECMUL_G2_PRECOMPILE_ADDRESS, None, Some(Bytes::from(
            hex::decode(
                "1536b2e79d6f2116ce8f06e33cb7997612d2514df64a41e1e5fae866b1c0d779\
                1f60381668f1c1d04cc11964dd3937c2ef0b11db4bbac18501c3ccd53ec87c6e\
                2dfe2cb093eafecb76994ca8cabb488d3171747c4e9fe6b3afc2123e31ac9c6f\
                1bddcd8f468cc2657ef23699b3bc07a16c314cd67d46c8dbb9372985c2dcc8ec\
                13f483281822f1f4ba278675eae97895cd9b6b056cffa37636891b1e9bfb3e72"
                ).unwrap()))).await.unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_ecmul_g2_gas_result(gas_used);

    let result = Bytes::from(
        hex::decode(
            "2a7e83535a70165447e7584d7142d71b0fe5313ac82e9cf408f0cbce98469863\
            2f44732f100e995e3722d8fbb88c42e20e3ce9753a086bd53b20138c436ac5e1\
            2e4c0e61b6e578ab82f606305ac376aa2edd4ee66d04c2cc75d6cd18888c551b\
            29ab1b2867c93a6f64b59f14505dd8bb2c03df0fcf031e08a7dfe4754db78590"
            ).unwrap());
    assert_eq!(era_output, result)
}


#[tokio::test]
async fn ecmul_g2_valid_2() {

    // P * k = R
    // P = [(2d8a913eeee7c28aa12c81a2dbf4e8a753b7745c4910254a0404f09c4f36d867 + 0686e06cae2b68521cfe51921e30ef9291eeee283f1b3b503a1c8c8f70b86017 * u),
    //      (1b1210574a3c68090fbaa2c595adcf2d5b0dadbaba73796d4f56f0c5aba15bfa + 179448931f57e3bff2dbbc2f394afa1ba523ec54ca8aabd344095d98ed99ce90 * u)]
    // k = 2f3ee6ad9ed78b75bf31c54d279ec79494a54793bacbffc439f186ece6f08d3f
    // R = [(24215fc5a8eb0a718c7d9bfe8cd257c661ad0951abf5c9905f3cb182f9f38d71 + 0f699078f604cf68bd76a78b7e071d7af2588901489a05d110588aeb35fc1d93 * u),
    //      (0a771b9d173b01a3aac71d109933e47dda4eafa3033c89d637c89c800f4eac81 + 00eaa8f99cf0eebafddedaaedc95b8003e3255fc584a84e37664179bba510b5d * u)]

    let era_response = era_call(ECMUL_G2_PRECOMPILE_ADDRESS, None, Some(Bytes::from(
            hex::decode(
                "2d8a913eeee7c28aa12c81a2dbf4e8a753b7745c4910254a0404f09c4f36d867\
                0686e06cae2b68521cfe51921e30ef9291eeee283f1b3b503a1c8c8f70b86017\
                1b1210574a3c68090fbaa2c595adcf2d5b0dadbaba73796d4f56f0c5aba15bfa\
                179448931f57e3bff2dbbc2f394afa1ba523ec54ca8aabd344095d98ed99ce90\
                2f3ee6ad9ed78b75bf31c54d279ec79494a54793bacbffc439f186ece6f08d3f"
                ).unwrap()))).await.unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_ecmul_g2_gas_result(gas_used);

    let result = Bytes::from(
        hex::decode(
            "24215fc5a8eb0a718c7d9bfe8cd257c661ad0951abf5c9905f3cb182f9f38d71\
            0f699078f604cf68bd76a78b7e071d7af2588901489a05d110588aeb35fc1d93\
            0a771b9d173b01a3aac71d109933e47dda4eafa3033c89d637c89c800f4eac81\
            00eaa8f99cf0eebafddedaaedc95b8003e3255fc584a84e37664179bba510b5d"
            ).unwrap());
    assert_eq!(era_output, result)
}

#[tokio::test]
async fn ecmul_g2_valid_3() {

    // P * k = R
    // P = [(00096d5e6af840ba27b51f9bd326ae18c17135f6f7c5aa2ac7579840113888c0 + 04d2463026cb19a0e51a55aee7949ed5b7807056e5348c16a4656e3ab35973bc * u),
    //      (240a69ceabd8f50bc18cb07d52f40cfc4f88d493471815f5214b204bd34100a5 + 1634ac6acf25be203d8b61a06297d60d00d2143df741847cb10b278eb5fb12cc * u)]
    // k = 284812b537be5f93b6e71c951db201ab8206195a90d61b08dfcb02444beca7a7
    // R = [(175ee8ec116f531ccbbefa19d7158e76817a6ee1730e4fadca89dbee55aad9c0 + 13206e9631dd12bc3281e3eb5513d2588325e77dd3df229dd36e50e45768f952 * u),
    //      (22b5174fd5843aae5aaa432e503b425cdce1b698e7c5deba8529fd7cdfadb8d5 + 2dd49e88eb4abc2c27ba786d37c21a031c0a2c4b1ed786a6427565caabe170b0 * u)]

    let era_response = era_call(ECMUL_G2_PRECOMPILE_ADDRESS, None, Some(Bytes::from(
            hex::decode(
                "00096d5e6af840ba27b51f9bd326ae18c17135f6f7c5aa2ac7579840113888c0\
                04d2463026cb19a0e51a55aee7949ed5b7807056e5348c16a4656e3ab35973bc\
                240a69ceabd8f50bc18cb07d52f40cfc4f88d493471815f5214b204bd34100a5\
                1634ac6acf25be203d8b61a06297d60d00d2143df741847cb10b278eb5fb12cc\
                284812b537be5f93b6e71c951db201ab8206195a90d61b08dfcb02444beca7a7"
                ).unwrap()))).await.unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_ecmul_g2_gas_result(gas_used);

    let result = Bytes::from(
        hex::decode(
            "175ee8ec116f531ccbbefa19d7158e76817a6ee1730e4fadca89dbee55aad9c0\
            13206e9631dd12bc3281e3eb5513d2588325e77dd3df229dd36e50e45768f952\
            22b5174fd5843aae5aaa432e503b425cdce1b698e7c5deba8529fd7cdfadb8d5\
            2dd49e88eb4abc2c27ba786d37c21a031c0a2c4b1ed786a6427565caabe170b0"
            ).unwrap());
    assert_eq!(era_output, result)
}

#[tokio::test]
async fn ecmul_g2_p_times_one_is_p() {

    // P * 1 = P
    // P = [(1536b2e79d6f2116ce8f06e33cb7997612d2514df64a41e1e5fae866b1c0d779 + 1f60381668f1c1d04cc11964dd3937c2ef0b11db4bbac18501c3ccd53ec87c6e * u),
    //      (2dfe2cb093eafecb76994ca8cabb488d3171747c4e9fe6b3afc2123e31ac9c6f + 1bddcd8f468cc2657ef23699b3bc07a16c314cd67d46c8dbb9372985c2dcc8ec * u)]

    let era_response = era_call(ECMUL_G2_PRECOMPILE_ADDRESS, None, Some(Bytes::from(
            hex::decode(
                "1536b2e79d6f2116ce8f06e33cb7997612d2514df64a41e1e5fae866b1c0d779\
                1f60381668f1c1d04cc11964dd3937c2ef0b11db4bbac18501c3ccd53ec87c6e\
                2dfe2cb093eafecb76994ca8cabb488d3171747c4e9fe6b3afc2123e31ac9c6f\
                1bddcd8f468cc2657ef23699b3bc07a16c314cd67d46c8dbb9372985c2dcc8ec\
                0000000000000000000000000000000000000000000000000000000000000001"
                ).unwrap()))).await.unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_ecmul_g2_gas_result(gas_used);

    let result = Bytes::from(
        hex::decode(
            "1536b2e79d6f2116ce8f06e33cb7997612d2514df64a41e1e5fae866b1c0d779\
            1f60381668f1c1d04cc11964dd3937c2ef0b11db4bbac18501c3ccd53ec87c6e\
            2dfe2cb093eafecb76994ca8cabb488d3171747c4e9fe6b3afc2123e31ac9c6f\
            1bddcd8f468cc2657ef23699b3bc07a16c314cd67d46c8dbb9372985c2dcc8ec"
            ).unwrap());
    assert_eq!(era_output, result)
}

#[tokio::test]
async fn ecmul_g2_p_times_two_is_2p() {

    // P * 2 = 2P
    // P = [(1536b2e79d6f2116ce8f06e33cb7997612d2514df64a41e1e5fae866b1c0d779 + 1f60381668f1c1d04cc11964dd3937c2ef0b11db4bbac18501c3ccd53ec87c6e * u),
    //      (2dfe2cb093eafecb76994ca8cabb488d3171747c4e9fe6b3afc2123e31ac9c6f + 1bddcd8f468cc2657ef23699b3bc07a16c314cd67d46c8dbb9372985c2dcc8ec * u)]
    // 2P = [(24121a621d058041283e3f33249834ed5babd0a2bf14db0afbd369d897e76f63 + 0f8c50d38c94ea7ed7f870103f77bb6dfc223becc0e8c31933c66de54933cd7e * u),
    //       (26f5199f284136bf0fd7a5371b97fe7503bf7e1dc7215b829eb16b08a9163e64 + 1e03e473a20f412127a0d354f6e0b4ce69b2f27455c67fba65e55fbb42b0500e * u )]

    let era_response = era_call(ECMUL_G2_PRECOMPILE_ADDRESS, None, Some(Bytes::from(
            hex::decode(
                "1536b2e79d6f2116ce8f06e33cb7997612d2514df64a41e1e5fae866b1c0d779\
                1f60381668f1c1d04cc11964dd3937c2ef0b11db4bbac18501c3ccd53ec87c6e\
                2dfe2cb093eafecb76994ca8cabb488d3171747c4e9fe6b3afc2123e31ac9c6f\
                1bddcd8f468cc2657ef23699b3bc07a16c314cd67d46c8dbb9372985c2dcc8ec\
                0000000000000000000000000000000000000000000000000000000000000002"
                ).unwrap()))).await.unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_ecmul_g2_gas_result(gas_used);

    let result = Bytes::from(
        hex::decode(
            "24121a621d058041283e3f33249834ed5babd0a2bf14db0afbd369d897e76f63\
            0f8c50d38c94ea7ed7f870103f77bb6dfc223becc0e8c31933c66de54933cd7e\
            26f5199f284136bf0fd7a5371b97fe7503bf7e1dc7215b829eb16b08a9163e64\
            1e03e473a20f412127a0d354f6e0b4ce69b2f27455c67fba65e55fbb42b0500e"
            ).unwrap());
    assert_eq!(era_output, result)
}

#[tokio::test]
async fn ecmul_g2_p_times_zero_is_infinity() {

    // P * 0 = 0
    // P = [(1536b2e79d6f2116ce8f06e33cb7997612d2514df64a41e1e5fae866b1c0d779 + 1f60381668f1c1d04cc11964dd3937c2ef0b11db4bbac18501c3ccd53ec87c6e * u),
    //      (2dfe2cb093eafecb76994ca8cabb488d3171747c4e9fe6b3afc2123e31ac9c6f + 1bddcd8f468cc2657ef23699b3bc07a16c314cd67d46c8dbb9372985c2dcc8ec * u)]

    let era_response = era_call(ECMUL_G2_PRECOMPILE_ADDRESS, None, Some(Bytes::from(
            hex::decode(
                "1536b2e79d6f2116ce8f06e33cb7997612d2514df64a41e1e5fae866b1c0d779\
                1f60381668f1c1d04cc11964dd3937c2ef0b11db4bbac18501c3ccd53ec87c6e\
                2dfe2cb093eafecb76994ca8cabb488d3171747c4e9fe6b3afc2123e31ac9c6f\
                1bddcd8f468cc2657ef23699b3bc07a16c314cd67d46c8dbb9372985c2dcc8ec\
                0000000000000000000000000000000000000000000000000000000000000000"
                ).unwrap()))).await.unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_ecmul_g2_gas_result(gas_used);

    let result = Bytes::from(
        hex::decode(
            "0000000000000000000000000000000000000000000000000000000000000000\
            0000000000000000000000000000000000000000000000000000000000000000\
            0000000000000000000000000000000000000000000000000000000000000000\
            0000000000000000000000000000000000000000000000000000000000000000"
            ).unwrap());
    assert_eq!(era_output, result)
}


#[tokio::test]
async fn ecmul_g2_p_infinity_times_k_is_infinity() {

    // Inf * k = Inf
    // k = 13f483281822f1f4ba278675eae97895cd9b6b056cffa37636891b1e9bfb3e72

    let era_response = era_call(ECMUL_G2_PRECOMPILE_ADDRESS, None, Some(Bytes::from(
            hex::decode(
                "0000000000000000000000000000000000000000000000000000000000000000\
                0000000000000000000000000000000000000000000000000000000000000000\
                0000000000000000000000000000000000000000000000000000000000000000\
                0000000000000000000000000000000000000000000000000000000000000000\
                13f483281822f1f4ba278675eae97895cd9b6b056cffa37636891b1e9bfb3e72"
                ).unwrap()))).await.unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_ecmul_g2_gas_result(gas_used);

    let result = Bytes::from(
        hex::decode(
            "0000000000000000000000000000000000000000000000000000000000000000\
            0000000000000000000000000000000000000000000000000000000000000000\
            0000000000000000000000000000000000000000000000000000000000000000\
            0000000000000000000000000000000000000000000000000000000000000000"
            ).unwrap());
    assert_eq!(era_output, result)
}

#[tokio::test]
async fn ecmul_g2_p_infinity_times_0_is_infinity() {

    // Inf * 0 = 0

    let era_response = era_call(ECMUL_G2_PRECOMPILE_ADDRESS, None, Some(Bytes::from(
            hex::decode(
                "0000000000000000000000000000000000000000000000000000000000000000\
                0000000000000000000000000000000000000000000000000000000000000000\
                0000000000000000000000000000000000000000000000000000000000000000\
                0000000000000000000000000000000000000000000000000000000000000000\
                13f483281822f1f4ba278675eae97895cd9b6b056cffa37636891b1e9bfb3e72"
                ).unwrap()))).await.unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_ecmul_g2_gas_result(gas_used);

    let result = Bytes::from(
        hex::decode(
            "0000000000000000000000000000000000000000000000000000000000000000\
            0000000000000000000000000000000000000000000000000000000000000000\
            0000000000000000000000000000000000000000000000000000000000000000\
            0000000000000000000000000000000000000000000000000000000000000000"
            ).unwrap());
    assert_eq!(era_output, result)
}

#[tokio::test]
async fn ecmul_g2_invalid_p_not_in_curve() {
    let era_response = era_call(ECMUL_G2_PRECOMPILE_ADDRESS, None, Some(Bytes::from(
            hex::decode(
                "0000000000000000000000000000000000000000000000000000000000000000\
                0000000000000000000000000000000000000000000000000000000000000000\
                0000000000000000000000000000000000000000000000000000000000000000\
                0000000000000000000000000000000000000000000000000000000000000001\
                123364d138d3c357b288a1eda53008a69e8fff2234acb97555bd4832575b4440"
                ).unwrap()))).await
                .err()
                .unwrap()
                .to_string();
            
    assert_eq!(era_response, EXECUTION_REVERTED);
}

#[tokio::test]
async fn ecmul_g2_coordinates_not_in_field() {

    // This number is bigger than the field
    let over_the_field = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
    let good_field = "00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
    let scalar = "123364d138d3c357b288a1eda53008a69e8fff2234acb97555bd4832575b4440";

    for i in 0..3 {
        
        let initial_string = good_field.repeat(i);
        let mid_string = over_the_field;
        let end_string = good_field.repeat(3-i);
        let input = initial_string + mid_string + &end_string + scalar;

        let era_response = era_call(ECMUL_G2_PRECOMPILE_ADDRESS, None, Some(Bytes::from(
            hex::decode(
                input
                ).unwrap()))).await
                .err()
                .unwrap()
                .to_string();
        
        assert_eq!(era_response, EXECUTION_REVERTED);
    }    
}
