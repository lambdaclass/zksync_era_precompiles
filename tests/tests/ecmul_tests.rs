use zksync_web3_rs::zks_utils::ECMUL_PRECOMPILE_ADDRESS;

mod test_utils;
use test_utils::{eth_call, era_call};

// Puts the point (1, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_0_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
}

// Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_5616_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_0_28000_64() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
}

// Puts the point (1, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_5616_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
}

// Puts the point (1, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_5617_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
}

// Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_5616_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_0_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
}

// Puts the point (1, 3) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_1_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "1"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "1"]).await.is_err());
}

// Puts the point (1, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_5616_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_5616_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 3) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_9_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "9"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "9"]).await.is_err());
}

// Puts the point (1, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_5617_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
}

// Puts the point (1, 2) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_340282366920938463463374607431768211456_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 3) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_2_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "2"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "2"]).await.is_err());
}

// Puts the point (1, 3) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_1_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "1"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "1"]).await.is_err());
}

// Puts the point (1, 2) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_9935_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_5617_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 2) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_340282366920938463463374607431768211456_21000_80() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 2) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_2_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "2"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 3) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_9_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "9"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "9"]).await.is_err());
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_1456_21000_80() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_0_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_1456_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_0_28000_80() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_5617_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
}

// Puts the point (1, 3) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_9_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "9"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "9"]).await.is_err());
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_9935_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_5617_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 3) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_1_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "1"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "1"]).await.is_err());
}

// Puts the point (1, 3) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_9935_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
}

// Puts the point (1, 3) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_9935_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_0_28000_64() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 2) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_9935_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 3) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_9935_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
}

// Puts the point (1, 2) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_9935_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_1_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "1"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "1"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 2) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_9_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "9"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "9"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_5617_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 3) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_340282366920938463463374607431768211456_28000_80() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "340282366920938463463374607431768211456"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "340282366920938463463374607431768211456"]).await.is_err());
}

// Puts the point (1, 3) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_2_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "2"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "2"]).await.is_err());
}

// Puts the point (1, 3) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_340282366920938463463374607431768211456_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "340282366920938463463374607431768211456"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "340282366920938463463374607431768211456"]).await.is_err());
}

// Puts the point (1, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_5616_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_2_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "2"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 2) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_9_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "9"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "9"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_0_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
}

// Puts the point (1, 3) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_2_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "2"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "2"]).await.is_err());
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_5617_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_0_28000_80() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_9_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "9"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "9"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 2) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_9_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "9"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "9"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_5617_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
}

// Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_5616_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_0_21000_64() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_5616_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 3) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_1_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "1"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "1"]).await.is_err());
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_2_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "2"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 2) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_340282366920938463463374607431768211456_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_9935_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 2) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_340282366920938463463374607431768211456_28000_80() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 2) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_9935_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 3) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_2_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "2"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "2"]).await.is_err());
}

// Puts the point (1, 2) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_340282366920938463463374607431768211456_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 2) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_340282366920938463463374607431768211456_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_2_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "2"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_0_21000_80() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_1456_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_0_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_9935_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_1456_28000_80() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_9935_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 3) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_9_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "9"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "9"]).await.is_err());
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_5617_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 3) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_9935_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_1456_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_0_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 2) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_2_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "2"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_0_21000_64() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 21000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_5617_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_0_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_1456_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 2) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_9_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "9"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "9"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_1_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "1"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "1"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_5616_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
}

// Puts the point (1, 3) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_340282366920938463463374607431768211456_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "340282366920938463463374607431768211456"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "340282366920938463463374607431768211456"]).await.is_err());
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_9_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "9"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "9"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 3) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_340282366920938463463374607431768211456_21000_80() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "340282366920938463463374607431768211456"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "340282366920938463463374607431768211456"]).await.is_err());
}

// Puts the point (1, 3) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_340282366920938463463374607431768211456_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "340282366920938463463374607431768211456"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "340282366920938463463374607431768211456"]).await.is_err());
}

// Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_5617_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_5616_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_2_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "2"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_1_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "1"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "1"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_0_21000_80() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_5617_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_9_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "9"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "9"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 3) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_3_340282366920938463463374607431768211456_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "340282366920938463463374607431768211456"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "340282366920938463463374607431768211456"]).await.is_err());
}

// Puts the point (1, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_3_0_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "3", "0"]).await.is_err());
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_5616_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_616_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_7827_6598_9_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "9"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "9"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_7827_6598_1_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "1"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["11999875504842010600789954262886096740416429265635183817701593963271973497827", "11843594000332171325303933275547366297934113019079887694534126289021216356598", "1"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (11999875504842010600789954262886096740416429265635183817701593963271973497827, 11843594000332171325303933275547366297934113019079887694534126289021216356598) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 0) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_340282366920938463463374607431768211456_28000_80() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_0_21000_64() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_1_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "1"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "1"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_340282366920938463463374607431768211456_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 40 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_0_28000_40() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 40 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_5616_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_9_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "9"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "9"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 3) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_2_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "2"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "2"]).await.is_err());
}

// Puts the point (0, 0) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_1_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "1"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "1"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_0_28000_80() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 3) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_9935_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
}

// Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_0_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 0) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_1_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "1"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "1"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 0) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_9_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "9"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "9"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 3) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_9_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "9"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "9"]).await.is_err());
}

// Puts the point (0, 0) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_2_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "2"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_0_28000_64() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
}

// Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_0_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 0) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_9935_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_5616_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
}

// Puts the point (0, 0) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_9_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "9"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "9"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 0 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_0_21000_0() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 0 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 3) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_1_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "1"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "1"]).await.is_err());
}

// Puts the point (1, 2) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_2_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "2"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_0_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_2_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "2"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_340282366920938463463374607431768211456_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_0_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 2) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_2_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "2"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_0_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
}

// Puts the point (0, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_0_28000_80() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
}

// Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_0_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_5617_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
}

// Puts the point (0, 0) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_340282366920938463463374607431768211456_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 0) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_2_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "2"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 2) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_1_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "1"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "1"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_5617_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 3) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_340282366920938463463374607431768211456_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "340282366920938463463374607431768211456"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "340282366920938463463374607431768211456"]).await.is_err());
}

// Puts the point (0, 3) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_340282366920938463463374607431768211456_21000_80() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "340282366920938463463374607431768211456"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "340282366920938463463374607431768211456"]).await.is_err());
}

// Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_0_28000_64() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 2) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_1_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "1"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "1"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_0_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 2) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_1_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "1"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "1"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_0_21000_80() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_340282366920938463463374607431768211456_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 40 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_0_21000_40() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 40 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_5616_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_0_28000_64() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 3) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_340282366920938463463374607431768211456_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "340282366920938463463374607431768211456"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "340282366920938463463374607431768211456"]).await.is_err());
}

// Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 0 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_0_28000_0() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 0 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 0) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_340282366920938463463374607431768211456_21000_80() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "340282366920938463463374607431768211456"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "340282366920938463463374607431768211456"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 3) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_2_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "2"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "2"]).await.is_err());
}

// Puts the point (0, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_5616_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
}

// Puts the point (0, 3) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_2_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "2"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "2"]).await.is_err());
}

// Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_5616_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_0_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 3) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_9935_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
}

// Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_0_21000_80() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 3) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_340282366920938463463374607431768211456_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "340282366920938463463374607431768211456"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "340282366920938463463374607431768211456"]).await.is_err());
}

// Puts the point (0, 0) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_1_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "1"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "1"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_5616_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_5616_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
}

// Puts the point (0, 3) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_2_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "2"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "2"]).await.is_err());
}

// Puts the point (0, 3) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_9_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "9"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "9"]).await.is_err());
}

// Puts the point (0, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_5617_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
}

// Puts the point (0, 0) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_2_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "2"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 2 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_9935_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_5617_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_0_21000_64() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
}

// Puts the point (0, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_5617_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
}

// Puts the point (0, 0) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_9_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "9"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "9"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495616 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_5616_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495616"]).await.is_err());
}

// Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_5617_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 3) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_1_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "1"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "1"]).await.is_err());
}

// Puts the point (0, 3) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_1_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "1"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "1"]).await.is_err());
}

// Puts the point (0, 3) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_9935_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
}

// Puts the point (0, 0) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_9935_21000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 3) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_9_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "9"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "9"]).await.is_err());
}

// Puts the point (0, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_0_21000_80() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
}

// Puts the point (0, 3) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_9935_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.is_err());
}

// Puts the point (0, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_0_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
}

// Puts the point (0, 3) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_1_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "1"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "1"]).await.is_err());
}

// Puts the point (0, 3) and the factor 9 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_9_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "9"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "9"]).await.is_err());
}

// Puts the point (0, 0) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_9935_28000_128() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "115792089237316195423570985008687907853269984665640564039457584007913129639935"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 115792089237316195423570985008687907853269984665640564039457584007913129639935 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 3) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_5617_21000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.is_err());
}

// Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_0_5617_21000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "21888242871839275222246405745257275088548364400416034343698204186575808495617"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 21888242871839275222246405745257275088548364400416034343698204186575808495617 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 21000 bytes");
}

// Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_1_2_0_21000_64() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 64 bytes. Gives the execution 21000 bytes");
}

// Puts the point (0, 3) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_340282366920938463463374607431768211456_28000_80() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "340282366920938463463374607431768211456"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "340282366920938463463374607431768211456"]).await.is_err());
}

// Puts the point (0, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecmul_0_3_0_21000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
}

// Puts the point (0, 3) and the factor 340282366920938463463374607431768211456 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_340282366920938463463374607431768211456_28000_96() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "340282366920938463463374607431768211456"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "340282366920938463463374607431768211456"]).await.is_err());
}

// Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_0_28000_80() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 80 bytes. Gives the execution 28000 bytes");
}

// Puts the point (1, 2) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_1_2_1_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "1"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["1", "2", "1"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (1, 2) and the factor 1 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_0_0_28000_96() {
	let eth_response = eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the point (0, 0) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 96 bytes. Gives the execution 28000 bytes");
}

// Puts the point (0, 3) and the factor 0 into the ECMUL precompile, truncating or expanding the input data to 128 bytes. Gives the execution 28000 bytes
#[tokio::test]
async fn ecmul_0_3_0_28000_128() {
	assert!(eth_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
	assert!(era_call(ECMUL_PRECOMPILE_ADDRESS, &["0", "3", "0"]).await.is_err());
}
