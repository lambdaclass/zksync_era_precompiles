use std::env;
use zksync_web3_rs::{
    abi::Token,
    providers::{Http, Provider, ProviderError},
    types::Address,
    zks_provider::ZKSProvider,
    zks_utils::ECADD_PRECOMPILE_ADDRESS,
};

static DEFAULT_L1_PROVIDER_URL: &str = "http://localhost:8545";
static DEFAULT_L2_PROVIDER_URL: &str = "http://localhost:3050";

pub fn eth_provider() -> Provider<Http> {
    let url: String =
        env::var("ZKSYNC_WEB3_RS_L1_PROVIDER_URL").unwrap_or(DEFAULT_L1_PROVIDER_URL.to_owned());
    Provider::try_from(url).unwrap()
}

pub fn era_provider() -> Provider<Http> {
    let url: String =
        env::var("ZKSYNC_WEB3_RS_L2_PROVIDER_URL").unwrap_or(DEFAULT_L2_PROVIDER_URL.to_owned());
    Provider::try_from(url).unwrap()
}

pub async fn eth_call(
    precompile_address: Address,
    inputs: &[&str],
) -> Result<Vec<Token>, ProviderError> {
    call(precompile_address, inputs, &eth_provider()).await
}

pub async fn era_call(
    precompile_address: Address,
    inputs: &[&str],
) -> Result<Vec<Token>, ProviderError> {
    call(precompile_address, inputs, &era_provider()).await
}

pub async fn call(
    precompile_address: Address,
    inputs: &[&str],
    provider: &Provider<Http>,
) -> Result<Vec<Token>, ProviderError> {
    ZKSProvider::call(
        provider,
        precompile_address,
        "",
        Some(inputs.to_vec().iter().map(|x| x.to_string()).collect()),
    )
    .await
}
