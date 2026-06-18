import '../entities/llm_config.dart';
import '../entities/app_settings.dart';

abstract class LlmSettingsRepository {
  Future<LlmConfig?> getLlmConfig();
  Future<void> saveLlmConfig(LlmConfig config);

  Future<AppSettings?> getAppSettings();
  Future<void> saveAppSettings(AppSettings settings);

  Future<String> exportData();
  Future<void> importData(String data);
}
