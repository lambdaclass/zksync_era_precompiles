use zksync_web3_rs::{zks_provider::ZKSProvider, zks_utils::ECADD_PRECOMPILE_ADDRESS};

mod test_utils;
use test_utils::{eth_provider, era_provider};

#[tokio::test]
async fn test_valid_points_addition() {
    /* P + P = 2P */

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "1".to_string(),
            "2".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L1] P + P = {eth_response:?}");

    let era_response = ZKSProvider::call(
        &era_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "1".to_string(),
            "2".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L2] P + P = {era_response:?}");

    assert_eq!(eth_response, era_response, "P + P should result on 2P");

    /* P1 + P2 = P3 */

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "1368015179489954701390400359078579693043519447331113978918064868415326638035".to_string(),
            "9918110051302171585080402603319702774565515993150576347155970296011118125764".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L1] P1 + P2 = {eth_response:?}");

    let era_response = ZKSProvider::call(
        &era_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "1368015179489954701390400359078579693043519447331113978918064868415326638035".to_string(),
            "9918110051302171585080402603319702774565515993150576347155970296011118125764".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L2] P1 + P2 = {era_response:?}");

    assert_eq!(eth_response, era_response, "P2 + P1 should result on P3");

    /* P2 + P1 = P3 */

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1368015179489954701390400359078579693043519447331113978918064868415326638035".to_string(),
            "9918110051302171585080402603319702774565515993150576347155970296011118125764".to_string(),
            "1".to_string(),
            "2".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L1] P2 + P1 = {eth_response:?}");

    let era_response = ZKSProvider::call(
        &era_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1368015179489954701390400359078579693043519447331113978918064868415326638035".to_string(),
            "9918110051302171585080402603319702774565515993150576347155970296011118125764".to_string(),
            "1".to_string(),
            "2".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L2] P2 + P1 = {era_response:?}");

    assert_eq!(eth_response, era_response, "P2 + P1 should result on P3");
}

#[tokio::test]
async fn test_adding_infinity() {
    /* P + Infinity = Infinity */

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "0".to_string(),
            "0".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L1] P + Infinity = {eth_response:?}");

    let era_response = ZKSProvider::call(
        &era_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "0".to_string(),
            "0".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L2] P + Infinity = {era_response:?}");

    assert_eq!(eth_response, era_response, "P + Infinity should result on P");

    /* Infinity + P = Infinity */

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "0".to_string(),
            "0".to_string(),
            "1".to_string(),
            "2".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L1] Infinity + P = {eth_response:?}");

    let era_response = ZKSProvider::call(
        &era_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "0".to_string(),
            "0".to_string(),
            "1".to_string(),
            "2".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L2] Infinity + P = {era_response:?}");

    assert_eq!(eth_response, era_response, "Infinity + P should result on P");

    /* Infinity + Infinity = Infinity */

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "0".to_string(),
            "0".to_string(),
            "0".to_string(),
            "0".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L1] Infinity + Infinity = {eth_response:?}");

    let era_response = ZKSProvider::call(
        &era_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "0".to_string(),
            "0".to_string(),
            "0".to_string(),
            "0".to_string(),
        ]),
    )
    .await
    .unwrap();

    println!("[L2] Infinity + Infinity = {era_response:?}");

    assert_eq!(eth_response, era_response, "Infinity + Infinity should result on Infinity");
}

#[tokio::test]
#[ignore = "invalid points addition is handled different in L1 than in L2"]
async fn test_invalid_points_addition() {
    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "1".to_string(),
            "0".to_string(),
        ]),
    )
    .await
    .unwrap();
    let era_response = ZKSProvider::call(
        &era_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "2".to_string(),
            "1".to_string(),
            "0".to_string(),
        ]),
    )
    .await
    .unwrap();

    assert_eq!(eth_response, era_response);

    let eth_response = ZKSProvider::call(
        &eth_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "0".to_string(),
            "1".to_string(),
            "2".to_string(),
        ]),
    )
    .await
    .unwrap();
    let era_response = ZKSProvider::call(
        &era_provider(),
        ECADD_PRECOMPILE_ADDRESS,
        "",
        Some(vec![
            "1".to_string(),
            "0".to_string(),
            "1".to_string(),
            "2".to_string(),
        ]),
    )
    .await
    .unwrap();

    assert_eq!(eth_response, era_response);
}