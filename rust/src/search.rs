/// Smart search implementation
use crate::error::Result;
use crate::models::{SearchStrategy, SmartSearchResult};
use crate::vector_store::VectorStoreService;
use std::sync::Arc;

/// Smart search use case
pub struct SmartSearch {
    vector_store: Arc<VectorStoreService>,
}

impl SmartSearch {
    /// Create a new smart search instance
    pub fn new(vector_store: Arc<VectorStoreService>) -> Self {
        Self { vector_store }
    }

    /// Perform intelligent search with automatic strategy selection
    pub async fn execute(&self, query: &str, limit: usize) -> Result<SmartSearchResult> {
        // Determine optimal strategy
        let strategy = self.determine_optimal_strategy(query);

        // Perform search with re-ranking
        let direct_results = self
            .vector_store
            .search_with_reranking(query, limit, strategy)
            .await?;

        // Multi-hop search for comprehensive context
        let hierarchical_results = self.vector_store.multi_hop_search(query, 2, 3).await?;

        Ok(SmartSearchResult {
            query: query.to_string(),
            strategy,
            direct_results,
            hierarchical_results,
            search_time: chrono::Utc::now(),
        })
    }

    /// Determine optimal search strategy based on query characteristics
    fn determine_optimal_strategy(&self, query: &str) -> SearchStrategy {
        let lower_query = query.to_lowercase();

        // Medical terminology → BM25
        let medical_terms = vec![
            "diagnóstico",
            "síntoma",
            "medicamento",
            "tratamiento",
            "prescripción",
            "dosis",
            "análisis",
            "resultado",
            "diabetes",
            "hipertensión",
            "alergia",
            "dolor",
        ];

        if medical_terms.iter().any(|term| lower_query.contains(term)) {
            return SearchStrategy::BM25;
        }

        // Temporal queries → Recency
        let temporal_keywords = [
            "reciente",
            "último",
            "actual",
            "hoy",
            "ayer",
            "esta semana",
            "este mes",
            "nuevo",
        ];

        if temporal_keywords.iter().any(|kw| lower_query.contains(kw)) {
            return SearchStrategy::Recency;
        }

        // Exploratory queries → Diversity
        let exploratory_keywords = [
            "todos",
            "diferentes",
            "variedad",
            "tipos",
            "opciones",
            "alternativas",
            "qué más",
        ];

        if exploratory_keywords
            .iter()
            .any(|kw| lower_query.contains(kw))
        {
            return SearchStrategy::Diversity;
        }

        // Default: MMR
        SearchStrategy::MMR
    }

    /// Compare different strategies side-by-side
    pub async fn compare_strategies(
        &self,
        query: &str,
        limit: usize,
    ) -> Result<std::collections::HashMap<String, Vec<String>>> {
        let strategies = vec![
            SearchStrategy::BM25,
            SearchStrategy::MMR,
            SearchStrategy::Diversity,
            SearchStrategy::Recency,
        ];

        let mut results = std::collections::HashMap::new();

        for strategy in strategies {
            match self
                .vector_store
                .search_with_reranking(query, limit, strategy)
                .await
            {
                Ok(strategy_results) => {
                    results.insert(format!("{:?}", strategy).to_lowercase(), strategy_results);
                }
                Err(e) => {
                    results.insert(
                        format!("{:?}", strategy).to_lowercase(),
                        vec![format!("Error: {}", e)],
                    );
                }
            }
        }

        Ok(results)
    }
}
