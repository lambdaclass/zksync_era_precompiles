use std::env;
use zksync_web3_rs::providers::{Http, Provider};

static DEFAULT_L1_PROVIDER_URL: &str = "http://localhost:8545";
static DEFAULT_L2_PROVIDER_URL: &str = "http://localhost:3050";

pub fn eth_provider() -> Provider<Http> {
    let url: String = env::var("ZKSYNC_WEB3_RS_L1_PROVIDER_URL")
        .unwrap_or(DEFAULT_L1_PROVIDER_URL.to_owned());
    Provider::try_from(url).unwrap()
}

pub fn era_provider() -> Provider<Http> {
    let url: String = env::var("ZKSYNC_WEB3_RS_L2_PROVIDER_URL")
        .unwrap_or(DEFAULT_L2_PROVIDER_URL.to_owned());
    Provider::try_from(url).unwrap()
}