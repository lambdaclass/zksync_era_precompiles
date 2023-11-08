use zksync_web3_rs::types::{Address, Bytes, H160};
mod test_utils;
use test_utils::{era_call, parse_call_result, write_p256verify_gas_result};

pub const P256VERIFTY_PRECOMPILE_ADDRESS: Address = H160([
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x19,
]);

const RESPONSE_VALID: [u8; 32] = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
];
const RESPONSE_INVALID: [u8; 32] = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];
const EXECUTION_REVERTED: &str =
    "(code: 3, message: execution reverted, data: Some(String(\"0x\")))";

// Puts the given data into the P256VERIFTY precompile
#[tokio::test]
async fn p256verify_valid_signature_one() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("93973e2948748003bc6c947d56a47411ea1c812b358be9d0189e2bd0a0b9d11eb03ae0c6a0e3e3ff4af4d16ee034277d34c6a8aa63c502d99b1d162961d07d59114fc42e88471db9de64d0ce23e37800a3b07af311d55119adcc82594b7492bb3caf1e7f618f833b6364862c701c6a1ce93fbeef210ef53f97619a8e0ad5c7b1b6a99bc96565cfdfa61439c441260232c6430726192fbb1cedc36f41570659f2").unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_p256verify_gas_result(gas_used);
    assert_eq!(era_output, Bytes::from(RESPONSE_VALID))
}

#[tokio::test]
async fn p256verify_valid_signature_two() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("5ad83880e16658d7521d4e878521defaf6b43dec1dbd69e514c09ab8f1f2ffe255affc6e5faba2ece4d686fd0ca1ed497325bcc2557b4186a54c62d244e692b5871c518be8c56e7f5c901933fdab317efafc588b3e04d19d9a27b29aad8d9e690dca12ea554ca09172dcba021d5965cdf3510180776207c73ade33b75e964bfeb48e217c2059c99a9a36a0297caaaff294b4dc080c5fc78f6af3bab3643c70c4").unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_p256verify_gas_result(gas_used);
    assert_eq!(era_output, Bytes::from(RESPONSE_VALID))
}

#[tokio::test]
async fn p256verify_invalid_signature_one() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("4ad83880e16658d7521d4e878521defaf6b43dec1dbd69e514c09ab8f1f2ffe255affc6e5faba2ece4d686fd0ca1ed497325bcc2557b4186a54c62d244e692b5871c518be8c56e7f5c901933fdab317efafc588b3e04d19d9a27b29aad8d9e690dca12ea554ca09172dcba021d5965cdf3510180776207c73ade33b75e964bfeb48e217c2059c99a9a36a0297caaaff294b4dc080c5fc78f6af3bab3643c70c4").unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_p256verify_gas_result(gas_used);
    assert_eq!(era_output, Bytes::from(RESPONSE_INVALID))
}

#[tokio::test]
async fn p256verify_invalid_r() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("5ad83880e16658d7521d4e878521defaf6b43dec1dbd69e514c09ab8f1f2ffe2FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632552a88a96ec0a98f29280ddffa35d63fb815c1d1d9c674838f01c4e49371e382983131c7301e8ac9e75cc8008b27e136e452a4e5b6112eae1296be30a0fa7274d5b9f5dde779183b71d1e50ac1cbcdbc52b62807ceb829000ab2986761e92f852e3").unwrap())),
    )
    .await
    .err()
    .unwrap()
    .to_string();
    assert_eq!(era_response, EXECUTION_REVERTED)
}

#[tokio::test]
async fn p256verify_invalid_s() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("5ad83880e16658d7521d4e878521defaf6b43dec1dbd69e514c09ab8f1f2ffe255affc6e5faba2ece4d686fd0ca1ed497325bcc2557b4186a54c62d244e692b5FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC6325520dca12ea554ca09172dcba021d5965cdf3510180776207c73ade33b75e964bfeb48e217c2059c99a9a36a0297caaaff294b4dc080c5fc78f6af3bab3643c70c4").unwrap())),
    )
    .await
    .err()
    .unwrap()
    .to_string();

    assert_eq!(era_response, EXECUTION_REVERTED)
}

#[tokio::test]
async fn p256verify_public_key_inf() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("93973e2948748003bc6c947d56a47411ea1c812b358be9d0189e2bd0a0b9d11eb03ae0c6a0e3e3ff4af4d16ee034277d34c6a8aa63c502d99b1d162961d07d59114fc42e88471db9de64d0ce23e37800a3b07af311d55119adcc82594b7492bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000").unwrap())),
    )
    .await
    .err()
    .unwrap()
    .to_string();

    assert_eq!(era_response, EXECUTION_REVERTED)
}

#[tokio::test]
async fn p256verify_public_key_x_not_in_field() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("93973e2948748003bc6c947d56a47411ea1c812b358be9d0189e2bd0a0b9d11eb03ae0c6a0e3e3ff4af4d16ee034277d34c6a8aa63c502d99b1d162961d07d59114fc42e88471db9de64d0ce23e37800a3b07af311d55119adcc82594b7492bbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb6a99bc96565cfdfa61439c441260232c6430726192fbb1cedc36f41570659f2").unwrap())),
    )
    .await
    .err()
    .unwrap()
    .to_string();

    assert_eq!(era_response, EXECUTION_REVERTED)
}

#[tokio::test]
async fn p256verify_public_key_y_not_in_field() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("93973e2948748003bc6c947d56a47411ea1c812b358be9d0189e2bd0a0b9d11eb03ae0c6a0e3e3ff4af4d16ee034277d34c6a8aa63c502d99b1d162961d07d59114fc42e88471db9de64d0ce23e37800a3b07af311d55119adcc82594b7492bb3caf1e7f618f833b6364862c701c6a1ce93fbeef210ef53f97619a8e0ad5c7b1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff").unwrap())),
    )
    .await
    .err()
    .unwrap()
    .to_string();

    assert_eq!(era_response, EXECUTION_REVERTED)
}

#[tokio::test]
async fn p256verify_public_key_not_in_curve() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("5ad83880e16658d7521d4e878521defaf6b43dec1dbd69e514c09ab8f1f2ffe255affc6e5faba2ece4d686fd0ca1ed497325bcc2557b4186a54c62d244e692b5871c518be8c56e7f5c901933fdab317efafc588b3e04d19d9a27b29aad8d9e690dca12ea554ca09172dcba021d5965cdf3510180776207c73ade33b75e964bffb48e217c2059c99a9a36a0297caaaff294b4dc080c5fc78f6af3bab3643c70c5").unwrap())),
    )
    .await
    .err()
    .unwrap()
    .to_string();

    assert_eq!(era_response, EXECUTION_REVERTED)
}

#[tokio::test]
async fn p256verify_invalid_signature_two() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("5ad83880e16658d7521d4e878521defaf6b43dec1dbd69e514c09ab8f1f2ffe25ad83880e16658d7521d4e878521defaf6b43dec1dbd69e514c09ab8f1f2ffe2871c518be8c56e7f5c901933fdab317efafc588b3e04d19d9a27b29aad8d9e696b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296b01cbd1c01e58065711814b583f061e9d431cca994cea1313449bf97c840ae0a").unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_p256verify_gas_result(gas_used);
    assert_eq!(era_output, Bytes::from(RESPONSE_INVALID))
}

#[tokio::test]
async fn p256verify_hash_edge_case_valid_1() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("00000000000000000000000000000000000000000000000000000000000000018c47ad0afe2e980cc144632bdc1d442c34fd234661f9cb983e66a59abc1eed05844c7bf016cf7cb4ae740fac63cc8ca08e6db74890d94db8954c52fd77bf040c6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2964fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5").unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_p256verify_gas_result(gas_used);
    assert_eq!(era_output, Bytes::from(RESPONSE_VALID))
}

#[tokio::test]
async fn p256verify_hash_edge_case_valid_2() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("00000000000000000000000000000000000000000000000000000000000000016b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2966b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2976b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2964fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5").unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_p256verify_gas_result(gas_used);
    assert_eq!(era_output, Bytes::from(RESPONSE_VALID))
}

#[tokio::test]
async fn p256verify_hash_edge_case_valid_3() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("00000000000000000000000000000000000000000000000000000000000000006b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2966b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2966b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2964fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5").unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_p256verify_gas_result(gas_used);
    assert_eq!(era_output, Bytes::from(RESPONSE_VALID))
}

#[tokio::test]
async fn p256verify_hash_edge_case_valid_4() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2966b17d1f3e12c4246f8bce6e563a440f2ba1c82d386d3951c00e76e82dc359d446b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2964fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5").unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_p256verify_gas_result(gas_used);
    assert_eq!(era_output, Bytes::from(RESPONSE_VALID))
}

#[tokio::test]
async fn p256verify_hash_edge_case_valid_5() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("ffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc6325516b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2966b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2966b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2964fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5").unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_p256verify_gas_result(gas_used);
    assert_eq!(era_output, Bytes::from(RESPONSE_VALID))
}

#[tokio::test]
async fn p256verify_hash_edge_case_valid_6() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("ffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc6325506b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2966b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2956b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2964fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5").unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_p256verify_gas_result(gas_used);
    assert_eq!(era_output, Bytes::from(RESPONSE_VALID))
}
