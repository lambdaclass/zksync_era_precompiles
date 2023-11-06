use zksync_web3_rs::prelude::abi::{Abi, Param};
use zksync_web3_rs::prelude::artifacts::StateMutability;
use zksync_web3_rs::prelude::info::ContractInfoRef;
use zksync_web3_rs::prelude::types::Bytes;

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ZKSArtifact {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub abi: Option<Abi>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bin: Option<Bytes>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub metadata: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub devdoc: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub userdoc: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none", rename = "kebab-case")]
    pub storage_layout: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub ast: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub asm: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none", rename = "kebab-case")]
    pub bin_runtime: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub hashes: Option<HashMap<String, String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub factory_deps: Option<HashMap<String, String>>,
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct ContractFunctionOutput {
    pub inputs: Vec<Param>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub outputs: Option<Vec<Param>>,
    pub state_mutability: StateMutability,
    #[serde(rename = "type")]
    pub sol_struct_type: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct ZKSCompilationOutput {
    #[serde(rename = "contracts")]
    pub artifacts: HashMap<String, ZKSArtifact>,
    pub version: String,
    pub zk_version: String,
}

impl ZKSCompilationOutput {
    pub fn find_contract<'contract_info>(
        &self,
        info: impl Into<ContractInfoRef<'contract_info>>,
    ) -> Option<&ZKSArtifact> {
        let ContractInfoRef { path, name } = info.into();
        if let Some(path) = path {
            self.find(path, name)
        } else {
            self.find_first(name)
        }
    }

    pub fn find(&self, path: impl AsRef<str>, contract: impl AsRef<str>) -> Option<&ZKSArtifact> {
        let contract_path = path.as_ref();
        let contract_name = contract.as_ref();
        self.artifacts
            .get(&format!("{contract_path}:{contract_name}"))
        // TODO: handle cached artifacts.
        // if let artifact @ Some(_) = self.artifacts.get(&format!("{contract_path}:{contract_name}")) {
        //     return artifact
        // }
        // self.cached_artifacts.find(contract_path, contract_name)
    }

    /// Finds the first contract with the given name
    pub fn find_first(&self, contract_name: impl AsRef<str>) -> Option<&ZKSArtifact> {
        let contract_name = contract_name.as_ref();
        self.artifacts.keys().find_map(|key| {
            if key.ends_with(contract_name) {
                self.artifacts.get(key)
            } else {
                None
            }
        })
        // TODO: handle cached artifacts.
        // if let artifact @ Some(_) = self.compiled_artifacts.find_first(contract_name) {
        //     return artifact
        // }
        // self.cached_artifacts.find_first(contract_name)
    }
}
