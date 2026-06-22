import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/llm_config.dart';
import '../../domain/repositories/llm_settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/llm_config_dto.dart';

@LazySingleton(as: LlmSettingsRepository)
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
    final config = await getLlmConfig();
    final settings = await getAppSettings();

    final data = {
      'llmConfig': config != null ? LlmConfigDto.fromEntity(config).toJson() : null,
      'appSettings': settings != null
          ? {
              'themeMode': settings.themeMode,
              'languageCode': settings.languageCode,
              'notificationsEnabled': settings.notificationsEnabled,
            }
          : null,
    };

    return jsonEncode(data);
  }

  @override
  Future<void> importData(String data) async {
    final decoded = jsonDecode(data) as Map<String, dynamic>;

    if (decoded.containsKey('llmConfig') && decoded['llmConfig'] != null) {
      final configDto = LlmConfigDto.fromJson(decoded['llmConfig'] as Map<String, dynamic>);
      await saveLlmConfig(configDto.toEntity());
    }

    if (decoded.containsKey('appSettings') && decoded['appSettings'] != null) {
      final s = decoded['appSettings'] as Map<String, dynamic>;
      final settings = AppSettings(
        themeMode: s['themeMode'] as String? ?? 'dark',
        languageCode: s['languageCode'] as String? ?? 'es',
        notificationsEnabled: s['notificationsEnabled'] as bool? ?? true,
      );
      await saveAppSettings(settings);
    }
  }
}
