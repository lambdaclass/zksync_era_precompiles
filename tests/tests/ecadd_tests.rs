use zksync_web3_rs::zks_utils::ECADD_PRECOMPILE_ADDRESS;

mod test_utils;
use test_utils::{eth_call, era_call};

// Puts the points (6, 9) and (19274124, 124124) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_6_9_19274124_124124_25000_128() {
	assert!(eth_call(ECADD_PRECOMPILE_ADDRESS, &["6", "9", "19274124", "124124"]).await.is_err());
	assert!(era_call(ECADD_PRECOMPILE_ADDRESS, &["6", "9", "19274124", "124124"]).await.is_err());
}

// Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 0 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_0_0_0_0_21000_0() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 0 bytes. Gives the execution 21000 bytes");
}

// Puts the points (1, 2) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_1_2_0_0_21000_128() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (1, 2) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_0_0_0_0_25000_128() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 25000 bytes");
}

// Puts the points (0, 3) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_0_3_1_2_25000_128() {
	assert!(eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "3", "1", "2"]).await.is_err());
	assert!(era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "3", "1", "2"]).await.is_err());
}

// Puts the points (0, 0) and (1, 3) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_0_0_1_3_25000_128() {
	assert!(eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "1", "3"]).await.is_err());
	assert!(era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "1", "3"]).await.is_err());
}

// Puts the points (0, 0) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_0_0_1_2_25000_128() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "1", "2"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "1", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (0, 0) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 25000 bytes");
}

// Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 64 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_0_0_0_0_25000_64() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 64 bytes. Gives the execution 25000 bytes");
}

// Puts the points (1, 2) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_1_2_1_2_21000_128() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "1", "2"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "1", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (1, 2) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the points (1, 3) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 80 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_1_3_0_0_25000_80() {
    assert!(eth_call(ECADD_PRECOMPILE_ADDRESS, &["1", "3", "0", "0"]).await.is_err());
	assert!(era_call(ECADD_PRECOMPILE_ADDRESS, &["1", "3", "0", "0"]).await.is_err());
}

// Puts the points (1, 2) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_1_2_0_0_25000_192() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (1, 2) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 25000 bytes");
}

// Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_0_0_0_0_21000_192() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 21000 bytes");
}

// Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 80 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_0_0_0_0_25000_80() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 80 bytes. Gives the execution 25000 bytes");
}

// Puts the points (10744596414106452074759370245733544594153395043370666422502510773307029471145, 848677436511517736191562425154572367705380862894644942948681172815252343932) and (10744596414106452074759370245733544594153395043370666422502510773307029471145, 21039565435327757486054843320102702720990930294403178719740356721829973864651) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_1145_3932_1145_4651_21000_192() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["10744596414106452074759370245733544594153395043370666422502510773307029471145", "848677436511517736191562425154572367705380862894644942948681172815252343932", "10744596414106452074759370245733544594153395043370666422502510773307029471145", "21039565435327757486054843320102702720990930294403178719740356721829973864651"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["10744596414106452074759370245733544594153395043370666422502510773307029471145", "848677436511517736191562425154572367705380862894644942948681172815252343932", "10744596414106452074759370245733544594153395043370666422502510773307029471145", "21039565435327757486054843320102702720990930294403178719740356721829973864651"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (10744596414106452074759370245733544594153395043370666422502510773307029471145, 848677436511517736191562425154572367705380862894644942948681172815252343932) and (10744596414106452074759370245733544594153395043370666422502510773307029471145, 21039565435327757486054843320102702720990930294403178719740356721829973864651) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 21000 bytes");
}

// Puts the points (0, 0) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_0_0_1_2_21000_192() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "1", "2"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "1", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (0, 0) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 21000 bytes");
}

// Puts the points (1, 2) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_1_2_1_2_25000_192() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "1", "2"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "1", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (1, 2) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 25000 bytes");
}

// Puts the points (1, 2) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 64 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_1_2_0_0_25000_64() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (1, 2) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 64 bytes. Gives the execution 25000 bytes");
}

// Puts the points (10744596414106452074759370245733544594153395043370666422502510773307029471145, 848677436511517736191562425154572367705380862894644942948681172815252343932) and (1624070059937464756887933993293429854168590106605707304006200119738501412969, 3269329550605213075043232856820720631601935657990457502777101397807070461336) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_1145_3932_2969_1336_21000_128() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["10744596414106452074759370245733544594153395043370666422502510773307029471145", "848677436511517736191562425154572367705380862894644942948681172815252343932", "1624070059937464756887933993293429854168590106605707304006200119738501412969", "3269329550605213075043232856820720631601935657990457502777101397807070461336"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["10744596414106452074759370245733544594153395043370666422502510773307029471145", "848677436511517736191562425154572367705380862894644942948681172815252343932", "1624070059937464756887933993293429854168590106605707304006200119738501412969", "3269329550605213075043232856820720631601935657990457502777101397807070461336"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (10744596414106452074759370245733544594153395043370666422502510773307029471145, 848677436511517736191562425154572367705380862894644942948681172815252343932) and (1624070059937464756887933993293429854168590106605707304006200119738501412969, 3269329550605213075043232856820720631601935657990457502777101397807070461336) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the points (6, 9) and (19274124, 124124) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_6_9_19274124_124124_21000_128() {
	assert!(eth_call(ECADD_PRECOMPILE_ADDRESS, &["6", "9", "19274124", "124124"]).await.is_err());
	assert!(era_call(ECADD_PRECOMPILE_ADDRESS, &["6", "9", "19274124", "124124"]).await.is_err());
}

// Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_0_0_0_0_21000_128() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the points (0, 3) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_0_3_1_2_21000_128() {
	assert!(eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "3", "1", "2"]).await.is_err());
	assert!(era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "3", "1", "2"]).await.is_err());
}

// Puts the points (0, 0) and (1, 3) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_0_0_1_3_21000_128() {
	assert!(eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "1", "3"]).await.is_err());
	assert!(era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "1", "3"]).await.is_err());
}

// Puts the points (1, 2) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_1_2_0_0_25000_128() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (1, 2) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 25000 bytes");
}

// Puts the points (1, 3) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_1_3_0_0_21000_80() {
    assert!(eth_call(ECADD_PRECOMPILE_ADDRESS, &["1", "3", "0", "0"]).await.is_err());
	assert!(era_call(ECADD_PRECOMPILE_ADDRESS, &["1", "3", "0", "0"]).await.is_err());
}

// Puts the points (1, 2) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_1_2_1_2_25000_128() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "1", "2"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "1", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (1, 2) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 25000 bytes");
}

// Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 0 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_0_0_0_0_25000_0() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 0 bytes. Gives the execution 25000 bytes");
}

// Puts the points (0, 0) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_0_0_1_2_21000_128() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "1", "2"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "1", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (0, 0) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 21000 bytes");
}

// Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 64 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_0_0_0_0_21000_64() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 64 bytes. Gives the execution 21000 bytes");
}

// Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_0_0_0_0_21000_80() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 80 bytes. Gives the execution 21000 bytes");
}

// Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_0_0_0_0_25000_192() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (0, 0) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 25000 bytes");
}

// Puts the points (1, 2) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_1_2_0_0_21000_192() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (1, 2) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 21000 bytes");
}

// Puts the points (1, 2) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_1_2_1_2_21000_192() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "1", "2"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "1", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (1, 2) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 21000 bytes");
}

// Puts the points (0, 0) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_0_0_1_2_25000_192() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "1", "2"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["0", "0", "1", "2"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (0, 0) and (1, 2) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 25000 bytes");
}

// Puts the points (10744596414106452074759370245733544594153395043370666422502510773307029471145, 848677436511517736191562425154572367705380862894644942948681172815252343932) and (10744596414106452074759370245733544594153395043370666422502510773307029471145, 21039565435327757486054843320102702720990930294403178719740356721829973864651) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_1145_3932_1145_4651_25000_192() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["10744596414106452074759370245733544594153395043370666422502510773307029471145", "848677436511517736191562425154572367705380862894644942948681172815252343932", "10744596414106452074759370245733544594153395043370666422502510773307029471145", "21039565435327757486054843320102702720990930294403178719740356721829973864651"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["10744596414106452074759370245733544594153395043370666422502510773307029471145", "848677436511517736191562425154572367705380862894644942948681172815252343932", "10744596414106452074759370245733544594153395043370666422502510773307029471145", "21039565435327757486054843320102702720990930294403178719740356721829973864651"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (10744596414106452074759370245733544594153395043370666422502510773307029471145, 848677436511517736191562425154572367705380862894644942948681172815252343932) and (10744596414106452074759370245733544594153395043370666422502510773307029471145, 21039565435327757486054843320102702720990930294403178719740356721829973864651) into the ECADD precompile, truncating or expanding the input data to 192 bytes. Gives the execution 25000 bytes");
}

// Puts the points (10744596414106452074759370245733544594153395043370666422502510773307029471145, 848677436511517736191562425154572367705380862894644942948681172815252343932) and (1624070059937464756887933993293429854168590106605707304006200119738501412969, 3269329550605213075043232856820720631601935657990457502777101397807070461336) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 25000 bytes
#[tokio::test]
async fn ecadd_1145_3932_2969_1336_25000_128() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["10744596414106452074759370245733544594153395043370666422502510773307029471145", "848677436511517736191562425154572367705380862894644942948681172815252343932", "1624070059937464756887933993293429854168590106605707304006200119738501412969", "3269329550605213075043232856820720631601935657990457502777101397807070461336"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["10744596414106452074759370245733544594153395043370666422502510773307029471145", "848677436511517736191562425154572367705380862894644942948681172815252343932", "1624070059937464756887933993293429854168590106605707304006200119738501412969", "3269329550605213075043232856820720631601935657990457502777101397807070461336"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (10744596414106452074759370245733544594153395043370666422502510773307029471145, 848677436511517736191562425154572367705380862894644942948681172815252343932) and (1624070059937464756887933993293429854168590106605707304006200119738501412969, 3269329550605213075043232856820720631601935657990457502777101397807070461336) into the ECADD precompile, truncating or expanding the input data to 128 bytes. Gives the execution 25000 bytes");
}

// Puts the points (1, 2) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 64 bytes. Gives the execution 21000 bytes
#[tokio::test]
async fn ecadd_1_2_0_0_21000_64() {
	let eth_response = eth_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "0", "0"]).await.unwrap();
	let era_response = era_call(ECADD_PRECOMPILE_ADDRESS, &["1", "2", "0", "0"]).await.unwrap();
	assert_eq!(eth_response, era_response, "Puts the points (1, 2) and (0, 0) into the ECADD precompile, truncating or expanding the input data to 64 bytes. Gives the execution 21000 bytes");
}

