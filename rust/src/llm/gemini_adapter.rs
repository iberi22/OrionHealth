use crate::error::{OrionError, Result};
use crate::llm::{create_summary_prompt, LlmAdapter};
use crate::models::SummaryType;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tokio::sync::RwLock;

/// Gemini API configuration
#[derive(Debug, Clone)]
pub struct GeminiConfig {
    pub api_key: String,
    pub model: String,
    pub endpoint: String,
}

impl Default for GeminiConfig {
    fn default() -> Self {
        Self {
            api_key: String::new(),
            model: "gemini-1.5-flash".to_string(),
            endpoint: "https://generativelanguage.googleapis.com/v1beta".to_string(),
        }
    }
}

/// Usage tracking for cloud API calls
#[derive(Debug, Clone, Default)]
pub struct UsageStats {
    pub total_tokens: u64,
    pub prompt_tokens: u64,
    pub completion_tokens: u64,
    pub requests_count: u64,
}

/// Gemini API request payload
#[derive(Debug, Serialize)]
struct GeminiRequest {
    contents: Vec<Content>,
    #[serde(skip_serializing_if = "Option::is_none")]
    generation_config: Option<GenerationConfig>,
}

#[derive(Debug, Serialize)]
struct Content {
    parts: Vec<Part>,
}

#[derive(Debug, Serialize)]
struct Part {
    text: String,
}

#[derive(Debug, Serialize)]
struct GenerationConfig {
    temperature: f32,
    top_p: f32,
    max_output_tokens: u32,
}

/// Gemini API response
#[derive(Debug, Deserialize)]
struct GeminiResponse {
    candidates: Vec<Candidate>,
    #[serde(default)]
    usage_metadata: Option<UsageMetadata>,
}

#[derive(Debug, Deserialize)]
struct Candidate {
    content: ResponseContent,
}

#[derive(Debug, Deserialize)]
struct ResponseContent {
    parts: Vec<ResponsePart>,
}

#[derive(Debug, Deserialize)]
struct ResponsePart {
    text: String,
}

#[derive(Debug, Deserialize)]
struct UsageMetadata {
    prompt_token_count: u32,
    candidates_token_count: u32,
    total_token_count: u32,
}

/// Cloud LLM adapter using Google Gemini API
pub struct GeminiAdapter {
    config: GeminiConfig,
    client: reqwest::Client,
    usage_stats: Arc<RwLock<UsageStats>>,
}

impl GeminiAdapter {
    /// Create a new Gemini adapter with the specified configuration
    pub fn new(config: GeminiConfig) -> Self {
        Self {
            config,
            client: reqwest::Client::new(),
            usage_stats: Arc::new(RwLock::new(UsageStats::default())),
        }
    }

    /// Create with API key only (uses defaults)
    pub fn with_api_key(api_key: String) -> Self {
        Self::new(GeminiConfig {
            api_key,
            ..Default::default()
        })
    }

    /// Get current usage statistics
    pub async fn get_usage_stats(&self) -> UsageStats {
        self.usage_stats.read().await.clone()
    }

    /// Reset usage statistics
    pub async fn reset_usage_stats(&self) {
        let mut stats = self.usage_stats.write().await;
        *stats = UsageStats::default();
    }

    /// Make a request to Gemini API
    async fn make_request(
        &self,
        prompt: &str,
        temperature: f32,
        top_p: f32,
        max_tokens: u32,
    ) -> Result<String> {
        if self.config.api_key.is_empty() {
            return Err(OrionError::Llm("Gemini API key not configured".to_string()));
        }

        let url = format!(
            "{}/models/{}:generateContent?key={}",
            self.config.endpoint, self.config.model, self.config.api_key
        );

        let request_payload = GeminiRequest {
            contents: vec![Content {
                parts: vec![Part {
                    text: prompt.to_string(),
                }],
            }],
            generation_config: Some(GenerationConfig {
                temperature,
                top_p,
                max_output_tokens: max_tokens,
            }),
        };

        let response = self
            .client
            .post(&url)
            .json(&request_payload)
            .send()
            .await
            .map_err(|e| OrionError::Llm(format!("Gemini API request failed: {}", e)))?;

        if !response.status().is_success() {
            let status = response.status();
            let error_text = response.text().await.unwrap_or_default();
            return Err(OrionError::Llm(format!(
                "Gemini API error ({}): {}",
                status, error_text
            )));
        }

        let gemini_response: GeminiResponse = response
            .json()
            .await
            .map_err(|e| OrionError::Llm(format!("Failed to parse Gemini response: {}", e)))?;

        // Update usage stats
        if let Some(usage) = gemini_response.usage_metadata {
            let mut stats = self.usage_stats.write().await;
            stats.prompt_tokens += usage.prompt_token_count as u64;
            stats.completion_tokens += usage.candidates_token_count as u64;
            stats.total_tokens += usage.total_token_count as u64;
            stats.requests_count += 1;
        }

        // Extract text from first candidate
        gemini_response
            .candidates
            .first()
            .and_then(|c| c.content.parts.first())
            .map(|p| p.text.clone())
            .ok_or_else(|| OrionError::Llm("No response from Gemini".to_string()))
    }
}

#[async_trait::async_trait]
impl LlmAdapter for GeminiAdapter {
    async fn is_available(&self) -> bool {
        !self.config.api_key.is_empty()
    }

    async fn generate_text(&self, prompt: &str) -> Result<String> {
        self.make_request(prompt, 0.7, 0.9, 512).await
    }

    async fn generate_summary(
        &self,
        contents: Vec<String>,
        summary_type: SummaryType,
    ) -> Result<String> {
        let prompt = create_summary_prompt(&contents, summary_type);
        self.make_request(&prompt, 0.7, 0.9, 1024).await
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_gemini_adapter_creation() {
        let adapter = GeminiAdapter::with_api_key("test-key".to_string());
        assert!(adapter.is_available().await);
    }

    #[tokio::test]
    async fn test_gemini_adapter_no_key() {
        let adapter = GeminiAdapter::new(GeminiConfig::default());
        assert!(!adapter.is_available().await);
    }

    #[tokio::test]
    async fn test_usage_stats() {
        let adapter = GeminiAdapter::with_api_key("test-key".to_string());
        let stats = adapter.get_usage_stats().await;
        assert_eq!(stats.total_tokens, 0);
        assert_eq!(stats.requests_count, 0);
    }
}
