/// LLM adapter trait and implementations
use crate::error::{OrionError, Result};
use crate::models::SummaryType;

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

/// Candle-based LLM adapter (placeholder for future implementation)
pub struct CandleLlmAdapter {
    // TODO: Add model loading and inference logic
}

#[async_trait::async_trait]
impl LlmAdapter for CandleLlmAdapter {
    async fn is_available(&self) -> bool {
        // TODO: Check if model is loaded
        false
    }

    async fn generate_text(&self, _prompt: &str) -> Result<String> {
        Err(OrionError::Llm("Candle LLM not yet implemented".to_string()))
    }

    async fn generate_summary(
        &self,
        _contents: Vec<String>,
        _summary_type: SummaryType,
    ) -> Result<String> {
        Err(OrionError::Llm("Candle LLM not yet implemented".to_string()))
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
