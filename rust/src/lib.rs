pub mod api;
mod frb_generated;

// Core modules
pub mod database;
pub mod error;
pub mod health;
pub mod llm;
pub mod models;
pub mod search;
pub mod vector_store;

// Re-exports
pub use error::{OrionError, Result};
