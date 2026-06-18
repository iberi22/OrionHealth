import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/llm_config.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/llm_settings_repository.dart';

@LazySingleton(as: LlmSettingsRepository)
class LlmSettingsRepositoryImpl implements LlmSettingsRepository {
  final Isar _isar;

  LlmSettingsRepositoryImpl(this._isar);

  @override
  Future<LlmConfig?> getLlmConfig() async {
    return await _isar.llmConfigs.where().findFirst();
  }

  @override
  Future<void> saveLlmConfig(LlmConfig config) async {
    await _isar.writeTxn(() async {
      await _isar.llmConfigs.put(config);
    });
  }

  @override
  Future<AppSettings?> getAppSettings() async {
    return await _isar.appSettings.where().findFirst();
  }

  @override
  Future<void> saveAppSettings(AppSettings settings) async {
    await _isar.writeTxn(() async {
      await _isar.appSettings.put(settings);
    });
  }

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
