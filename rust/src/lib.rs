pub mod api;
mod frb_generated;

// Core modules
pub mod database;
pub mod vector_store;
pub mod llm;
pub mod search;
pub mod health;
pub mod models;
pub mod error;

// Re-exports
pub use error::{Result, OrionError};

