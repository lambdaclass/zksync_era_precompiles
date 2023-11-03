use crate::test_utils::write_verifier_gas_result;
use std::env;
use zksync_era_precompiles::compile::compiler;
use zksync_web3_rs::{
    types::{Address, Bytes},
    zks_wallet::DeployRequest,
    ZKSWallet,
};

mod test_utils;

const CARGO_MANIFEST_DIR: &str = env!("CARGO_MANIFEST_DIR");

const RESPONSE_VALID: [u8; 32] = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
];

const RESPONSE_INVALID: [u8; 32] = [0; 32];

fn init_logger() {
    env_logger::builder()
        .filter_module("reqwest::connect", log::LevelFilter::Off)
        .filter_level(log::LevelFilter::Debug)
        .init();
}

#[tokio::test]
async fn old_verifier_succeeds() {
    init_logger();

    // Deploy the verifier.

    let era_provider = test_utils::era_provider();
    let wallet = test_utils::local_wallet();
    let zk_wallet = ZKSWallet::new(wallet, None, Some(era_provider.clone()), None).unwrap();
    let verifier_address: Address = {
        let artifact = compiler::compile(
            format!("{CARGO_MANIFEST_DIR}/contracts").as_str(),
            "contracts/old_verifier/Verifier.sol",
            "Verifier",
            compiler::Compiler::ZKSolc,
        )
        .unwrap();

        let compiled_bytecode = artifact.bin().unwrap();
        let compiled_abi = artifact.abi().unwrap();

        let deploy_request =
            DeployRequest::with(compiled_abi, compiled_bytecode.to_vec(), Vec::default());

        zk_wallet.deploy(&deploy_request).await.unwrap()
    };

    log::debug!("VERIFIER DEPLOYED AT: {verifier_address:?}");

    // Call the verifier.

    // Calldata for the verifier taken from this test
    // https://github.com/matter-labs/era-contracts/blob/main/ethereum/test/unit_tests/verifier.spec.ts
    let calldata = "330deb9f00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000100143e5a9ae11ce7c212304dd3f434ac8dff25332ad8adfc4203d95c7b4aea2f000000000000000000000000000000000000000000000000000000000000002c010f11270a0ddb00a666e1c6532065905092112e5fad0d1c9b615f9f3065c8dd014f93fc29fed9372193fc9535150c8d4ebe2b49fad387fc230344d16149a9bb23a4dc9d7f679cd15923c6dfc0e8e457edc0a3862a824e5aa4702ceabda0a04700948cb016bb21c4dd9c8cf107ddd4ddbc308eff7743c019d680fb4d8587d05a133b7e7e63f70910acce3feaf44d89cf893d410b0880f87ff308ef44c5aee77324878e90e224cb4246492115e94e79809dce757ca7a4decbcff6092ea5ce510a2e172ed1fb272478ca968965488da0b5c18d7fce9241f4a8ad295f01ba8478bd108bbbc2153a50515d9d8b2a5757a4b4d62efd3fd425da9d8b9a1b2f795421ea21ebacd434b555e1a82af0e0535f6aa47c9b38006a10f79f0fe8a52df474c51c1c2c8ca9750ed300dbc06ade43e69acbb614592a305c8e7ef4bf8aee50865fc8009e1b717a35bb31ab11d7ecd5802f7e598ca7918f79d575f17921d6681f7e79038209dfd674204198de3d291ca47b4212dfd4d6a20a2b360b1a6138623094ac1036e836c58c78400fd7b30e337e26d765b19d51d3d3447a01c0a003306b7efc001e7f110f8601fe84c79bb7a6c75cbd8cb92658ef563245280b9457c2a6913901cc91f946efb91a4e14f2d0790f73d6ba647aa414bc2e6fddd800d925371d8204e93b5790dd468d77df0b9b8bea80dc2ebe525412db5e724510e2feb7cad95506ebd8b3c96266a6fb9ff923431147bef97d701d1a2333bbf91cbfdb276080f22d5dab85db469066124fb7706b9c710773c05d8c360efc1c31992e336762c7d7114f8bf9a2050f2763affa8d7213c22adbcf01e42e785d3441ffea118888243d2692422d6933cdf24274fd29cef859856cc169e5d2e72b31deb620001cf3b9402ca0abed52054af163f83d0d6fabf082579d20bbb734eb9bf4e33a28cd8b4bdd0a44d037425f05a738e6ebc2e44127c05d6a6564a9091bab3407c223dbd2900f2e74025e8f7b63473b2639e8e876c04ce28907892ce6f56d976f16a9d5d3d3140caa73604a585da384d06686f4cc7b01f4cdc9627ff9b32b954048da29538f080a79a1acfe5cc1064672fe805b8efa3b3730dfa6558a17f323ad94bc47ab6d4a23922b78fa043a80c9cfdae2907a050804e7821e71d8fdcabeaece0d47eba0ad0027394d6a7c23dff26d46eb9a0a4ded65f663359db6dfaf5d020bbdf4defd4a21be59cd244bd991ddf098d632c68a61a1f5834567906aa6129aa1e38d269f6c0fb1ba84318af85e01302d8610a3810aea901f783e4f38cf01130f477456907926fdabdf196e08cbb15d242b74604fdf5466e34ac457f7776b166f9e74d4d09b15aae20ac54fb73ac5f19f5e8d8234bc619c2f93e14894e53e3a39059e9904d423cee98e838bc6f77a12ceb104f87f6a72974827e8a64698e18c3485a4e095441a0a8d84b5833271ad69ee59116ba97d1dd86efa77f75486a049195b47c499bd1fe6778aa9d3d435ad39d30564ecf51751db67f12669fa1bdae3f84c163f75c70feb723ac8ddd1a21c6adaedc36c86d1f6d5177183afa8d288ba699bac17b1c502bdd5679a965f57d8e1f71306c0adb67ccf46163b4538af86aa49d8d917590f1ce9caaed894da866c8a904161f4490c4381e073dbc1959cff9fbdc5ad8395a2303af8ffd4f4c8accf6bec9c91bb29ab90a334291134aaa3fcc392f156fc8bc20902d7167e48f2a66924d91098ce44aaf35c6c45df42ab66fea90bb4935e26e815fb71a86f46171b9fb5e77f2789b663643450e0ecc4a321089518f21f0838f70b1a21e343b967eed4b93b0764708d8ec57597848658bf8777dff4541faf0bf220117d30650de2bb1812f77f853ae99e5de5ff48587f5e4277061ad19bfcbd300e4d544ce4205b02bf74dd6e2dd6d132a3dd678a09fef6f98f3917b04bf1583e2673b5373e44ec861370732e2d2a8eeb2b719e12f4d7e085c2ee7bfdc4e9475f";
    let era_response = test_utils::era_call(
        verifier_address,
        None,
        Some(Bytes::from(hex::decode(calldata).unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = test_utils::parse_call_result(&era_response);
    // write_verifier_gas_result(gas_used);

    // Check the response.
    assert_eq!(era_output, Bytes::from(RESPONSE_VALID));
}

#[tokio::test]
async fn old_verifier_fails() {
    // Deploy the verifier.

    let era_provider = test_utils::era_provider();
    let wallet = test_utils::local_wallet();
    let zk_wallet = ZKSWallet::new(wallet, None, Some(era_provider.clone()), None).unwrap();
    let verifier_address: Address = {
        let artifact = compiler::compile(
            format!("{CARGO_MANIFEST_DIR}/contracts").as_str(),
            "contracts/old_verifier/Verifier.sol",
            "Verifier",
            compiler::Compiler::ZKSolc,
        )
        .unwrap();

        let compiled_bytecode = artifact.bin().unwrap();
        let compiled_abi = artifact.abi().unwrap();

        let deploy_request =
            DeployRequest::with(compiled_abi, compiled_bytecode.to_vec(), Vec::default());

        zk_wallet.deploy(&deploy_request).await.unwrap()
    };

    // Call the verifier.

    // Calldata for the verifier taken from this test
    // https://github.com/matter-labs/era-contracts/blob/main/ethereum/test/unit_tests/verifier.spec.ts
    // and modified to make it invalid.
    let calldata = "330deb9f00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000100143e5a9ae11ce7c212304dd3f434ac8dff25332ad8adfc4203d95c7b4aea2f000000000000000000000000000000000000000000000000000000000000002c010f11270a0ddb00a666e1c6532065905092112e5fad0d1c9b615f9f3065c8dd014f93fc29fed9372193fc9535150c8d4ebe2b49fad387fc230344d16149a9bb23a4dc9d7f679cd15923c6dfc0e8e457edc0a3862a824e5aa4702ceabda0a04700948cb016bb21c4dd9c8cf107ddd4ddbc308eff7743c019d680fb4d8587d05a133b7e7e63f70910acce3feaf44d89cf893d410b0880f87ff308ef44c5aee77324878e90e224cb4246492115e94e79809dce757ca7a4decbcff6092ea5ce510a2e172ed1fb272478ca968965488da0b5c18d7fce9241f4a8ad295f01ba8478bd108bbbc2153a50515d9d8b2a5757a4b4d62efd3fd425da9d8b9a1b2f795421ea21ebacd434b555e1a82af0e0535f6aa47c9b38006a10f79f0fe8a52df474c51c1c2c8ca9750ed300dbc06ade43e69acbb614592a305c8e7ef4bf8aee50865fc8009e1b717a35bb31ab11d7ecd5802f7e598ca7918f79d575f17921d6681f7e79038209dfd674204198de3d291ca47b4212dfd4d6a20a2b360b1a6138623094ac1036e836c58c78400fd7b30e337e26d765b19d51d3d3447a01c0a003306b7efc001e7f110f8601fe84c79bb7a6c75cbd8cb92658ef563245280b9457c2a6913901cc91f946efb91a4e14f2d0790f73d6ba647aa414bc2e6fddd800d925371d8204e93b5790dd468d77df0b9b8bea80dc2ebe525412db5e724510e2feb7cad95506ebd8b3c96266a6fb9ff923431147bef97d701d1a2333bbf91cbfdb276080f22d5dab85db469066124fb7706b9c710773c05d8c360efc1c31992e336762c7d7114f8bf9a2050f2763affa8d7213c22adbcf01e42e785d3441ffea118888243d2692422d6933cdf24274fd29cef859856cc169e5d2e72b31deb620001cf3b9402ca0abed52054af163f83d0d6fabf082579d20bbb734eb9bf4e33a28cd8b4bdd0a44d037425f05a738e6ebc2e44127c05d6a6564a9091bab3407c223dbd2900f2e74025e8f7b63473b2639e8e876c04ce28907892ce6f56d976f16a9d5d3d3140caa73604a585da384d06686f4cc7b01f4cdc9627ff9b32b954048da29538f080a79a1acfe5cc1064672fe805b8efa3b3730dfa6558a17f323ad94bc47ab6d4a23922b78fa043a80c9cfdae2907a050804e7821e71d8fdcabeaece0d47eba0ad0027394d6a7c23dff26d46eb9a0a4ded65f663359db6dfaf5d020bbdf4defd4a21be59cd244bd991ddf098d632c68a61a1f5834567906aa6129aa1e38d269f6c0fb1ba84318af85e01302d8610a3810aea901f783e4f38cf01130f477456907926fdabdf196e08cbb15d242b74604fdf5466e34ac457f7776b166f9e74d4d09b15aae20ac54fb73ac5f19f5e8d8234bc619c2f93e14894e53e3a39059e9904d423cee98e838bc6f77a12ceb104f87f6a72974827e8a64698e18c3485a4e095441a0a8d84b5833271ad69ee59116ba97d1dd86efa77f75486a049195b47c499bd1fe6778aa9d3d435ad39d30564ecf51751db67f12669fa1bdae3f84c163f75c70feb723ac8ddd1a21c6adaedc36c86d1f6d5177183afa8d288ba699bac17b1c502bdd5679a965f57d8e1f71306c0adb67ccf46163b4538af86aa49d8d917590f1ce9caaed894da866c8a904161f4490c4381e073dbc1959cff9fbdc5ad8395a2303af8ffd4f4c8accf6bec9c91bb29ab90a334291134aaa3fcc392f156fc8bc20902d7167e48f2a66924d91098ce44aaf35c6c45df42ab66fea90bb4935e26e815fb71a86f46171b9fb5e77f2789b663643450e0ecc4a321089518f21f0838f70b1a21e343b967eed4b93b0764708d8ec57597848658bf8777dff4541faf0bf220117d30650de2bb1812f77f853ae99e5de5ff48587f5e4277061ad19bfcbd300e4d544ce4205b02bf74dd6e2dd6d132a3dd678a09fef6f98f3917b04bf1583e2673b5373e44ec861370732e2d2a8eeb2b719e12f4d7e085c2ee7bfdc4e9475e";
    let era_response = test_utils::era_call(
        verifier_address,
        None,
        Some(Bytes::from(hex::decode(calldata).unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = test_utils::parse_call_result(&era_response);
    write_verifier_gas_result(gas_used);

    // Check the response.
    assert_eq!(era_output, Bytes::from(RESPONSE_INVALID));
}

// Note: This test deploys a Verifier with a test verifying key which was
// extracted from this PR https://github.com/matter-labs/era-contracts/pull/83/files#diff-7d10171e170dd1cd2c7502e8a682141ad6904c95c14bf631f0c97439fa90a0f6.
#[tokio::test]
async fn new_verifier_succeeds() {
    init_logger();

    // Deploy the verifier.

    let era_provider = test_utils::era_provider();
    let wallet = test_utils::local_wallet();
    let zk_wallet = ZKSWallet::new(wallet, None, Some(era_provider.clone()), None).unwrap();
    let verifier_address: Address = {
        let artifact = compiler::compile(
            format!("{CARGO_MANIFEST_DIR}/contracts").as_str(),
            "contracts/new_verifier/Verifier.sol",
            "Verifier",
            compiler::Compiler::ZKSolc,
        )
        .unwrap();

        let compiled_bytecode = artifact.bin().unwrap();
        let compiled_abi = artifact.abi().unwrap();

        let deploy_request =
            DeployRequest::with(compiled_abi, compiled_bytecode.to_vec(), Vec::default());

        zk_wallet.deploy(&deploy_request).await.unwrap()
    };

    log::debug!("VERIFIER DEPLOYED AT: {verifier_address:?}");

    // Call the verifier.

    // Calldata for the verifier taken from this test
    // https://github.com/matter-labs/era-contracts/blob/main/ethereum/test/unit_tests/verifier.spec.ts
    let calldata = "87d9d023000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000640000000000000000000000000000000000000000000000000000000000000000100000000a3dd954bb76c1474c1a04f04870cc75bcaf66ec23c0303c87fb119f9000000000000000000000000000000000000000000000000000000000000002c162e0e35310fa1265df0051490fad590e875a98b4e7781ce1bb2698887e240701a3645718b688a382a00b99059f9488daf624d04ceb39b5553f0a1a0d508dde6044df31be22763cde0700cc784f70758b944096a11c9b32bfb4f559d9b6a956702efae700419dd3fa0bebf5404efef2f3b5f8f2288c595ec219a05607e9971c9223e7327348fd30effc617ee9fa7e28117869f149719cf93c20788cb78adc291099f67d073880787c73d54bc2509c1611ac6f48fbe3b5214b4dc2f3cb3a572c017365bde1bbcd62561764ddd8b2d562edbe1c07519cd23f03831b694c6665a2d2f321ac8e18ab998f8fe370f3b5114598881798ccc6eac24d7f4161c15fdabb32f6b4b0f4973f2f6e2fa5ecd34602b20b56f0e4fb551b011af96e555fdc1197d0b8d070fec07e8467425605015acba755f54db7f566c6704818408d927419d800103185cff27eef6e8090373749a8065129fcc93482bd6ea4db1808725b6da2e29b35d35c22deda2ac9dd56a9f6a145871b1b6557e165296f804297160d5f98b240bb4b0b7e30e71e8af2d908e72bf47b6496aab1e1f7cb32f2604d79f76cff81cd2156a0f0c1944a8a3359618ff978b27eb42075c667960817be624ce1614890bd0b75112591ab1b4a6a3e03fb76368419b78e4b95ee773b8ef5e7848695cf70cd1da7fcfc27d2d9e9743e80951694995b162298d4109428fcf1c9a90f249052672327da3fdec6c58e8a0d33ca94e059da0787e9221a2a0ac412692cc962aac050e88db23f7582691a0fb7e5c95dd713e54188833fe1d241e3e32a98dfeb0f008dc78ede51774238b0984b02ac7fcf8b0a8dfcb6ca733b90c6b44aac455105702a3167374e2d54e47ce865ef222346adf7a27d4174820a637cf6568992383872f161fddcebb9ed8740c14d3a782efcf6f0ad069371194f87bcc04f9e9baf2ee25dcf81d1721eab45e86ccfee579eaa4e54a4a80a19edf784f24cc1ee831e58a1e483708e664ced677568d93b3b4f505e9d2968f802e04b31873f7d8f635fb0f2bf6cdf920d353ba8bda932b72bf6ff6a93aa831274a5dc3ea6ea647a446d18e02aa406a77d9143221165e066adfcc9281b9c90afdcee4336eda87f85d2bfe5b26fc05b152609664e624a233e52e12252a0cae9d2a86a36717300063faca4b4b24579fb180a63e5594644f4726c5af6d091aee4ee64c2c2a37d98f646a9c8d9d0b34ff9cbae3a9afe40e80a46e7d1419380e210a0e9595f61eb3a300aaef9f342ee89372d00fd0e32a46d513f7a80a1ae64302f33bc4b100384327a443c0193c2b0e285154aef9e8af0777190947379df37da05cf342897bf1de1bc40e497893158b022dd94b2c5c44994a5be28b2f570f1187277430ed9307517fa0c830d4321d1ea6f83308f30e544948e221d6b313367eccfe54ec05dfa757f023b5758f3d1a08a4549273627eadafe47379be8e997306f5b9567618b38c93a0d58eb6c54c0f434e5d987974afdd7f45a0f84fb800ecbbcdf2eeb302e415371e1d08ba4ad7168b5b6d46176887125f13423384b8e8dd4fd947aac832d8d15b87865580b5fb166cd223e74511332e2df4e7ad7a82c3871ed0305a5708521702c5e62e11a30b10f0979b9797e30f8fe15539518c7f4dfc98c7acb1490da60088b6ff908a4876020e08df88bbafc9a810fa8e2324c36b5513134477207763849ed4a0b6bd96391e977a84137396a3cfb17565ecfb5b60dffb242c7aab4afecaa45ebd2c83e0a319f3f9b6c6868a0e2a7453ff8949323715817869f8a25075308aa34a50c1ca3c248b030bbfab25516cca23e7937d4b3b46967292ef6dfd3df25fcfe289d53fac26bee4a0a5c8b76caa6b73172fa7760bd634c28d2c2384335b74f5d18e3933f4106719993b9dacbe46b17f4e896c0c9c116d226c50afe2256dca1e81cd510b5c19b5748fd961f755dd3c713d09014bd12adbb739fa1d2160067a312780a146a20000000000000000000000000000000000000000000000000000000000000000";
    let era_response = test_utils::era_call(
        verifier_address,
        None,
        Some(Bytes::from(hex::decode(calldata).unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = test_utils::parse_call_result(&era_response);
    write_verifier_gas_result(gas_used);

    // Check the response.
    assert_eq!(era_output, Bytes::from(RESPONSE_VALID));
}

// Note: This test deploys a Verifier with a test verifying key which was
// extracted from this PR https://github.com/matter-labs/era-contracts/pull/83/files#diff-7d10171e170dd1cd2c7502e8a682141ad6904c95c14bf631f0c97439fa90a0f6.
#[tokio::test]
async fn new_verifier_fails() {
    // Deploy the verifier.

    let era_provider = test_utils::era_provider();
    let wallet = test_utils::local_wallet();
    let zk_wallet = ZKSWallet::new(wallet, None, Some(era_provider.clone()), None).unwrap();
    let verifier_address: Address = {
        let artifact = compiler::compile(
            format!("{CARGO_MANIFEST_DIR}/contracts").as_str(),
            "contracts/new_verifier/Verifier.sol",
            "Verifier",
            compiler::Compiler::ZKSolc,
        )
        .unwrap();

        let compiled_bytecode = artifact.bin().unwrap();
        let compiled_abi = artifact.abi().unwrap();

        let deploy_request =
            DeployRequest::with(compiled_abi, compiled_bytecode.to_vec(), Vec::default());

        zk_wallet.deploy(&deploy_request).await.unwrap()
    };

    // Call the verifier.

    // Calldata for the verifier taken from this test
    // https://github.com/matter-labs/era-contracts/blob/main/ethereum/test/unit_tests/verifier.spec.ts
    // and modified to make it invalid.
    let calldata = "87d9d023000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000640000000000000000000000000000000000000000000000000000000000000000100000000a3dd954bb76c1474c1a04f04870cc75bcaf66ec23c0303c87fb119f9000000000000000000000000000000000000000000000000000000000000002c162e0e35310fa1265df0051490fad590e875a98b4e7781ce1bb2698887e240701a3645718b688a382a00b99059f9488daf624d04ceb39b5553f0a1a0d508dde6044df31be22763cde0700cc784f70758b944096a11c9b32bfb4f559d9b6a956702efae700419dd3fa0bebf5404efef2f3b5f8f2288c595ec219a05607e9971c9223e7327348fd30effc617ee9fa7e28117869f149719cf93c20788cb78adc291099f67d073880787c73d54bc2509c1611ac6f48fbe3b5214b4dc2f3cb3a572c017365bde1bbcd62561764ddd8b2d562edbe1c07519cd23f03831b694c6665a2d2f321ac8e18ab998f8fe370f3b5114598881798ccc6eac24d7f4161c15fdabb32f6b4b0f4973f2f6e2fa5ecd34602b20b56f0e4fb551b011af96e555fdc1197d0b8d070fec07e8467425605015acba755f54db7f566c6704818408d927419d800103185cff27eef6e8090373749a8065129fcc93482bd6ea4db1808725b6da2e29b35d35c22deda2ac9dd56a9f6a145871b1b6557e165296f804297160d5f98b240bb4b0b7e30e71e8af2d908e72bf47b6496aab1e1f7cb32f2604d79f76cff81cd2156a0f0c1944a8a3359618ff978b27eb42075c667960817be624ce1614890bd0b75112591ab1b4a6a3e03fb76368419b78e4b95ee773b8ef5e7848695cf70cd1da7fcfc27d2d9e9743e80951694995b162298d4109428fcf1c9a90f249052672327da3fdec6c58e8a0d33ca94e059da0787e9221a2a0ac412692cc962aac050e88db23f7582691a0fb7e5c95dd713e54188833fe1d241e3e32a98dfeb0f008dc78ede51774238b0984b02ac7fcf8b0a8dfcb6ca733b90c6b44aac455105702a3167374e2d54e47ce865ef222346adf7a27d4174820a637cf6568992383872f161fddcebb9ed8740c14d3a782efcf6f0ad069371194f87bcc04f9e9baf2ee25dcf81d1721eab45e86ccfee579eaa4e54a4a80a19edf784f24cc1ee831e58a1e483708e664ced677568d93b3b4f505e9d2968f802e04b31873f7d8f635fb0f2bf6cdf920d353ba8bda932b72bf6ff6a93aa831274a5dc3ea6ea647a446d18e02aa406a77d9143221165e066adfcc9281b9c90afdcee4336eda87f85d2bfe5b26fc05b152609664e624a233e52e12252a0cae9d2a86a36717300063faca4b4b24579fb180a63e5594644f4726c5af6d091aee4ee64c2c2a37d98f646a9c8d9d0b34ff9cbae3a9afe40e80a46e7d1419380e210a0e9595f61eb3a300aaef9f342ee89372d00fd0e32a46d513f7a80a1ae64302f33bc4b100384327a443c0193c2b0e285154aef9e8af0777190947379df37da05cf342897bf1de1bc40e497893158b022dd94b2c5c44994a5be28b2f570f1187277430ed9307517fa0c830d4321d1ea6f83308f30e544948e221d6b313367eccfe54ec05dfa757f023b5758f3d1a08a4549273627eadafe47379be8e997306f5b9567618b38c93a0d58eb6c54c0f434e5d987974afdd7f45a0f84fb800ecbbcdf2eeb302e415371e1d08ba4ad7168b5b6d46176887125f13423384b8e8dd4fd947aac832d8d15b87865580b5fb166cd223e74511332e2df4e7ad7a82c3871ed0305a5708521702c5e62e11a30b10f0979b9797e30f8fe15539518c7f4dfc98c7acb1490da60088b6ff908a4876020e08df88bbafc9a810fa8e2324c36b5513134477207763849ed4a0b6bd96391e977a84137396a3cfb17565ecfb5b60dffb242c7aab4afecaa45ebd2c83e0a319f3f9b6c6868a0e2a7453ff8949323715817869f8a25075308aa34a50c1ca3c248b030bbfab25516cca23e7937d4b3b46967292ef6dfd3df25fcfe289d53fac26bee4a0a5c8b76caa6b73172fa7760bd634c28d2c2384335b74f5d18e3933f4106719993b9dacbe46b17f4e896c0c9c116d226c50afe2256dca1e81cd510b5c19b5748fd961f755dd3c713d09014bd12adbb739fa1d2160067a312780a146a20000000000000000000000000000000000000000000000000000000000000001";
    let era_response = test_utils::era_call(
        verifier_address,
        None,
        Some(Bytes::from(hex::decode(calldata).unwrap())),
    )
    .await
    .unwrap();
    let (era_output, gas_used) = test_utils::parse_call_result(&era_response);
    write_verifier_gas_result(gas_used);

    // Check the response.
    assert_eq!(era_output, Bytes::from(RESPONSE_INVALID));
}
