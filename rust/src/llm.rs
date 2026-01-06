/// LLM adapter trait and implementations
use crate::error::{OrionError, Result};
use crate::models::SummaryType;

pub mod model_manager;
pub use model_manager::{ModelManager, ModelInfo, DownloadProgress};

/// LLM adapter trait for AI inference
#[async_trait::async_trait]
pub trait LlmAdapter: Send + Sync {
    /// Check if LLM service is available
    async fn is_available(&self) -> bool;

    /// Generate text completion
    async fn generate_text(&self, prompt: &str) -> Result<String>;

    /// Generate summary with structured output
    async fn generate_summary(
        &self,
        contents: Vec<String>,
        summary_type: SummaryType,
    ) -> Result<String>;
}

/// Mock LLM adapter for testing
pub struct MockLlmAdapter;

#[async_trait::async_trait]
impl LlmAdapter for MockLlmAdapter {
    async fn is_available(&self) -> bool {
        false
    }

    async fn generate_text(&self, _prompt: &str) -> Result<String> {
        Err(OrionError::Llm("Mock LLM adapter - not available".to_string()))
    }

    async fn generate_summary(
        &self,
        _contents: Vec<String>,
        summary_type: SummaryType,
    ) -> Result<String> {
        Ok(format!(
            "[MOCK] Resumen {} generado automáticamente (LLM no disponible)",
            summary_type
        ))
    }
}

/// Candle-based LLM adapter for local inference
pub struct CandleLlmAdapter {
    model_path: std::path::PathBuf,
    tokenizer: Option<tokenizers::Tokenizer>,
    device: candle_core::Device,
}

impl CandleLlmAdapter {
    /// Create a new Candle adapter with the specified model path
    pub fn new(model_path: std::path::PathBuf) -> Self {
        let device = candle_core::Device::Cpu; // Use CPU for Android compatibility
        Self {
            model_path,
            tokenizer: None,
            device,
        }
    }

    /// Initialize the adapter by loading tokenizer
    pub async fn init(&mut self) -> Result<()> {
        // For now, use a simple tokenizer stub
        // In production, load from model directory or HuggingFace cache
        // let tokenizer_path = self.model_path.parent()
        //     .unwrap_or(&self.model_path)
        //     .join("tokenizer.json");
        
        // TODO: Load actual tokenizer from file
        // self.tokenizer = Some(tokenizers::Tokenizer::from_file(tokenizer_path)
        //     .map_err(|e| OrionError::Llm(format!("Failed to load tokenizer: {}", e)))?);
        
        Ok(())
    }

    /// Generate text with temperature and sampling parameters
    async fn generate_with_params(
        &self,
        prompt: &str,
        max_tokens: usize,
        _temperature: f64,
        _top_p: f64,
    ) -> Result<String> {
        // TODO: Once tokenizer is loaded, tokenize input
        // let tokenizer = self.tokenizer.as_ref()
        //     .ok_or_else(|| OrionError::Llm("Tokenizer not initialized".to_string()))?;
        
        // let encoding = tokenizer
        //     .encode(prompt, false)
        //     .map_err(|e| OrionError::Llm(format!("Tokenization failed: {}", e)))?;
        
        // let input_ids = encoding.get_ids();

        // TODO: Load GGUF model and run inference with Candle
        // This requires implementing the full Phi-3 architecture in Candle
        // For now, return a placeholder indicating the model path
        
        Ok(format!(
            "[Candle Inference Stub] Model: {:?}, Prompt length: {}, Max output: {}",
            self.model_path.file_name().unwrap_or_default(),
            prompt.len(),
            max_tokens
        ))
    }
}

#[async_trait::async_trait]
impl LlmAdapter for CandleLlmAdapter {
    async fn is_available(&self) -> bool {
        self.model_path.exists() && self.tokenizer.is_some()
    }

    async fn generate_text(&self, prompt: &str) -> Result<String> {
        self.generate_with_params(prompt, 512, 0.7, 0.9).await
    }

    async fn generate_summary(
        &self,
        contents: Vec<String>,
        summary_type: SummaryType,
    ) -> Result<String> {
        let prompt = create_summary_prompt(&contents, summary_type);
        self.generate_with_params(&prompt, 1024, 0.7, 0.9).await
    }
}

/// Create LLM prompt for medical summaries
pub fn create_summary_prompt(contents: &[String], summary_type: SummaryType) -> String {
    let joined_contents = contents.join("\n\n");

    format!(
        r#"Genera un resumen {} de los siguientes registros médicos:

{}

El resumen debe incluir:
- Principales diagnósticos o síntomas
- Medicamentos prescritos y cambios en tratamientos
- Resultados de análisis o estudios relevantes
- Tendencias observadas en signos vitales
- Recomendaciones o seguimientos pendientes

Formato: Texto estructurado y claro para el paciente."#,
        summary_type, joined_contents
    )
}
