/// LLM Adapter interface for integration with isar_agent_memory v0.4.0
///
/// This interface allows OrionHealth to integrate with the HiRAG Phase 2
/// automatic summarization features while maintaining hexagonal architecture.
abstract class LlmAdapter {
  /// Generate text based on a prompt
  ///
  /// This method is called by isar_agent_memory's autoSummarizeLayer()
  /// to create summaries of memory nodes.
  Future<String> generate(String prompt);

  /// Optional: Get the model name/identifier
  String get modelName;

  /// Optional: Check if the adapter is available/configured
  Future<bool> isAvailable();
}
