use std::fs::OpenOptions;
use std::io::Write;
use zksync_era_precompiles::compile::compiler::{self, Compiler};
use zksync_web3_rs::providers::{Http, Provider};
use zksync_web3_rs::types::{Address, Bytes, H160};
use zksync_web3_rs::zks_wallet::DeployRequest;
use zksync_web3_rs::ZKSWallet;

mod test_utils;

const CARGO_MANIFEST_DIR: &str = env!("CARGO_MANIFEST_DIR");

const P256VERIFTY_PRECOMPILE_ADDRESS: Address = H160([
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x19,
]);

async fn deploy(
    era_provider: &Provider<Http>,
    project_root_dir: &str,
    contract_path: &str,
    contract_name: &str,
    compiler: Compiler,
) -> Address {
    let wallet = test_utils::local_wallet();
    let zk_wallet = ZKSWallet::new(wallet, None, Some(era_provider.clone()), None).unwrap();
    let address: Address = {
        let artifact =
            compiler::compile(project_root_dir, contract_path, contract_name, compiler).unwrap();

        let compiled_bytecode = artifact.bin().unwrap();
        let compiled_abi = artifact.abi().unwrap();

        let deploy_request =
            DeployRequest::with(compiled_abi, compiled_bytecode.to_vec(), Vec::default());

        zk_wallet.deploy(&deploy_request).await.unwrap()
    };

    log::debug!("CONTRACT DEPLOYED AT: {address:?}");

    address
}

async fn call(contract: Address, calldata: &str) -> u32 {
    let p256verify_response = test_utils::era_call(
        contract,
        None,
        Some(Bytes::from(hex::decode(calldata).unwrap())),
    )
    .await
    .unwrap();

    let (_, p256verify_gas_used) = test_utils::parse_call_result(&p256verify_response);

    p256verify_gas_used
}

#[tokio::test]
async fn p256verify_bench() {
    env_logger::init();

    let era_provider = test_utils::era_provider();

    let project_root_dir = format!("{CARGO_MANIFEST_DIR}/contracts");

    // Deploy contracts.
    let p256verify_sol_address = deploy(
        &era_provider,
        project_root_dir.as_str(),
        "contracts/p256verify/P256Verify.sol",
        "P256Verifier",
        Compiler::ZKSolc,
    )
    .await;
    let p256verify_vy_address = deploy(
        &era_provider,
        "contracts/p256verify/P256Verify.vy",
        "contracts/p256verify/P256Verify.vy",
        "P256Verifier",
        Compiler::ZKVyper,
    )
    .await;

    // Read calldata.
    let valid_calldata_cases: Vec<&str> =
        serde_json::from_slice(include_bytes!("../../assets/benches_calldata.json")).unwrap();

    // Bench.
    let mut bench_data = Vec::new();
    let bench_data_len = valid_calldata_cases.len();
    for (i, calldata) in valid_calldata_cases.into_iter().enumerate() {
        log::info!("Benchmarking {i}/{bench_data_len}...");
        let p256verify_sol_gas_used = call(p256verify_sol_address, calldata).await;
        let p256verify_vy_gas_used = call(p256verify_vy_address, calldata).await;
        let p256verify_yul_gas_used = call(P256VERIFTY_PRECOMPILE_ADDRESS, calldata).await;
        bench_data.push((
            p256verify_sol_gas_used,
            p256verify_vy_gas_used,
            p256verify_yul_gas_used,
        ));
    }
    log::info!("Done benchmarking.");

    // Calculate min.
    let p256verify_sol_gas_used_min = bench_data
        .clone()
        .into_iter()
        .min_by_key(|(p256verify_sol_gas_used, _, _)| *p256verify_sol_gas_used)
        .unwrap()
        .0;
    let p256verify_vy_gas_used_min = bench_data
        .clone()
        .into_iter()
        .min_by_key(|(_, p256verify_vy_gas_used, _)| *p256verify_vy_gas_used)
        .unwrap()
        .1;
    let p256verify_yul_gas_used_min = bench_data
        .clone()
        .into_iter()
        .min_by_key(|(_, _, p256verify_yul_gas_used)| *p256verify_yul_gas_used)
        .unwrap()
        .2;

    // Calculate max.
    let p256verify_sol_gas_used_max = bench_data
        .clone()
        .into_iter()
        .max_by_key(|(p256verify_sol_gas_used, _, _)| *p256verify_sol_gas_used)
        .unwrap()
        .0;
    let p256verify_vy_gas_used_max = bench_data
        .clone()
        .into_iter()
        .max_by_key(|(_, p256verify_vy_gas_used, _)| *p256verify_vy_gas_used)
        .unwrap()
        .1;
    let p256verify_yul_gas_used_max = bench_data
        .clone()
        .into_iter()
        .max_by_key(|(_, _, p256verify_yul_gas_used)| *p256verify_yul_gas_used)
        .unwrap()
        .2;

    // Calculate avg.
    let p256verify_sol_gas_used_avg = bench_data
        .clone()
        .into_iter()
        .map(|(p256verify_sol_gas_used, _, _)| p256verify_sol_gas_used)
        .sum::<u32>()
        / bench_data.len() as u32;
    let p256verify_vy_gas_used_avg = bench_data
        .clone()
        .into_iter()
        .map(|(_, p256verify_vy_gas_used, _)| p256verify_vy_gas_used)
        .sum::<u32>()
        / bench_data.len() as u32;
    let p256verify_yul_gas_used_avg = bench_data
        .clone()
        .into_iter()
        .map(|(_, _, p256verify_yul_gas_used)| p256verify_yul_gas_used)
        .sum::<u32>()
        / bench_data.len() as u32;

    // Write benches report.
    let mut file = OpenOptions::new()
        .create(true)
        .write(true)
        .truncate(true)
        .open("gas_reports/p256verify_benches_report.md")
        .unwrap();

    let bench_report = format!("| Implementation | Min Gas Used | Avg Used | Max Gas Used |
    | --- | --- | --- | --- |
    | Daimo's Solidity P256 Verifier  | {p256verify_sol_gas_used_min} | {p256verify_sol_gas_used_avg} | {p256verify_sol_gas_used_max} |
    | pcaversaccio's Vyper P256 Verifier | {p256verify_vy_gas_used_min} | {p256verify_vy_gas_used_avg} | {p256verify_vy_gas_used_max} |
    | Lambda's Yul P256 Verifier | {p256verify_yul_gas_used_min} | {p256verify_yul_gas_used_avg} | {p256verify_yul_gas_used_max} |\n");

    writeln!(file, "{bench_report}").unwrap();
}
