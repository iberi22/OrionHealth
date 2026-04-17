import '../entities/llm_config.dart';

/// Repository interface for LLM settings persistence
abstract class LlmSettingsRepository {
  /// Get the current LLM configuration
  Future<LlmConfig?> getLlmConfig();

  /// Save the LLM configuration
  Future<void> saveLlmConfig(LlmConfig config);
}
