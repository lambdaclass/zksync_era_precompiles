use zksync_web3_rs::types::{Address, Bytes, H160};

mod test_utils;
use test_utils::{era_call, parse_call_result, write_secp256k1verify_gas_result};

pub const SECP256K1VERIFTY_PRECOMPILE_ADDRESS: Address = H160([
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x20,
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
async fn secp256k1verify_valid_signature_one() {
    let era_response = era_call(
        SECP256K1VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("1899fa5c2e77910f63db2d279ae19dea9ec0d2f3b0c8c532c572fe27cd1bedba8c5056f413489ee720b4683ce930cad9c3b7e24a4d66b86a9aadaf1b8894bf8c18d9533e1720ec3431130907948cc742587258045569caf86880b3e3d5aa66e0b6e56e53302271f0c7917f53fe06ed6b0ee407b17df4fb31a5cafad9d1f2f4b97cc9a1235fcb1392136e67f8590d1dbad166e2706dad4fdf9535b9d98ce760a0").unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_secp256k1verify_gas_result(gas_used);
    assert_eq!(era_output, Bytes::from(RESPONSE_VALID))
}

#[tokio::test]
async fn secp256k1verify_valid_signature_two() {
    let era_response = era_call(
        SECP256K1VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("1899fa5c2e77910f63db2d279ae19dea9ec0d2f3b0c8c532c572fe27cd1bedba57e35a941054db36dd621975f9b35ceec81f3ffa9471c046115a3428edf0ee9ca1246172f0c9a1aef67be23850ae60f6a4ce2e4654648a9b1756909df4fd4e64c16895b126617f6016d64f7d1096af1b42e3a800efd2ce9b1ec2ac115faf675afa8e77dcd37cf95a1c62c106b0c18756fd944bb79bf7522efd479bde327b9105").unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_secp256k1verify_gas_result(gas_used);
    assert_eq!(era_output, Bytes::from(RESPONSE_VALID))
}

#[tokio::test]
async fn secp256k1verify_invalid_signature() {
    let era_response = era_call(
        SECP256K1VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("2899fa5c2e77910f63db2d279ae19dea9ec0d2f3b0c8c532c572fe27cd1bedba8c5056f413489ee720b4683ce930cad9c3b7e24a4d66b86a9aadaf1b8894bf8c18d9533e1720ec3431130907948cc742587258045569caf86880b3e3d5aa66e0b6e56e53302271f0c7917f53fe06ed6b0ee407b17df4fb31a5cafad9d1f2f4b97cc9a1235fcb1392136e67f8590d1dbad166e2706dad4fdf9535b9d98ce760a0").unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = parse_call_result(&era_response);
    write_secp256k1verify_gas_result(gas_used);
    assert_eq!(era_output, Bytes::from(RESPONSE_INVALID))
}

#[tokio::test]
async fn secp256k1verify_invalid_r() {
    let era_response = era_call(
        SECP256K1VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("1899fa5c2e77910f63db2d279ae19dea9ec0d2f3b0c8c532c572fe27cd1bedbaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff18d9533e1720ec3431130907948cc742587258045569caf86880b3e3d5aa66e0b6e56e53302271f0c7917f53fe06ed6b0ee407b17df4fb31a5cafad9d1f2f4b97cc9a1235fcb1392136e67f8590d1dbad166e2706dad4fdf9535b9d98ce760a0").unwrap())),
    )
    .await
    .err()
    .unwrap()
    .to_string();
    assert_eq!(era_response, EXECUTION_REVERTED)
}

#[tokio::test]
async fn secp256k1verify_invalid_s() {
    let era_response = era_call(
        SECP256K1VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("1899fa5c2e77910f63db2d279ae19dea9ec0d2f3b0c8c532c572fe27cd1bedba8c5056f413489ee720b4683ce930cad9c3b7e24a4d66b86a9aadaf1b8894bf8cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb6e56e53302271f0c7917f53fe06ed6b0ee407b17df4fb31a5cafad9d1f2f4b97cc9a1235fcb1392136e67f8590d1dbad166e2706dad4fdf9535b9d98ce760a0").unwrap())),
    )
    .await
    .err()
    .unwrap()
    .to_string();
    assert_eq!(era_response, EXECUTION_REVERTED)
}

#[tokio::test]
async fn secp256k1verify_public_key_inf() {
    let era_response = era_call(
        SECP256K1VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("1899fa5c2e77910f63db2d279ae19dea9ec0d2f3b0c8c532c572fe27cd1bedba8c5056f413489ee720b4683ce930cad9c3b7e24a4d66b86a9aadaf1b8894bf8c18d9533e1720ec3431130907948cc742587258045569caf86880b3e3d5aa66e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000").unwrap())),
    )
    .await
    .err()
    .unwrap()
    .to_string();
    assert_eq!(era_response, EXECUTION_REVERTED)
}

#[tokio::test]
async fn secp256k1verify_public_key_x_not_in_field() {
    let era_response = era_call(
        SECP256K1VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("1899fa5c2e77910f63db2d279ae19dea9ec0d2f3b0c8c532c572fe27cd1bedba57e35a941054db36dd621975f9b35ceec81f3ffa9471c046115a3428edf0ee9ca1246172f0c9a1aef67be23850ae60f6a4ce2e4654648a9b1756909df4fd4e64fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa8e77dcd37cf95a1c62c106b0c18756fd944bb79bf7522efd479bde327b9105").unwrap())),
    )
    .await
    .err()
    .unwrap()
    .to_string();
    assert_eq!(era_response, EXECUTION_REVERTED)
}

#[tokio::test]
async fn secp256k1verify_public_key_y_not_in_field() {
    let era_response = era_call(
        SECP256K1VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("1899fa5c2e77910f63db2d279ae19dea9ec0d2f3b0c8c532c572fe27cd1bedba57e35a941054db36dd621975f9b35ceec81f3ffa9471c046115a3428edf0ee9ca1246172f0c9a1aef67be23850ae60f6a4ce2e4654648a9b1756909df4fd4e64c16895b126617f6016d64f7d1096af1b42e3a800efd2ce9b1ec2ac115faf675affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff").unwrap())),
    )
    .await
    .err()
    .unwrap()
    .to_string();
    assert_eq!(era_response, EXECUTION_REVERTED)
}

#[tokio::test]
async fn secp256k1verify_public_key_not_in_curve() {
    let era_response = era_call(
        SECP256K1VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode("1899fa5c2e77910f63db2d279ae19dea9ec0d2f3b0c8c532c572fe27cd1bedba57e35a941054db36dd621975f9b35ceec81f3ffa9471c046115a3428edf0ee9ca1246172f0c9a1aef67be23850ae60f6a4ce2e4654648a9b1756909df4fd4e64c16895b126617f6016d64f7d1096af1b42e3a800efd2ce9b1ec2ac115faf675bfa8e77dcd37cf95a1c62c106b0c18756fd944bb79bf7522efd479bde327b9106").unwrap())),
    )
    .await
    .err()
    .unwrap()
    .to_string();
    assert_eq!(era_response, EXECUTION_REVERTED)
}
