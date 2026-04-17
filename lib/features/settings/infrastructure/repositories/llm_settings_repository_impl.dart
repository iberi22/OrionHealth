import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/llm_config.dart';
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
}
