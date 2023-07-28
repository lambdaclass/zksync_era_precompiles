use zksync_web3_rs::{zks_provider::ZKSProvider, zks_utils::ECMUL_PRECOMPILE_ADDRESS};

mod test_utils;
use test_utils::{eth_provider, era_provider};

#[tokio::test]
async fn test_valid_point_scalar_multiplication() {
    /* P * 0 = Infinity */

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "0".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L1] P * 0 = {eth_response:?}");

    let era_response = ZKSProvider::call(
        &era_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "0".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L2] P * 0 = {era_response:?}");

    assert_eq!(eth_response, era_response, "P * 0 should result on Infinity");

    /* P * 1 = P */

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "1".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L1] P * 1 = {eth_response:?}");

    let era_response = ZKSProvider::call(
        &era_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "1".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L2] P * 1 = {era_response:?}");

    assert_eq!(eth_response, era_response, "P * 1 should result on P");

    /* P * 2 = 2P */

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "2".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L1] P * 2 = {era_response:?}");

    let era_response = ZKSProvider::call(
        &era_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "2".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L2] P * 2 = {era_response:?}");

    assert_eq!(eth_response, era_response, "P * 2 should result on 2P");

    /* P * 3 = 3P */

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "3".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L1] P * 3 = {eth_response:?}");

    let era_response = ZKSProvider::call(
        &era_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "3".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L2] P * 3 = {era_response:?}");

    assert_eq!(eth_response, era_response, "P * 3 should result on 3P");
}

#[tokio::test]
async fn test_infinity_scalar_multiplication() {
    /* P * 0 = Infinity */

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "0".to_string(),
            "0".to_string(),
            "0".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L1] P * 0 = {eth_response:?}");

    let era_response = ZKSProvider::call(
        &era_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "0".to_string(),
            "0".to_string(),
            "0".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L2] P * 0 = {era_response:?}");

    assert_eq!(eth_response, era_response, "P * 0 should result on Infinity");

    /* P * 1 = P */

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "0".to_string(),
            "0".to_string(),
            "1".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L1] P * 1 = {eth_response:?}");

    let era_response = ZKSProvider::call(
        &era_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "0".to_string(),
            "0".to_string(),
            "1".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L2] P * 1 = {era_response:?}");

    assert_eq!(eth_response, era_response, "P * 1 should result on P");

    /* P * 2 = 2P */

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "0".to_string(),
            "0".to_string(),
            "2".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L1] P * 2 = {era_response:?}");

    let era_response = ZKSProvider::call(
        &era_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "0".to_string(),
            "0".to_string(),
            "2".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L2] P * 2 = {era_response:?}");

    assert_eq!(eth_response, era_response, "P * 2 should result on 2P");

    /* P * 3 = 3P */

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "0".to_string(),
            "0".to_string(),
            "3".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L1] P * 3 = {eth_response:?}");

    let era_response = ZKSProvider::call(
        &era_provider(),
        ECMUL_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "0".to_string(),
            "0".to_string(),
            "3".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L2] P * 3 = {era_response:?}");

    assert_eq!(eth_response, era_response, "P * 3 should result on 3P");
}
