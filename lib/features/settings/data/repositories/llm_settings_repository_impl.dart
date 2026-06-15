import '../../domain/entities/llm_config.dart';
import '../../domain/repositories/llm_settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class LlmSettingsRepositoryImpl implements LlmSettingsRepository {
  final SettingsLocalDataSource _localDataSource;
  LlmSettingsRepositoryImpl(this._localDataSource);

  @override
  Future<LlmConfig?> getLlmConfig() => _localDataSource.getLlmConfig();
  @override
  Future<void> saveLlmConfig(LlmConfig config) => _localDataSource.saveLlmConfig(config);
}
