use zksync_web3_rs::{types::Bytes, zks_utils::P256VERIFTY_PRECOMPILE_ADDRESS};

mod test_utils;
use test_utils::era_call;

const RESPONSE_VALID: [u8; 32] = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
];
const RESPONSE_INVALID: [u8; 32] = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];
const RESPONSE_ERROR: [u8; 1] = [0];

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
    assert_eq!(era_response, Bytes::from(RESPONSE_VALID))
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
    assert_eq!(era_response, Bytes::from(RESPONSE_VALID))
}

#[tokio::test]
async fn p256verify_invalid_signature() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("4ad83880e16658d7521d4e878521defaf6b43dec1dbd69e514c09ab8f1f2ffe255affc6e5faba2ece4d686fd0ca1ed497325bcc2557b4186a54c62d244e692b5871c518be8c56e7f5c901933fdab317efafc588b3e04d19d9a27b29aad8d9e690dca12ea554ca09172dcba021d5965cdf3510180776207c73ade33b75e964bfeb48e217c2059c99a9a36a0297caaaff294b4dc080c5fc78f6af3bab3643c70c4").unwrap())),
    )
    .await
    .unwrap();
    assert_eq!(era_response, Bytes::from(RESPONSE_INVALID))
}

#[tokio::test]
async fn p256verify_invalid_r() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("5ad83880e16658d7521d4e878521defaf6b43dec1dbd69e514c09ab8f1f2ffe2FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632552a88a96ec0a98f29280ddffa35d63fb815c1d1d9c674838f01c4e49371e382983131c7301e8ac9e75cc8008b27e136e452a4e5b6112eae1296be30a0fa7274d5b9f5dde779183b71d1e50ac1cbcdbc52b62807ceb829000ab2986761e92f852e3").unwrap())),
    )
    .await
    .unwrap();
    assert_eq!(era_response, Bytes::from(RESPONSE_ERROR))
}

#[tokio::test]
async fn p256verify_invalid_s() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("5ad83880e16658d7521d4e878521defaf6b43dec1dbd69e514c09ab8f1f2ffe255affc6e5faba2ece4d686fd0ca1ed497325bcc2557b4186a54c62d244e692b5FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC6325520dca12ea554ca09172dcba021d5965cdf3510180776207c73ade33b75e964bfeb48e217c2059c99a9a36a0297caaaff294b4dc080c5fc78f6af3bab3643c70c4").unwrap())),
    )
    .await
    .unwrap();
    assert_eq!(era_response, Bytes::from(RESPONSE_ERROR))
}

#[tokio::test]
async fn p256verify_public_key_inf() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("93973e2948748003bc6c947d56a47411ea1c812b358be9d0189e2bd0a0b9d11eb03ae0c6a0e3e3ff4af4d16ee034277d34c6a8aa63c502d99b1d162961d07d59114fc42e88471db9de64d0ce23e37800a3b07af311d55119adcc82594b7492bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000").unwrap())),
    )
    .await
    .unwrap();
    assert_eq!(era_response, Bytes::from(RESPONSE_ERROR))
}

#[tokio::test]
async fn p256verify_public_key_x_not_in_field() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("93973e2948748003bc6c947d56a47411ea1c812b358be9d0189e2bd0a0b9d11eb03ae0c6a0e3e3ff4af4d16ee034277d34c6a8aa63c502d99b1d162961d07d59114fc42e88471db9de64d0ce23e37800a3b07af311d55119adcc82594b7492bbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb6a99bc96565cfdfa61439c441260232c6430726192fbb1cedc36f41570659f2").unwrap())),
    )
    .await
    .unwrap();
    assert_eq!(era_response, Bytes::from(RESPONSE_ERROR))
}

#[tokio::test]
async fn p256verify_public_key_y_not_in_field() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("93973e2948748003bc6c947d56a47411ea1c812b358be9d0189e2bd0a0b9d11eb03ae0c6a0e3e3ff4af4d16ee034277d34c6a8aa63c502d99b1d162961d07d59114fc42e88471db9de64d0ce23e37800a3b07af311d55119adcc82594b7492bb3caf1e7f618f833b6364862c701c6a1ce93fbeef210ef53f97619a8e0ad5c7b1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff").unwrap())),
    )
    .await
    .unwrap();
    assert_eq!(era_response, Bytes::from(RESPONSE_ERROR))
}

#[tokio::test]
async fn p256verify_public_key_not_in_curve() {
    let era_response = era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("5ad83880e16658d7521d4e878521defaf6b43dec1dbd69e514c09ab8f1f2ffe255affc6e5faba2ece4d686fd0ca1ed497325bcc2557b4186a54c62d244e692b5871c518be8c56e7f5c901933fdab317efafc588b3e04d19d9a27b29aad8d9e690dca12ea554ca09172dcba021d5965cdf3510180776207c73ade33b75e964bffb48e217c2059c99a9a36a0297caaaff294b4dc080c5fc78f6af3bab3643c70c5").unwrap())),
    )
    .await
    .unwrap();
    assert_eq!(era_response, Bytes::from(RESPONSE_ERROR))
}
