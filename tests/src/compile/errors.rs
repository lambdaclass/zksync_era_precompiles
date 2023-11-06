#[derive(thiserror::Error, Debug)]
pub enum ZKCompilerError {
    #[error("Compilation error: {0}")]
    CompilationError(String),
}
