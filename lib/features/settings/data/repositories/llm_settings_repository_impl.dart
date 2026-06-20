import '../../domain/entities/app_settings.dart';
import '../../domain/entities/llm_config.dart';
import '../../domain/repositories/llm_settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class LlmSettingsRepositoryImpl implements LlmSettingsRepository {
  final SettingsLocalDataSource _localDataSource;
  LlmSettingsRepositoryImpl(this._localDataSource);

  @override
  Future<LlmConfig?> getLlmConfig() => _localDataSource.getLlmConfig();

  @override
  Future<void> saveLlmConfig(LlmConfig config) =>
      _localDataSource.saveLlmConfig(config);

  @override
  Future<AppSettings?> getAppSettings() => _localDataSource.getAppSettings();

  @override
  Future<void> saveAppSettings(AppSettings settings) =>
      _localDataSource.saveAppSettings(settings);

  @override
  Future<String> exportData() async {
    // Mock implementation for FHIR/JSON export
    return '{"version": "1.0", "data": "FHIR Bundle Mock"}';
  }

  @override
  Future<void> importData(String data) async {
    // Mock implementation for data import
    return;
  }
}
