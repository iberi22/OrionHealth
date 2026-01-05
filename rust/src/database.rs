/// SurrealDB connection and management
use crate::error::{OrionError, Result};
use surrealdb::engine::local::Db;
use surrealdb::engine::local::Mem;
use surrealdb::Surreal;
use std::sync::Arc;
use tokio::sync::RwLock;

/// Database manager for SurrealDB
pub struct DatabaseManager {
    db: Arc<RwLock<Option<Surreal<Db>>>>,
}

impl DatabaseManager {
    /// Create a new database manager
    pub fn new() -> Self {
        Self {
            db: Arc::new(RwLock::new(None)),
        }
    }

    /// Initialize the database connection
    pub async fn init(&self) -> Result<()> {
        let db = Surreal::new::<Mem>(()).await?;

        // Use namespace and database
        db.use_ns("orionhealth").use_db("medical").await?;

        // Store the connection
        let mut lock = self.db.write().await;
        *lock = Some(db);

        Ok(())
    }

    /// Get a clone of the database connection
    pub async fn get_db(&self) -> Result<Surreal<Db>> {
        let lock = self.db.read().await;
        lock.as_ref()
            .cloned()
            .ok_or_else(|| OrionError::Database("Database not initialized".to_string()))
    }

    /// Check if database is initialized
    pub async fn is_initialized(&self) -> bool {
        self.db.read().await.is_some()
    }
}

impl Default for DatabaseManager {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_database_init() {
        let manager = DatabaseManager::new();
        assert!(!manager.is_initialized().await);

        manager.init().await.expect("Failed to initialize database");
        assert!(manager.is_initialized().await);
    }
}
