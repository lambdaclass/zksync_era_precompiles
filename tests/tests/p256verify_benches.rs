use std::fs::OpenOptions;
use std::io::Write;
use zksync_era_precompiles::compile::compiler;
use zksync_web3_rs::ZKSWallet;
use zksync_web3_rs::providers::{Provider, Http};
use zksync_web3_rs::types::{Address, Bytes, H160};
use zksync_web3_rs::zks_wallet::DeployRequest;

mod test_utils;

const CARGO_MANIFEST_DIR: &str = env!("CARGO_MANIFEST_DIR");

const P256VERIFTY_PRECOMPILE_ADDRESS: Address = H160([
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x19,
]);

async fn deploy(era_provider: Provider<Http>, project_root_dir: &str, contract_path: &str, contract_name: &str) -> Address {
    let wallet = test_utils::local_wallet();
    let zk_wallet = ZKSWallet::new(wallet, None, Some(era_provider.clone()), None).unwrap();
    let address: Address = {
        let artifact = compiler::compile(
            project_root_dir,
            contract_path,
            contract_name,
            compiler::Compiler::ZKSolc,
        )
        .unwrap();

        let compiled_bytecode = artifact.bin().unwrap();
        let compiled_abi = artifact.abi().unwrap();

        let deploy_request =
            DeployRequest::with(compiled_abi, compiled_bytecode.to_vec(), Vec::default());

        zk_wallet.deploy(&deploy_request).await.unwrap()
    };

    log::debug!("CONTRACT DEPLOYED AT: {address:?}");

    address
}

#[tokio::test]
async fn p256verify_bench() {
    env_logger::init();

    let era_provider = test_utils::era_provider();

    let project_root_dir = format!("{CARGO_MANIFEST_DIR}/contracts");

    let p256verify_sol_address = deploy(era_provider, project_root_dir.as_str(), "contracts/p256verify/P256Verify.sol", "P256Verifier").await;

    let calldata = "93973e2948748003bc6c947d56a47411ea1c812b358be9d0189e2bd0a0b9d11eb03ae0c6a0e3e3ff4af4d16ee034277d34c6a8aa63c502d99b1d162961d07d59114fc42e88471db9de64d0ce23e37800a3b07af311d55119adcc82594b7492bb3caf1e7f618f833b6364862c701c6a1ce93fbeef210ef53f97619a8e0ad5c7b1b6a99bc96565cfdfa61439c441260232c6430726192fbb1cedc36f41570659f2";

    // Call P256Verify.sol
    let p256verify_sol_response = test_utils::era_call(
        p256verify_sol_address,
        None,
        Some(Bytes::from(hex::decode(calldata).unwrap())),
    )
    .await
    .unwrap();
    let (_, p256verify_sol_gas_used) = test_utils::parse_call_result(&p256verify_sol_response);

    // Call P256Verify.yul
    let p256verify_yul_response = test_utils::era_call(
        P256VERIFTY_PRECOMPILE_ADDRESS,
        None,
        Some(Bytes::from(hex::decode(calldata).unwrap())),
    )
    .await
    .unwrap();
    let (_, p256verify_yul_gas_used) = test_utils::parse_call_result(&p256verify_yul_response);

    // Write benches report.

    let mut file = OpenOptions::new()
        .create(true)
        .write(true)
        .truncate(true)
        .open("gas_reports/p256verify_benches_report.md")
        .unwrap();

    writeln!(file, "| Implementation | Gas used |").unwrap();
    writeln!(file, "| --------- | -------- |").unwrap();
    writeln!(file, "| AmadiMichael's Huff P256 Verifier  ||").unwrap();
    writeln!(file, "| Daimo's Solidity P256 Verifier  | {p256verify_sol_gas_used} |").unwrap();
    writeln!(file, "| Lambda's Yul P256 Verifier | {p256verify_yul_gas_used} |").unwrap();
}
