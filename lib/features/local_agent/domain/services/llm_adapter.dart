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

  /// Install a model from a network url.
  /// Returns a stream of progress percentages (0–100).
  Stream<int> installModel({
    required String modelId,
    required String url,
  });

  /// List all installed model file identifiers.
  Future<List<String>> listInstalledModels();

  /// Uninstall (delete) a model from disk.
  Future<void> uninstallModel(String modelId);

  /// Stop an active download.
  Future<void> cancelDownload(String modelId);

  /// Check whether a model (by its identifier) is installed.
  Future<bool> isModelInstalled(String modelId);
}
