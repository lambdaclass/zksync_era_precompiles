// use zksync_web3_rs::{types::Bytes, zks_utils::ECADDG2_PRECOMPILE_ADDRESS};

mod test_utils;
use test_utils::{era_call, parse_call_result};
use zksync_web3_rs::types::{Address, Bytes, H160};

pub const ECADD_G2_PRECOMPILE_ADDRESS: Address = H160([
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x0A,
]);

#[tokio::test]
async fn ecadd_g2_valid_1() {

    // P + Q = R
    // P = [(123364d138d3c357b288a1eda53008a69e8fff2234acb97555bd4832575b4440 + 26e5131791db07c83124fc5959235d073e735137a2c7b6627254f9ec45d45e2 * u),
    //      (2b1f80d2f89aaba97ecce556ce75b17002deb6bbeccbc5d9ca5e03474b82acfc + 39f8a1bcc72edfaecf7527355fc27d1a2c62f88da5a7c8fdd6d5f7176c97bfd * u)]
    // Q = [(140fbfc39579e8ee047e627c713f3dbb4a5757c2e9da1851df2c91643a39bf06 + f1287358ba8b8096533ab4165f7b7232f8ca9d8b524d57d0aa343544f5e77c0 * u),
    //      (1f96db302eb6f987734ba048b6f52de5cf8c3a983687eb472cd95b333666a49e + 72d44f229ed6afa5d666b374c5e480a7d6927ef04d0c19038d4a412d813c947 * u)]
    // R = [(efa63d157bae6d2a0c45f94ee7703888580c24efcfe2bbd8e43ad27a2c825be + dbc04d10f8669fdf3ff8919018728b105bd778faf7f631eae47a6d02b3a441f * u),
    //      (cfb235e67d14e6d0d15be6b776db5400db90f0735bb0ba9b6ccfdea3f030b53 + 25c428cdc42de7169b01d949376a2a2b319b1098d414d5146e637b49b60fbb62 * u)]

    let era_response = era_call(ECADD_G2_PRECOMPILE_ADDRESS, None, Some(Bytes::from(
            hex::decode(
                "123364d138d3c357b288a1eda53008a69e8fff2234acb97555bd4832575b4440\
                026e5131791db07c83124fc5959235d073e735137a2c7b6627254f9ec45d45e2\
                2b1f80d2f89aaba97ecce556ce75b17002deb6bbeccbc5d9ca5e03474b82acfc\
                039f8a1bcc72edfaecf7527355fc27d1a2c62f88da5a7c8fdd6d5f7176c97bfd\
                140fbfc39579e8ee047e627c713f3dbb4a5757c2e9da1851df2c91643a39bf06\
                0f1287358ba8b8096533ab4165f7b7232f8ca9d8b524d57d0aa343544f5e77c0\
                1f96db302eb6f987734ba048b6f52de5cf8c3a983687eb472cd95b333666a49e\
                072d44f229ed6afa5d666b374c5e480a7d6927ef04d0c19038d4a412d813c947"
                ).unwrap()))).await.unwrap();
    let (era_output, _gas_used) = parse_call_result(&era_response);

    let result = Bytes::from(
        hex::decode(
            "0efa63d157bae6d2a0c45f94ee7703888580c24efcfe2bbd8e43ad27a2c825be\
            0dbc04d10f8669fdf3ff8919018728b105bd778faf7f631eae47a6d02b3a441f\
            0cfb235e67d14e6d0d15be6b776db5400db90f0735bb0ba9b6ccfdea3f030b53\
            25c428cdc42de7169b01d949376a2a2b319b1098d414d5146e637b49b60fbb62"
            ).unwrap());
    assert_eq!(era_output, result)
}

#[tokio::test]
async fn ecadd_g2_valid_2() {

    // P + Q = R
    // P = [(29274c280e635e69826c79f6a73541305a7ba63c3b29b35f5ffa022417d9d938 + 125ec0b478ffc74cd6a8f11695f8b6e70feaa4210d8b6a79146fb76d438d16ee * u),
    //      (07cf2e9ba94b5bcc4f96376d173fc7aa46bc342068a3eb5089f794d529808501 + 15d79409c1351490fcdf2c5be63bf4215dfbfbae2a868b60e9089ced9aa6251e * u)]
    // Q = [(20ddf29108747d2a1c2052f07c0548ce13834556d4316a4042ac7157f01ad80e + 1b70e8d0c4dc8730e30725c33fb157766955e988ead1fc6bdf4a193f6229dda0 * u),
    //      (2f146452dc0ad6ea48a438b0f88958b9591d834892b7e6e5383616545c9fb596 + c90472097ba74ad9e818144862bcdd5889f52f7efb2e1d43dd9e45d5ee5b5a4 * u)]
    // R = [(21e0a10d705985d59a6608814b8f84234100c54d11f745ca5e2f73c03ef53ce5 + 47a972dc54371c9510db4d650bb80aa3b3449189f184c90108a687d184678c2 * u),
    //      (12ec72c51aebaba5d8285ec71c1a1205e2623fba659992c9a74e336864c15e69 + 1ad73defc8fbbedc47fc1b67bbcec83837e77f6eb9dc505593fbcbc5b5383d58 * u)]

    let era_response = era_call(ECADD_G2_PRECOMPILE_ADDRESS, None, Some(Bytes::from(
            hex::decode(
                "29274c280e635e69826c79f6a73541305a7ba63c3b29b35f5ffa022417d9d938\
                125ec0b478ffc74cd6a8f11695f8b6e70feaa4210d8b6a79146fb76d438d16ee\
                07cf2e9ba94b5bcc4f96376d173fc7aa46bc342068a3eb5089f794d529808501\
                15d79409c1351490fcdf2c5be63bf4215dfbfbae2a868b60e9089ced9aa6251e\
                20ddf29108747d2a1c2052f07c0548ce13834556d4316a4042ac7157f01ad80e\
                1b70e8d0c4dc8730e30725c33fb157766955e988ead1fc6bdf4a193f6229dda0\
                2f146452dc0ad6ea48a438b0f88958b9591d834892b7e6e5383616545c9fb596\
                0c90472097ba74ad9e818144862bcdd5889f52f7efb2e1d43dd9e45d5ee5b5a4"
                ).unwrap()))).await.unwrap();
    let (era_output, _gas_used) = parse_call_result(&era_response);

    let result = Bytes::from(
        hex::decode(
            "21e0a10d705985d59a6608814b8f84234100c54d11f745ca5e2f73c03ef53ce5\
            047a972dc54371c9510db4d650bb80aa3b3449189f184c90108a687d184678c2\
            12ec72c51aebaba5d8285ec71c1a1205e2623fba659992c9a74e336864c15e69\
            1ad73defc8fbbedc47fc1b67bbcec83837e77f6eb9dc505593fbcbc5b5383d58"
            ).unwrap());
    assert_eq!(era_output, result)
}

#[tokio::test]
async fn ecadd_g2_valid_3() {

    // P + Q = R
    // P = [(2c7feab275fd27a02f0169e9195ee3748a4027a314e5c91cf98ce1f3c26fc07c + 1b528e37f99bb64edaa6d01bda8ae86de78ec14f1e15d30e4f92174419347f91 * u),
    //      (0eae57d3f9e6cbb78b7d89f5ac3e6fd2f110032a398ca55d26b35272d608d644 + 2ecdd2542d8358b9b6590bd48e075fc3b1b2f6a5e237b9ac67c628553e1afb41 * u)]
    // Q = [(28fb3f4fa26a1b6f6829e4e19632fe8b766ee70b17d10e560b9f86855b43dfe8 + 299b8a2cbe007ebed8bccc3e2a763314afa6d3c97a1ab4a54176d375cb34c904 * u),
    //      (2ead7e668665df160741d0047feee0c0426c5881a525c62c96a3a6a09df60eca + 166f12fcd94202b021eb6178d5253ac78e867546ada6480b9d66eadb17e53021 * u)]
    // R = [(19b7e6f6b1293bf6a9621d1ba6a95b3cb3b65a8a73c0f9aca717fd518919fc9f + 1b7ee434ec088b0e218fb9c5413e2094ff853c4befad6aef083b5af1329da497 * u),
    //      (1141ffd3b881a67a09669968a53c0d6abc1dd4ef5fd4e4cda539e166c92cf2d9 + 14833f347a9f9a8ab50e210749f055b2a42617a3f9ec26ae08f48e5f6dce2d95 * u)]

    let era_response = era_call(ECADD_G2_PRECOMPILE_ADDRESS, None, Some(Bytes::from(
            hex::decode(
                "2c7feab275fd27a02f0169e9195ee3748a4027a314e5c91cf98ce1f3c26fc07c\
                1b528e37f99bb64edaa6d01bda8ae86de78ec14f1e15d30e4f92174419347f91\
                0eae57d3f9e6cbb78b7d89f5ac3e6fd2f110032a398ca55d26b35272d608d644\
                2ecdd2542d8358b9b6590bd48e075fc3b1b2f6a5e237b9ac67c628553e1afb41\
                28fb3f4fa26a1b6f6829e4e19632fe8b766ee70b17d10e560b9f86855b43dfe8\
                299b8a2cbe007ebed8bccc3e2a763314afa6d3c97a1ab4a54176d375cb34c904\
                2ead7e668665df160741d0047feee0c0426c5881a525c62c96a3a6a09df60eca\
                166f12fcd94202b021eb6178d5253ac78e867546ada6480b9d66eadb17e53021"
                ).unwrap()))).await.unwrap();
    let (era_output, _gas_used) = parse_call_result(&era_response);

    let result = Bytes::from(
        hex::decode(
            "19b7e6f6b1293bf6a9621d1ba6a95b3cb3b65a8a73c0f9aca717fd518919fc9f\
            1b7ee434ec088b0e218fb9c5413e2094ff853c4befad6aef083b5af1329da497\
            1141ffd3b881a67a09669968a53c0d6abc1dd4ef5fd4e4cda539e166c92cf2d9\
            14833f347a9f9a8ab50e210749f055b2a42617a3f9ec26ae08f48e5f6dce2d95"
            ).unwrap());
    assert_eq!(era_output, result)
}
