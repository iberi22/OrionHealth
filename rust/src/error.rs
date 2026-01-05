/// Custom error types for OrionHealth Rust backend
use thiserror::Error;

pub type Result<T> = std::result::Result<T, OrionError>;

#[derive(Error, Debug)]
pub enum OrionError {
    #[error("Database error: {0}")]
    Database(String),

    #[error("Vector store error: {0}")]
    VectorStore(String),

    #[error("LLM error: {0}")]
    Llm(String),

    #[error("Search error: {0}")]
    Search(String),

    #[error("Serialization error: {0}")]
    Serialization(#[from] serde_json::Error),

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("SurrealDB error: {0}")]
    SurrealDb(String),

    #[error("Invalid input: {0}")]
    InvalidInput(String),

    #[error("Not found: {0}")]
    NotFound(String),

    #[error("Unknown error: {0}")]
    Unknown(String),
}

// Implement conversion from surrealdb::Error
impl From<surrealdb::Error> for OrionError {
    fn from(err: surrealdb::Error) -> Self {
        OrionError::SurrealDb(err.to_string())
    }
}

// Implement conversion from anyhow::Error
impl From<anyhow::Error> for OrionError {
    fn from(err: anyhow::Error) -> Self {
        OrionError::Unknown(err.to_string())
    }
}
