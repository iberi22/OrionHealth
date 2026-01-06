use crate::error::{OrionError, Result};
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use tokio::fs;
use tokio::io::AsyncWriteExt;

/// Information about a downloaded or available model
#[derive(Debug, Clone)]
pub struct ModelInfo {
    pub id: String,
    pub name: String,
    pub size_bytes: u64,
    pub version: String,
    pub path: Option<PathBuf>,
    pub is_downloaded: bool,
}

/// Progress callback for model downloads
#[derive(Debug, Clone)]
pub struct DownloadProgress {
    pub downloaded_bytes: u64,
    pub total_bytes: u64,
    pub percentage: f32,
}

/// Manages local LLM model downloads, caching, and lifecycle
pub struct ModelManager {
    models_dir: PathBuf,
    cache: HashMap<String, ModelInfo>,
}

impl ModelManager {
    /// Create a new ModelManager with the specified models directory
    pub fn new(models_dir: PathBuf) -> Self {
        Self {
            models_dir,
            cache: HashMap::new(),
        }
    }

    /// Initialize the model manager, creating directories if needed
    pub async fn init(&mut self) -> Result<()> {
        fs::create_dir_all(&self.models_dir)
            .await
            .map_err(OrionError::Io)?;

        // Scan existing models
        self.refresh_cache().await?;

        Ok(())
    }

    /// Refresh the cache by scanning the models directory
    async fn refresh_cache(&mut self) -> Result<()> {
        self.cache.clear();

        let mut entries = fs::read_dir(&self.models_dir)
            .await
            .map_err(OrionError::Io)?;

        while let Some(entry) = entries.next_entry().await.map_err(OrionError::Io)? {
            let path = entry.path();
            if path.is_file() {
                if let Some(file_name) = path.file_name().and_then(|n| n.to_str()) {
                    if file_name.ends_with(".gguf") {
                        let metadata = fs::metadata(&path).await.map_err(OrionError::Io)?;

                        let model_id = file_name.trim_end_matches(".gguf").to_string();
                        let model_info = ModelInfo {
                            id: model_id.clone(),
                            name: file_name.to_string(),
                            size_bytes: metadata.len(),
                            version: "local".to_string(),
                            path: Some(path.clone()),
                            is_downloaded: true,
                        };

                        self.cache.insert(model_id, model_info);
                    }
                }
            }
        }

        Ok(())
    }

    /// Download Phi-3-mini model from HuggingFace Hub
    /// Model: microsoft/Phi-3-mini-4k-instruct-gguf
    /// File: Phi-3-mini-4k-instruct-q4.gguf (approximately 1.8GB)
    pub async fn download_phi3_mini<F>(&mut self, progress_callback: F) -> Result<PathBuf>
    where
        F: Fn(DownloadProgress) + Send + Sync,
    {
        let model_id = "microsoft/Phi-3-mini-4k-instruct-gguf";
        let file_name = "Phi-3-mini-4k-instruct-q4.gguf";
        let destination = self.models_dir.join(file_name);

        // Check if already downloaded
        if destination.exists() {
            return Ok(destination);
        }

        // Build HuggingFace Hub URL
        let url = format!(
            "https://huggingface.co/{}/resolve/main/{}",
            model_id, file_name
        );

        // Download with progress tracking
        let client = reqwest::Client::new();
        let response = client
            .get(&url)
            .send()
            .await
            .map_err(|e| OrionError::Unknown(e.to_string()))?;

        if !response.status().is_success() {
            return Err(OrionError::Unknown(format!(
                "Failed to download model: HTTP {}",
                response.status()
            )));
        }

        let total_bytes = response.content_length().unwrap_or(0);
        let mut downloaded_bytes: u64 = 0;

        let mut file = fs::File::create(&destination)
            .await
            .map_err(OrionError::Io)?;

        let mut stream = response.bytes_stream();
        use futures_util::StreamExt;

        while let Some(chunk) = stream.next().await {
            let chunk = chunk.map_err(|e| OrionError::Unknown(e.to_string()))?;
            file.write_all(&chunk).await.map_err(OrionError::Io)?;

            downloaded_bytes += chunk.len() as u64;
            let percentage = if total_bytes > 0 {
                (downloaded_bytes as f32 / total_bytes as f32) * 100.0
            } else {
                0.0
            };

            progress_callback(DownloadProgress {
                downloaded_bytes,
                total_bytes,
                percentage,
            });
        }

        file.flush().await.map_err(OrionError::Io)?;

        // Update cache
        self.refresh_cache().await?;

        Ok(destination)
    }

    /// Download a generic model from HuggingFace Hub
    pub async fn download_model<F>(
        &mut self,
        repo_id: &str,
        file_name: &str,
        progress_callback: F,
    ) -> Result<PathBuf>
    where
        F: Fn(DownloadProgress) + Send + Sync,
    {
        let destination = self.models_dir.join(file_name);

        // Check if already downloaded
        if destination.exists() {
            return Ok(destination);
        }

        let url = format!(
            "https://huggingface.co/{}/resolve/main/{}",
            repo_id, file_name
        );

        let client = reqwest::Client::new();
        let response = client
            .get(&url)
            .send()
            .await
            .map_err(|e| OrionError::Unknown(e.to_string()))?;

        if !response.status().is_success() {
            return Err(OrionError::Unknown(format!(
                "Failed to download model: HTTP {}",
                response.status()
            )));
        }

        let total_bytes = response.content_length().unwrap_or(0);
        let mut downloaded_bytes: u64 = 0;

        let mut file = fs::File::create(&destination)
            .await
            .map_err(OrionError::Io)?;

        let mut stream = response.bytes_stream();
        use futures_util::StreamExt;

        while let Some(chunk) = stream.next().await {
            let chunk = chunk.map_err(|e| OrionError::Unknown(e.to_string()))?;
            file.write_all(&chunk).await.map_err(OrionError::Io)?;

            downloaded_bytes += chunk.len() as u64;
            let percentage = if total_bytes > 0 {
                (downloaded_bytes as f32 / total_bytes as f32) * 100.0
            } else {
                0.0
            };

            progress_callback(DownloadProgress {
                downloaded_bytes,
                total_bytes,
                percentage,
            });
        }

        file.flush().await.map_err(OrionError::Io)?;

        // Update cache
        self.refresh_cache().await?;

        Ok(destination)
    }

    /// List all downloaded models
    pub fn list_downloaded(&self) -> Vec<&ModelInfo> {
        self.cache.values().filter(|m| m.is_downloaded).collect()
    }

    /// List all available models (including predefined ones)
    pub fn list_available(&self) -> Vec<ModelInfo> {
        let mut available = vec![ModelInfo {
            id: "phi3-mini-4k".to_string(),
            name: "Phi-3-mini-4k-instruct".to_string(),
            size_bytes: 1_800_000_000, // ~1.8GB
            version: "q4".to_string(),
            path: None,
            is_downloaded: self.cache.contains_key("Phi-3-mini-4k-instruct-q4"),
        }];

        // Add downloaded models not in predefined list
        for model in self.cache.values() {
            if !available.iter().any(|m| m.id == model.id) {
                available.push(model.clone());
            }
        }

        available
    }

    /// Get the path to a downloaded model
    pub fn get_model_path(&self, model_id: &str) -> Result<PathBuf> {
        self.cache
            .get(model_id)
            .and_then(|m| m.path.clone())
            .ok_or_else(|| OrionError::NotFound(format!("Model not found: {}", model_id)))
    }

    /// Delete a downloaded model
    pub async fn delete_model(&mut self, model_id: &str) -> Result<()> {
        let path = self.get_model_path(model_id)?;

        fs::remove_file(&path).await.map_err(OrionError::Io)?;

        self.cache.remove(model_id);

        Ok(())
    }

    /// Get the models directory path
    pub fn models_dir(&self) -> &Path {
        &self.models_dir
    }

    /// Check if a model is downloaded
    pub fn is_downloaded(&self, model_id: &str) -> bool {
        self.cache
            .get(model_id)
            .map(|m| m.is_downloaded)
            .unwrap_or(false)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[tokio::test]
    async fn test_model_manager_init() {
        let temp_dir = TempDir::new().unwrap();
        let mut manager = ModelManager::new(temp_dir.path().to_path_buf());

        assert!(manager.init().await.is_ok());
        assert!(temp_dir.path().exists());
    }

    #[tokio::test]
    async fn test_list_available_models() {
        let temp_dir = TempDir::new().unwrap();
        let mut manager = ModelManager::new(temp_dir.path().to_path_buf());
        manager.init().await.unwrap();

        let available = manager.list_available();
        assert!(!available.is_empty());
        assert!(available.iter().any(|m| m.id == "phi3-mini-4k"));
    }

    #[tokio::test]
    async fn test_model_not_found() {
        let temp_dir = TempDir::new().unwrap();
        let mut manager = ModelManager::new(temp_dir.path().to_path_buf());
        manager.init().await.unwrap();

        let result = manager.get_model_path("nonexistent");
        assert!(result.is_err());
    }
}
