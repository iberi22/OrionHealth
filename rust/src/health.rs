/// Health summary generation
use crate::error::Result;
use crate::llm::LlmAdapter;
use crate::models::{HealthSummaryReport, SummaryType};
use crate::vector_store::VectorStoreService;
use chrono::{DateTime, Utc};
use std::sync::Arc;

/// Health summary generator
pub struct HealthSummaryGenerator {
    vector_store: Arc<VectorStoreService>,
    llm_adapter: Arc<dyn LlmAdapter>,
}

impl HealthSummaryGenerator {
    /// Create a new health summary generator
    pub fn new(vector_store: Arc<VectorStoreService>, llm_adapter: Arc<dyn LlmAdapter>) -> Self {
        Self {
            vector_store,
            llm_adapter,
        }
    }

    /// Generate a comprehensive health summary for a time period
    pub async fn generate_summary(
        &self,
        start_date: DateTime<Utc>,
        end_date: DateTime<Utc>,
        summary_type: SummaryType,
    ) -> Result<HealthSummaryReport> {
        // Check if LLM is available
        let is_llm_available = self.llm_adapter.is_available().await;

        // Query base layer nodes
        let base_nodes = self.vector_store.get_nodes_by_layer(0).await?;

        // Filter by date range
        let relevant_nodes: Vec<_> = base_nodes
            .into_iter()
            .filter(|node| {
                node.metadata.created_at >= start_date && node.metadata.created_at <= end_date
            })
            .collect();

        // Create summary if enough records and LLM available
        let summary_node_id = if relevant_nodes.len() >= 3 && is_llm_available {
            let node_ids: Vec<_> = relevant_nodes.iter().map(|n| n.id.clone()).collect();

            let summary_content = self
                .generate_summary_content(&relevant_nodes, summary_type)
                .await?;

            Some(
                self.vector_store
                    .create_summary_node(summary_content, node_ids, 1, "health_period_summary")
                    .await?,
            )
        } else {
            None
        };

        // Gather insights
        let insights = self.gather_insights(&relevant_nodes, summary_type).await?;

        // Generate recommendations
        let recommendations = self.generate_recommendations(&insights);

        Ok(HealthSummaryReport {
            period: format!(
                "{}: {} - {}",
                summary_type,
                Self::format_date(start_date),
                Self::format_date(end_date)
            ),
            total_records: relevant_nodes.len(),
            summary_node_id,
            key_insights: insights,
            recommendations,
            used_llm: is_llm_available,
        })
    }

    /// Generate summary content using LLM or rule-based approach
    async fn generate_summary_content(
        &self,
        nodes: &[crate::models::MedicalNode],
        summary_type: SummaryType,
    ) -> Result<String> {
        let contents: Vec<_> = nodes.iter().map(|n| n.content.clone()).collect();

        if self.llm_adapter.is_available().await {
            self.llm_adapter
                .generate_summary(contents, summary_type)
                .await
        } else {
            // Fallback: Simple concatenation
            Ok(format!(
                "[Resumen {} automático]\n\nTotal de registros: {}\n\n{}",
                summary_type,
                nodes.len(),
                contents.join("\n\n")
            ))
        }
    }

    /// Gather insights from nodes
    async fn gather_insights(
        &self,
        nodes: &[crate::models::MedicalNode],
        _summary_type: SummaryType,
    ) -> Result<Vec<String>> {
        // Simple rule-based insights
        let mut insights = vec![];

        // Count by record type
        let mut type_counts = std::collections::HashMap::new();
        for node in nodes {
            *type_counts.entry(&node.metadata.record_type).or_insert(0) += 1;
        }

        for (record_type, count) in type_counts {
            insights.push(format!("{} registros de {}", count, record_type));
        }

        if insights.is_empty() {
            insights.push("No hay suficientes datos para generar insights".to_string());
        }

        Ok(insights)
    }

    /// Generate recommendations based on insights
    fn generate_recommendations(&self, insights: &[String]) -> Vec<String> {
        let mut recommendations = vec![];

        // Simple rule-based recommendations
        if insights.len() < 3 {
            recommendations.push(
                "Registra más información médica para obtener mejores recomendaciones".to_string(),
            );
        } else {
            recommendations.push("Mantén un registro regular de tu salud".to_string());
            recommendations.push("Consulta con tu médico para análisis detallados".to_string());
        }

        recommendations
    }

    /// Format date for display
    fn format_date(date: DateTime<Utc>) -> String {
        date.format("%Y-%m-%d").to_string()
    }
}
