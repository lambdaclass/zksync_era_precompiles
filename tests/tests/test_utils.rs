use std::env;
use zksync_web3_rs::{
    abi::{decode, ParamType, Token},
    providers::{Http, Middleware, Provider, ProviderError},
    types::{transaction::eip2718::TypedTransaction, Address, Bytes, Eip1559TransactionRequest},
    zks_provider::ZKSProvider,
    zks_utils::{
        ec_add_function, ec_mul_function, mod_exp_function, ECADD_PRECOMPILE_ADDRESS,
        ECMUL_PRECOMPILE_ADDRESS, MODEXP_PRECOMPILE_ADDRESS,
    },
};

static DEFAULT_L1_PROVIDER_URL: &str = "http://65.21.140.36:8545";
static DEFAULT_L2_PROVIDER_URL: &str = "http://localhost:8011";

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
    inputs: Option<&[&str]>,
    data: Option<Bytes>,
) -> Result<Vec<Token>, ProviderError> {
    call(precompile_address, inputs, data, &eth_provider()).await
}

pub async fn era_call(
    precompile_address: Address,
    inputs: Option<&[&str]>,
    data: Option<Bytes>,
) -> Result<Vec<Token>, ProviderError> {
    call(precompile_address, inputs, data, &era_provider()).await
}

pub async fn call(
    precompile_address: Address,
    inputs: Option<&[&str]>,
    data: Option<Bytes>,
    provider: &Provider<Http>,
) -> Result<Vec<Token>, ProviderError> {
    if let Some(data) = data {
        let request = Eip1559TransactionRequest::new()
            .to(precompile_address)
            .data(data);
        let transaction: TypedTransaction = request.into();
        let encoded_output = Middleware::call(&provider, &transaction, None).await?;
        let output_types: Vec<ParamType> = if precompile_address == ECADD_PRECOMPILE_ADDRESS {
            ec_add_function()
        } else if precompile_address == ECMUL_PRECOMPILE_ADDRESS {
            ec_mul_function()
        } else if precompile_address == MODEXP_PRECOMPILE_ADDRESS {
            mod_exp_function()
        } else {
            panic!("precompile_address not supported")
        }
        .outputs
        .into_iter()
        .map(|o| o.kind)
        .collect();
        decode(&output_types, &encoded_output).map_err(|e| ProviderError::CustomError(format!("decode error: {}", e)))
    } else if let Some(inputs) = inputs {
        Ok(ZKSProvider::call(
            provider,
            precompile_address,
            "",
            Some(inputs.to_vec().iter().map(|x| x.to_string()).collect()),
        )
        .await
        .unwrap_or_default())
    } else {
        panic!("inputs or data must be provided")
    }
}
