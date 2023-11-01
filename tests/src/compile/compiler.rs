use super::{output::ZKSArtifact, project::ZKSProject};
use eyre::ContextCompat;
use std::{ffi::OsString, path::PathBuf, str::FromStr};
use zksync_web3_rs::{
    prelude::{abi::Abi, info::ContractInfo, Project, ProjectPathsConfig},
    solc::{utils::source_files, ConfigurableContractArtifact},
    types::Bytes,
};

#[derive(Clone)]
pub enum Compiler {
    ZKSolc,
    Solc,
}

// Unwrap is allowed here because of the trait.
#[allow(clippy::unwrap_used)]
impl From<OsString> for Compiler {
    fn from(compiler: OsString) -> Self {
        match compiler.to_str().unwrap() {
            "zksolc" => Compiler::ZKSolc,
            "solc" => Compiler::Solc,
            _ => panic!("Invalid compiler"),
        }
    }
}

#[derive(Debug)]
pub enum Artifact {
    ZKSArtifact(ZKSArtifact),
    SolcArtifact(ConfigurableContractArtifact),
}

#[allow(dead_code)]
impl Artifact {
    pub fn abi(&self) -> eyre::Result<Abi> {
        match self {
            Artifact::ZKSArtifact(artifact) => artifact.abi.clone().context("abi not found"),
            Artifact::SolcArtifact(artifact) => {
                Ok(artifact.abi.clone().context("abi not found")?.abi)
            }
        }
    }

    pub fn bin(&self) -> eyre::Result<Bytes> {
        match self {
            Artifact::ZKSArtifact(artifact) => artifact.bin.clone().context("bytecode not found"),
            Artifact::SolcArtifact(artifact) => Ok(artifact
                .bytecode
                .clone()
                .context("bytecode not found")?
                .object
                .as_bytes()
                .context("empty object")?
                .clone()),
        }
    }
}

pub fn compile(
    project_root: &str,
    contract_path: &str,
    contract_name: &str,
    compiler: Compiler,
) -> eyre::Result<Artifact> {
    match compiler {
        Compiler::ZKSolc => compile_with_zksolc(project_root, contract_path, contract_name),
        Compiler::Solc => compile_with_solc(contract_path, contract_name),
    }
}

fn compile_with_zksolc(
    project_root: &str,
    contract_path: &str,
    contract_name: &str,
) -> eyre::Result<Artifact> {
    let root = PathBuf::from(project_root);
    let zk_project = ZKSProject::from(
        Project::builder()
            .paths(ProjectPathsConfig::builder().build_with_root(root))
            .set_auto_detect(true)
            .build()?,
    );
    let compilation_output = zk_project.compile()?;
    let artifact = compilation_output
        .find_contract(ContractInfo::from_str(&format!(
            "{contract_path}:{contract_name}"
        ))?)
        .context("contract not found in compilation output")?
        .clone();
    Ok(Artifact::ZKSArtifact(artifact))
}

fn compile_with_solc(contract_path: &str, contract_name: &str) -> eyre::Result<Artifact> {
    let root = PathBuf::from(contract_path);
    let project = Project::builder()
        .paths(ProjectPathsConfig::builder().build_with_root(root))
        .set_auto_detect(true)
        .build()?;
    let compilation_output = project.compile()?;
    let artifact = compilation_output
        .find_contract(ContractInfo::from_str(&format!(
            "{contract_path}:{contract_name}"
        ))?)
        .context("contract not found in compilation output")?
        .clone();
    Ok(Artifact::SolcArtifact(artifact))
}

#[allow(dead_code)]
pub fn build(contract_path: &str, compiler: Compiler) -> eyre::Result<()> {
    match compiler {
        Compiler::ZKSolc => build_with_zksolc(contract_path),
        Compiler::Solc => build_with_solc(contract_path),
    }
}

fn build_with_zksolc(contract_path: &str) -> eyre::Result<()> {
    let root = PathBuf::from(contract_path);
    let zk_project = ZKSProject::from(
        Project::builder()
            .paths(ProjectPathsConfig::builder().build_with_root(root))
            .set_auto_detect(true)
            .build()?,
    );
    zk_project.build().map_err(|e| eyre::eyre!(e))
}

fn build_with_solc(contract_path: &str) -> eyre::Result<()> {
    let root = PathBuf::from(contract_path);
    let project = Project::builder()
        .paths(ProjectPathsConfig::builder().build_with_root(root))
        .set_auto_detect(true)
        .build()?;

    let solc_path = PathBuf::from("src/compiler/bin/solc");

    let command = &mut std::process::Command::new(solc_path);
    command
        .arg("@openzeppelin/=node_modules/@openzeppelin/")
        .arg("--combined-json")
        .arg("abi,bin")
        .arg("--output-dir")
        .arg("contracts/build/")
        .arg("--")
        .args(source_files(project.root()));

    command.output()?;

    Ok(())
}
