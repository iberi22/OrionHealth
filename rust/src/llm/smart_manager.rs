use crate::error::{OrionError, Result};
use crate::llm::gemini_adapter::{GeminiAdapter, UsageStats};
use crate::llm::{CandleLlmAdapter, LlmAdapter};
use crate::models::SummaryType;
use std::sync::Arc;
use tokio::sync::RwLock;

/// Strategy for selecting LLM provider
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LlmStrategy {
    /// Always use local model
    LocalOnly,
    /// Always use cloud model
    CloudOnly,
    /// Auto-switch based on availability and complexity
    Hybrid,
}

/// Configuration for Smart LLM Manager
#[derive(Debug, Clone)]
pub struct SmartLlmConfig {
    pub strategy: LlmStrategy,
    pub max_monthly_tokens: u64,
    pub prefer_local_under_tokens: usize,
}

impl Default for SmartLlmConfig {
    fn default() -> Self {
        Self {
            strategy: LlmStrategy::Hybrid,
            max_monthly_tokens: 1_000_000,   // 1M tokens/month limit
            prefer_local_under_tokens: 2048, // Use local for prompts < 2K tokens
        }
    }
}

/// Smart LLM Manager that auto-switches between local and cloud
pub struct SmartLlmManager {
    config: SmartLlmConfig,
    local_adapter: Option<Arc<RwLock<CandleLlmAdapter>>>,
    cloud_adapter: Option<Arc<GeminiAdapter>>,
    network_available: Arc<RwLock<bool>>,
}

impl SmartLlmManager {
    /// Create a new Smart LLM Manager
    pub fn new(config: SmartLlmConfig) -> Self {
        Self {
            config,
            local_adapter: None,
            cloud_adapter: None,
            network_available: Arc::new(RwLock::new(true)),
        }
    }

    /// Set local model adapter
    pub fn with_local_adapter(mut self, adapter: CandleLlmAdapter) -> Self {
        self.local_adapter = Some(Arc::new(RwLock::new(adapter)));
        self
    }

    /// Set cloud adapter
    pub fn with_cloud_adapter(mut self, adapter: GeminiAdapter) -> Self {
        self.cloud_adapter = Some(Arc::new(adapter));
        self
    }

    /// Update network availability status
    pub async fn set_network_available(&self, available: bool) {
        let mut network = self.network_available.write().await;
        *network = available;
    }

    /// Check if network is available
    pub async fn is_network_available(&self) -> bool {
        *self.network_available.read().await
    }

    /// Get cloud usage statistics
    pub async fn get_cloud_usage(&self) -> Option<UsageStats> {
        if let Some(cloud) = &self.cloud_adapter {
            Some(cloud.get_usage_stats().await)
        } else {
            None
        }
    }

    /// Reset cloud usage statistics
    pub async fn reset_cloud_usage(&self) -> Result<()> {
        if let Some(cloud) = &self.cloud_adapter {
            cloud.reset_usage_stats().await;
            Ok(())
        } else {
            Err(OrionError::Llm("Cloud adapter not configured".to_string()))
        }
    }

    /// Determine which adapter to use based on current conditions
    async fn select_adapter(&self, prompt_length: usize) -> Result<AdapterChoice> {
        // Strategy: LocalOnly
        if self.config.strategy == LlmStrategy::LocalOnly {
            if self.local_adapter.is_some() {
                return Ok(AdapterChoice::Local);
            }
            return Err(OrionError::Llm(
                "Local adapter not available but strategy is LocalOnly".to_string(),
            ));
        }

        // Strategy: CloudOnly
        if self.config.strategy == LlmStrategy::CloudOnly {
            if self.cloud_adapter.is_some() && self.is_network_available().await {
                return Ok(AdapterChoice::Cloud);
            }
            return Err(OrionError::Llm(
                "Cloud adapter not available but strategy is CloudOnly".to_string(),
            ));
        }

        // Strategy: Hybrid (auto-switch logic)
        let network_available = self.is_network_available().await;
        let cloud_available = self.cloud_adapter.is_some() && network_available;
        let local_available = self.local_adapter.is_some();

        // Check cloud token limits
        let cloud_credits_ok = if let Some(usage) = self.get_cloud_usage().await {
            usage.total_tokens < self.config.max_monthly_tokens
        } else {
            true
        };

        // Decision tree
        match (cloud_available && cloud_credits_ok, local_available) {
            // Both available: choose based on prompt complexity
            (true, true) => {
                if prompt_length < self.config.prefer_local_under_tokens {
                    Ok(AdapterChoice::Local)
                } else {
                    Ok(AdapterChoice::Cloud)
                }
            }
            // Only cloud available
            (true, false) => Ok(AdapterChoice::Cloud),
            // Only local available
            (false, true) => Ok(AdapterChoice::Local),
            // None available
            (false, false) => Err(OrionError::Llm("No LLM adapter available".to_string())),
        }
    }

    /// Generate text using the best available adapter
    pub async fn generate_text(&self, prompt: &str) -> Result<(String, AdapterChoice)> {
        let choice = self.select_adapter(prompt.len()).await?;

        let result =
            match choice {
                AdapterChoice::Local => {
                    let adapter = self.local_adapter.as_ref().ok_or_else(|| {
                        OrionError::Llm("Local adapter not available".to_string())
                    })?;
                    adapter.read().await.generate_text(prompt).await?
                }
                AdapterChoice::Cloud => {
                    let adapter = self.cloud_adapter.as_ref().ok_or_else(|| {
                        OrionError::Llm("Cloud adapter not available".to_string())
                    })?;
                    adapter.generate_text(prompt).await?
                }
            };

        Ok((result, choice))
    }

    /// Generate summary using the best available adapter
    pub async fn generate_summary(
        &self,
        contents: Vec<String>,
        summary_type: SummaryType,
    ) -> Result<(String, AdapterChoice)> {
        // Estimate prompt length
        let estimated_length: usize = contents.iter().map(|c| c.len()).sum();
        let choice = self.select_adapter(estimated_length).await?;

        let result =
            match choice {
                AdapterChoice::Local => {
                    let adapter = self.local_adapter.as_ref().ok_or_else(|| {
                        OrionError::Llm("Local adapter not available".to_string())
                    })?;
                    adapter
                        .read()
                        .await
                        .generate_summary(contents, summary_type)
                        .await?
                }
                AdapterChoice::Cloud => {
                    let adapter = self.cloud_adapter.as_ref().ok_or_else(|| {
                        OrionError::Llm("Cloud adapter not available".to_string())
                    })?;
                    adapter.generate_summary(contents, summary_type).await?
                }
            };

        Ok((result, choice))
    }

    /// Check which adapter is currently preferred
    pub async fn get_preferred_adapter(&self, prompt_length: usize) -> Result<AdapterChoice> {
        self.select_adapter(prompt_length).await
    }
}

/// Represents which adapter was chosen
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AdapterChoice {
    Local,
    Cloud,
}

impl std::fmt::Display for AdapterChoice {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AdapterChoice::Local => write!(f, "Local"),
            AdapterChoice::Cloud => write!(f, "Cloud"),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    #[tokio::test]
    async fn test_smart_manager_local_only() {
        let config = SmartLlmConfig {
            strategy: LlmStrategy::LocalOnly,
            ..Default::default()
        };

        let local_adapter = CandleLlmAdapter::new(PathBuf::from("test_model.gguf"));
        let manager = SmartLlmManager::new(config).with_local_adapter(local_adapter);

        let choice = manager.select_adapter(100).await.unwrap();
        assert_eq!(choice, AdapterChoice::Local);
    }

    #[tokio::test]
    async fn test_smart_manager_hybrid_small_prompt() {
        let config = SmartLlmConfig {
            strategy: LlmStrategy::Hybrid,
            prefer_local_under_tokens: 2048,
            ..Default::default()
        };

        let local_adapter = CandleLlmAdapter::new(PathBuf::from("test_model.gguf"));
        let cloud_adapter = GeminiAdapter::with_api_key("test-key".to_string());

        let manager = SmartLlmManager::new(config)
            .with_local_adapter(local_adapter)
            .with_cloud_adapter(cloud_adapter);

        // Small prompt should prefer local
        let choice = manager.select_adapter(500).await.unwrap();
        assert_eq!(choice, AdapterChoice::Local);
    }

    #[tokio::test]
    async fn test_smart_manager_hybrid_large_prompt() {
        let config = SmartLlmConfig {
            strategy: LlmStrategy::Hybrid,
            prefer_local_under_tokens: 2048,
            ..Default::default()
        };

        let local_adapter = CandleLlmAdapter::new(PathBuf::from("test_model.gguf"));
        let cloud_adapter = GeminiAdapter::with_api_key("test-key".to_string());

        let manager = SmartLlmManager::new(config)
            .with_local_adapter(local_adapter)
            .with_cloud_adapter(cloud_adapter);

        // Large prompt should prefer cloud
        let choice = manager.select_adapter(5000).await.unwrap();
        assert_eq!(choice, AdapterChoice::Cloud);
    }

    #[tokio::test]
    async fn test_smart_manager_network_unavailable() {
        let config = SmartLlmConfig {
            strategy: LlmStrategy::Hybrid,
            ..Default::default()
        };

        let local_adapter = CandleLlmAdapter::new(PathBuf::from("test_model.gguf"));
        let cloud_adapter = GeminiAdapter::with_api_key("test-key".to_string());

        let manager = SmartLlmManager::new(config)
            .with_local_adapter(local_adapter)
            .with_cloud_adapter(cloud_adapter);

        // Simulate network unavailable
        manager.set_network_available(false).await;

        // Should fallback to local even for large prompts
        let choice = manager.select_adapter(5000).await.unwrap();
        assert_eq!(choice, AdapterChoice::Local);
    }
}
