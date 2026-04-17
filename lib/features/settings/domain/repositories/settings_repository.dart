import '../entities/llm_config.dart';

abstract class SettingsRepository {
  Future<LlmConfig> getLlmConfig();
  Future<void> saveLlmConfig(LlmConfig config);
}
