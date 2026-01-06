---
title: "Legacy Logic Reference - Dart to Rust Migration"
type: SPECIFICATION
id: "spec-legacy-logic"
created: 2026-01-05
updated: 2026-01-05
summary: |
  Reference documentation for business logic, prompts, and strategies
  from the original Dart implementation to guide Rust refactoring.
keywords: [legacy, migration, rust, business-logic, ai-prompts]
tags: ["#migration", "#rust", "#refactoring"]
project: OrionHealth
---

# 📚 Legacy Logic Reference - Dart to Rust Migration

## Purpose
This document preserves the business logic, AI prompts, and algorithmic strategies from the original Dart/Flutter implementation of OrionHealth. It serves as a reference during the migration to a Rust-based backend with SurrealDB and local LLM inference.

---

## 1. Smart Search Strategies

### Overview
The `SmartSearchUseCase` implements intelligent search using multiple re-ranking strategies optimized for medical queries.

### Strategy Selection Algorithm

```rust
// Pseudo-Rust implementation
fn determine_optimal_strategy(query: &str) -> SearchStrategy {
    let lower_query = query.to_lowercase();

    // Medical terminology → BM25 (precise keyword matching)
    let medical_terms = vec![
        "diagnóstico", "síntoma", "medicamento", "tratamiento",
        "prescripción", "dosis", "análisis", "resultado",
        "diabetes", "hipertensión", "alergia", "dolor",
    ];

    if medical_terms.iter().any(|term| lower_query.contains(term)) {
        return SearchStrategy::BM25;
    }

    // Temporal queries → Recency
    let temporal_keywords = vec![
        "reciente", "último", "actual", "hoy", "ayer",
        "esta semana", "este mes", "nuevo",
    ];

    if temporal_keywords.iter().any(|kw| lower_query.contains(kw)) {
        return SearchStrategy::Recency;
    }

    // Exploratory queries → Diversity
    let exploratory_keywords = vec![
        "todos", "diferentes", "variedad", "tipos",
        "opciones", "alternativas", "qué más",
    ];

    if exploratory_keywords.iter().any(|kw| lower_query.contains(kw)) {
        return SearchStrategy::Diversity;
    }

    // Default: MMR (balanced relevance + diversity)
    SearchStrategy::MMR
}

enum SearchStrategy {
    BM25,      // Keyword matching for specific medical terms
    Recency,   // Time-based prioritization
    Diversity, // Maximize variety in results
    MMR,       // Maximal Marginal Relevance (balanced)
}
```

### Strategy Explanations (for UI feedback)

| Strategy | User-Facing Explanation (Spanish) |
|----------|-----------------------------------|
| **BM25** | "Usando BM25: Tu consulta contiene términos médicos específicos. Esta estrategia prioriza coincidencias exactas de palabras clave." |
| **Recency** | "Usando Recency: Tu consulta busca información reciente. Esta estrategia prioriza los registros más nuevos." |
| **Diversity** | "Usando Diversity: Tu consulta es exploratoria. Esta estrategia maximiza la variedad de resultados." |
| **MMR** | "Usando MMR (Maximal Marginal Relevance): Esta estrategia balancea relevancia y diversidad para resultados óptimos." |

### Search Parameters
- **Default Limit:** 5 results
- **Multi-hop Search:**
  - Max hops: 2
  - Top K per hop: 3
- **Strategy Comparison:** Compare all 4 strategies with 3 results each

---

## 2. Health Summary Generation

### Overview
The `GenerateHealthSummaryUseCase` creates comprehensive health summaries for time periods using hierarchical RAG (HiRAG Phase 2).

### Summary Generation Process

```rust
// Pseudo-Rust implementation
async fn generate_health_summary(
    start_date: DateTime,
    end_date: DateTime,
    summary_type: SummaryType, // Weekly, Monthly, Quarterly
) -> Result<HealthSummaryReport, Error> {

    // Step 1: Query base layer nodes (layer 0)
    let base_nodes = vector_store.get_nodes_by_layer(0).await?;

    // Step 2: Filter by date range
    let relevant_nodes: Vec<_> = base_nodes
        .into_iter()
        .filter(|node| {
            if let Some(created_at) = node.metadata.get("createdAt") {
                created_at >= start_date && created_at <= end_date
            } else {
                false
            }
        })
        .collect();

    // Step 3: Create summary if enough records and LLM available
    let summary_node_id = if relevant_nodes.len() >= 3 && llm.is_available().await {
        let summary_content = generate_summary_content(
            &relevant_nodes,
            &summary_type,
        ).await?;

        let node_ids: Vec<_> = relevant_nodes.iter()
            .map(|n| n.id.clone())
            .collect();

        Some(vector_store.create_summary_node(
            summary_content,
            node_ids,
            1, // layer
            "health_period_summary", // type
        ).await?)
    } else {
        None
    };

    // Step 4: Gather insights using multi-hop search
    let insights = gather_insights(&relevant_nodes, &summary_type).await?;

    // Step 5: Generate recommendations
    let recommendations = generate_recommendations(&insights);

    Ok(HealthSummaryReport {
        period: format!(
            "{:?}: {} - {}",
            summary_type,
            format_date(start_date),
            format_date(end_date)
        ),
        total_records: relevant_nodes.len(),
        summary_node_id,
        key_insights: insights,
        recommendations,
        used_llm: llm.is_available().await,
    })
}

enum SummaryType {
    Weekly,
    Monthly,
    Quarterly,
}
```

### LLM Prompt Template for Medical Summaries

**Spanish Version (Original):**

```text
Genera un resumen {summary_type} de los siguientes registros médicos:

{contents}

El resumen debe incluir:
- Principales diagnósticos o síntomas
- Medicamentos prescritos y cambios en tratamientos
- Resultados de análisis o estudios relevantes
- Tendencias observadas en signos vitales
- Recomendaciones o seguimientos pendientes

Formato: Texto estructurado y claro para el paciente.
```

**English Version (for reference):**

```text
Generate a {summary_type} summary of the following medical records:

{contents}

The summary should include:
- Main diagnoses or symptoms
- Prescribed medications and treatment changes
- Relevant test or study results
- Observed trends in vital signs
- Pending recommendations or follow-ups

Format: Structured and clear text for the patient.
```

### Minimum Threshold
- **Minimum Records for LLM Summarization:** 3 nodes
- **Fallback:** If LLM unavailable or < 3 records, use rule-based insights only

---

## 3. Multi-Hop Search Configuration

### Parameters
- **Max Hops:** 2 (base layer → summary layer)
- **Top K per hop:** 3 results
- **Layer Structure:**
  - Layer 0: Base facts (individual medical records)
  - Layer 1: Summaries (weekly/monthly aggregations)
  - Layer 2+: Meta-summaries (not yet implemented)

### Use Cases
1. **Contextual Search:** Find specific symptom + related diagnoses + treatment history
2. **Trend Analysis:** Identify patterns across time periods
3. **Comprehensive Patient View:** Gather all context related to a health condition

---

## 4. Data Models (for Rust Migration)

### Node Metadata Structure

```rust
struct NodeMetadata {
    created_at: DateTime<Utc>,
    record_type: String, // "symptom", "diagnosis", "medication", "vital_sign"
    patient_id: String,
    layer: u8,
    summary_of: Option<Vec<String>>, // IDs of nodes this summarizes
}
```

### Search Result Structure

```rust
struct SmartSearchResult {
    query: String,
    strategy: SearchStrategy,
    direct_results: Vec<String>,
    hierarchical_results: Vec<MultiHopResult>,
    search_time: DateTime<Utc>,
}

struct MultiHopResult {
    node_id: String,
    content: String,
    layer: u8,
    context: Vec<ContextNode>, // Parent/child nodes
    relevance_score: f32,
}
```

### Health Summary Report Structure

```rust
struct HealthSummaryReport {
    period: String,
    total_records: usize,
    summary_node_id: Option<String>,
    key_insights: Vec<String>,
    recommendations: Vec<String>,
    used_llm: bool,
}
```

---

## 5. LLM Adapter Interface (from Dart)

### Required Methods

```rust
#[async_trait]
trait LlmAdapter {
    /// Check if LLM service is available
    async fn is_available(&self) -> bool;

    /// Generate text completion
    async fn generate_text(&self, prompt: &str) -> Result<String, Error>;

    /// Generate summary with structured output
    async fn generate_summary(
        &self,
        contents: Vec<String>,
        summary_type: SummaryType,
    ) -> Result<String, Error>;
}
```

### Mock Implementation Notes
- Always returns `is_available() = false`
- Useful for testing without LLM dependency
- Should return placeholder summaries for development

---

## 6. Vector Store Service Interface (from Dart)

### Core Methods

```rust
#[async_trait]
trait VectorStoreService {
    /// Add a memory node with embeddings
    async fn add_node(
        &self,
        content: &str,
        metadata: NodeMetadata,
    ) -> Result<String, Error>;

    /// Semantic search with optional re-ranking
    async fn search_with_reranking(
        &self,
        query: &str,
        limit: usize,
        strategy: SearchStrategy,
    ) -> Result<Vec<String>, Error>;

    /// Multi-hop hierarchical search
    async fn multi_hop_search(
        &self,
        query: &str,
        max_hops: u8,
        top_k: usize,
    ) -> Result<Vec<MultiHopResult>, Error>;

    /// Create summary node (HiRAG Phase 2)
    async fn create_summary_node(
        &self,
        summary_content: String,
        source_node_ids: Vec<String>,
        layer: u8,
        node_type: &str,
    ) -> Result<String, Error>;

    /// Query nodes by hierarchical layer
    async fn get_nodes_by_layer(&self, layer: u8) -> Result<Vec<Node>, Error>;
}
```

---

## 7. Migration Priorities

### High Priority (Core Functionality)
1. ✅ Smart search with strategy selection
2. ✅ Multi-hop hierarchical search
3. ✅ Health summary generation with LLM prompts
4. ✅ Node metadata and layer management

### Medium Priority (Enhancements)
- Strategy comparison API
- Trend analysis across summaries
- Patient-specific context aggregation

### Low Priority (Future)
- Meta-summaries (Layer 2+)
- Cross-patient anonymized insights
- Predictive health alerts

---

## 8. Testing Checklist

### Unit Tests to Migrate
- [ ] Strategy selection for various query types
- [ ] Date filtering in summary generation
- [ ] Multi-hop search path correctness
- [ ] LLM prompt formatting
- [ ] Mock LLM adapter responses

### Integration Tests
- [ ] End-to-end search workflow
- [ ] Summary generation with real embeddings
- [ ] Multi-hop context retrieval
- [ ] SurrealDB persistence and queries

---

## 9. Performance Considerations

### Original Dart Performance
- Search latency: ~50-200ms (depends on index size)
- Summary generation: ~2-5s (with LLM)
- Multi-hop search: ~100-500ms (2 hops)

### Rust Performance Goals
- Search latency: < 50ms (target 2-4x improvement)
- Summary generation: < 1s (with optimized local LLM)
- Multi-hop search: < 100ms (parallel hop execution)

### Memory Constraints (Android)
- Target devices: 4-8GB RAM
- Max LLM model size: 2GB (quantized)
- SurrealDB cache: 100-500MB
- Flutter UI overhead: 100-200MB

---

## 10. References

### Original Files (Dart)
- `lib/features/local_agent/application/use_cases/smart_search_use_case.dart`
- `lib/features/local_agent/domain/services/llm_adapter.dart`
- `lib/features/local_agent/domain/services/vector_store_service.dart`
- `lib/features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart`
- `lib/features/local_agent/infrastructure/services/isar_vector_store_service.dart`

### New Rust Modules (To Be Created)
- `rust/src/search/smart_search.rs`
- `rust/src/llm/adapter.rs`
- `rust/src/vector_store/surrealdb_store.rs`
- `rust/src/health/summary_generator.rs`

---

## Notes
- All Spanish text (prompts, UI messages) should be preserved in Rust constants
- LLM prompts may need adjustment based on the chosen model (Candle vs. llama.cpp)
- SurrealDB queries will differ significantly from Isar's Dart API - needs careful migration planning
