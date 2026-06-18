import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/llm_config.dart';
import '../../domain/entities/app_settings.dart';

@lazySingleton
class SettingsLocalDataSource {
  final Isar _isar;
  SettingsLocalDataSource(this._isar);

  Future<LlmConfig?> getLlmConfig() =>
      _isar.llmConfigs.where().findFirst();

  Future<void> saveLlmConfig(LlmConfig config) =>
      _isar.writeTxn(() async => _isar.llmConfigs.put(config));

  Future<AppSettings?> getAppSettings() =>
      _isar.appSettings.where().findFirst();

  Future<void> saveAppSettings(AppSettings settings) =>
      _isar.writeTxn(() async => _isar.appSettings.put(settings));
}
