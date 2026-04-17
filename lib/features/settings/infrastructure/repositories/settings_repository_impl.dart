import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/llm_config.dart';
import '../../domain/repositories/settings_repository.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final Isar _isar;

  SettingsRepositoryImpl(this._isar);

  @override
  Future<LlmConfig> getLlmConfig() async {
    final config = await _isar.llmConfigs.where().findFirst();
    return config ?? LlmConfig();
  }

  @override
  Future<void> saveLlmConfig(LlmConfig config) async {
    await _isar.writeTxn(() async {
      await _isar.llmConfigs.put(config);
    });
  }
}
