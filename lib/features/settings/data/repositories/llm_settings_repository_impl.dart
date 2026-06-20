import 'package:injectable/injectable.dart';
import '../../domain/entities/llm_config.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/llm_settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

@Injectable(as: LlmSettingsRepository)
class LlmSettingsRepositoryImpl implements LlmSettingsRepository {
  final SettingsLocalDataSource _localDataSource;
  LlmSettingsRepositoryImpl(this._localDataSource);

  @override
  Future<LlmConfig?> getLlmConfig() => _localDataSource.getLlmConfig();

  @override
  Future<void> saveLlmConfig(LlmConfig config) => _localDataSource.saveLlmConfig(config);

  @override
  Future<AppSettings?> getAppSettings() async {
    // TODO: implement when AppSettings local datasource is ready
    return null;
  }

  @override
  Future<void> saveAppSettings(AppSettings settings) async {
    // TODO: implement when AppSettings local datasource is ready
  }

  @override
  Future<String> exportData() async {
    // TODO: implement export functionality
    return '{}';
  }

  @override
  Future<void> importData(String data) async {
    // TODO: implement import functionality
  }
}
