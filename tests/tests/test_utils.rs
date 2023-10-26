use std::{env, fs::OpenOptions, io::Write};
use zksync_web3_rs::{
    providers::{Http, Middleware, Provider, ProviderError},
    types::{transaction::eip2718::TypedTransaction, Address, Bytes, Eip1559TransactionRequest},
    zks_utils::{ECADD_PRECOMPILE_ADDRESS, ECMUL_PRECOMPILE_ADDRESS, ECPAIRING_PRECOMPILE_ADDRESS},
};

static DEFAULT_L1_PROVIDER_URL: &str =
    "https://eth-mainnet.alchemyapi.io/v2/Lc7oIGYeL_QvInzI0Wiu_pOZZDEKBrdf";
static DEFAULT_L2_PROVIDER_URL: &str = "http://localhost:8011";

pub fn parse_call_result(bytes: &[u8]) -> (Bytes, u32) {
    let gas_used_bytes = bytes[0..4].to_vec();
    let output = bytes[4..].to_vec();
    let gas_used = u32::from_le_bytes(gas_used_bytes.try_into().unwrap());

    (output.into(), gas_used)
}

fn write_line_to_report(used_gas: u32, report_to_write: &str) {
    let mut file = OpenOptions::new()
        .append(true)
        .open(report_to_write)
        .unwrap();

    let curr_thread = std::thread::current();
    let test_name = curr_thread.name().unwrap();

    write!(file, "| {test_name}  | {used_gas} | \n").unwrap();
}

pub fn write_modexp_gas_result(used_gas: u32) {
    write_line_to_report(used_gas, "gas_reports/modexp_report.md");
}

pub fn write_ecadd_gas_result(used_gas: u32) {
    write_line_to_report(used_gas, "gas_reports/ecadd_report.md");
}

pub fn write_ecmul_gas_result(used_gas: u32) {
    write_line_to_report(used_gas, "gas_reports/ecmul_report.md");
}

pub fn write_ecpairing_gas_result(used_gas: u32) {
    write_line_to_report(used_gas, "gas_reports/ecpairing_report.md");
}

pub fn write_p256verify_gas_result(used_gas: u32) {
    write_line_to_report(used_gas, "gas_reports/p256verify_report.md");
}

pub fn write_secp256k1verify_gas_result(used_gas: u32) {
    write_line_to_report(used_gas, "gas_reports/secp256k1verify_report.md");
}

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

#[allow(dead_code)]
pub async fn eth_call(
    precompile_address: Address,
    inputs: Option<&[&str]>,
    data: Option<Bytes>,
) -> Result<Bytes, ProviderError> {
    call(precompile_address, inputs, data, &eth_provider()).await
}

pub async fn era_call(
    precompile_address: Address,
    inputs: Option<&[&str]>,
    data: Option<Bytes>,
) -> Result<Bytes, ProviderError> {
    let response = call(precompile_address, inputs, data, &era_provider()).await?;

    // This check was necessary because the revert from yul returns `0x00` and is not being parsed as an error in the node side when it should be.
    if (precompile_address == ECMUL_PRECOMPILE_ADDRESS
        || precompile_address == ECADD_PRECOMPILE_ADDRESS
        || precompile_address == ECPAIRING_PRECOMPILE_ADDRESS)
        && (response.len() == 1)
    {
        return Err(ProviderError::CustomError("Reverted".to_owned()));
    };
    Ok(response)
}

pub async fn call(
    precompile_address: Address,
    _inputs: Option<&[&str]>,
    data: Option<Bytes>,
    provider: &Provider<Http>,
) -> Result<Bytes, ProviderError> {
    if let Some(data) = data {
        let request = Eip1559TransactionRequest::new()
            .to(precompile_address)
            .data(data);
        let transaction: TypedTransaction = request.into();
        let encoded_output = Middleware::call(&provider, &transaction, None).await?;
        Ok(encoded_output)
    } else {
        panic!("inputs or data must be provided")
    }
}

#[allow(unused)]
pub async fn eth_raw_call(
    precompile_address: Address,
    data: Bytes,
) -> Result<Bytes, ProviderError> {
    raw_call(precompile_address, data, &eth_provider()).await
}

#[allow(unused)]
pub async fn era_raw_call(
    precompile_address: Address,
    data: Bytes,
) -> Result<Bytes, ProviderError> {
    raw_call(precompile_address, data, &era_provider()).await
}

#[allow(unused)]
pub async fn raw_call(
    precompile_address: Address,
    data: Bytes,
    provider: &Provider<Http>,
) -> Result<Bytes, ProviderError> {
    let request = Eip1559TransactionRequest::new()
        .to(precompile_address)
        .data(data);
    let transaction: TypedTransaction = request.into();
    Middleware::call(&provider, &transaction, None).await
}
