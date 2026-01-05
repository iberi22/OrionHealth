/// Common data models for OrionHealth
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

/// Node metadata structure for hierarchical storage
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NodeMetadata {
    pub created_at: DateTime<Utc>,
    pub record_type: String, // "symptom", "diagnosis", "medication", "vital_sign"
    pub patient_id: String,
    pub layer: u8,
    pub summary_of: Option<Vec<String>>, // IDs of nodes this summarizes
}

/// Search strategy enum
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum SearchStrategy {
    BM25,      // Keyword matching for specific medical terms
    Recency,   // Time-based prioritization
    Diversity, // Maximize variety in results
    MMR,       // Maximal Marginal Relevance (balanced)
}

impl SearchStrategy {
    /// Convert strategy to user-facing explanation in Spanish
    pub fn explain(&self) -> &'static str {
        match self {
            SearchStrategy::BM25 => {
                "Usando BM25: Tu consulta contiene términos médicos específicos. \
                Esta estrategia prioriza coincidencias exactas de palabras clave."
            }
            SearchStrategy::Recency => {
                "Usando Recency: Tu consulta busca información reciente. \
                Esta estrategia prioriza los registros más nuevos."
            }
            SearchStrategy::Diversity => {
                "Usando Diversity: Tu consulta es exploratoria. \
                Esta estrategia maximiza la variedad de resultados."
            }
            SearchStrategy::MMR => {
                "Usando MMR (Maximal Marginal Relevance): Esta estrategia \
                balancea relevancia y diversidad para resultados óptimos."
            }
        }
    }
}

/// Multi-hop search result
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MultiHopResult {
    pub node_id: String,
    pub content: String,
    pub layer: u8,
    pub context: Vec<ContextNode>,
    pub relevance_score: f32,
}

/// Context node for multi-hop results
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContextNode {
    pub node_id: String,
    pub content: String,
    pub layer: u8,
}

/// Smart search result
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SmartSearchResult {
    pub query: String,
    pub strategy: SearchStrategy,
    pub direct_results: Vec<String>,
    pub hierarchical_results: Vec<MultiHopResult>,
    pub search_time: DateTime<Utc>,
}

impl SmartSearchResult {
    /// Get total number of unique results
    pub fn total_results(&self) -> usize {
        self.direct_results.len() + self.hierarchical_results.len()
    }

    /// Check if hierarchical context is available
    pub fn has_hierarchical_context(&self) -> bool {
        self.hierarchical_results
            .iter()
            .any(|r| !r.context.is_empty())
    }
}

/// Summary type enum
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum SummaryType {
    Weekly,
    Monthly,
    Quarterly,
}

impl std::fmt::Display for SummaryType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            SummaryType::Weekly => write!(f, "semanal"),
            SummaryType::Monthly => write!(f, "mensual"),
            SummaryType::Quarterly => write!(f, "trimestral"),
        }
    }
}

/// Health summary report
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HealthSummaryReport {
    pub period: String,
    pub total_records: usize,
    pub summary_node_id: Option<String>,
    pub key_insights: Vec<String>,
    pub recommendations: Vec<String>,
    pub used_llm: bool,
}

/// Medical record node
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MedicalNode {
    pub id: String,
    pub content: String,
    pub metadata: NodeMetadata,
    pub embedding: Option<Vec<f32>>,
}
