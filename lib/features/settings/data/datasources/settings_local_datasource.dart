import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/llm_config.dart';

@lazySingleton
class SettingsLocalDataSource {
  final Isar _isar;
  SettingsLocalDataSource(this._isar);

  Future<LlmConfig?> getLlmConfig() =>
      _isar.llmConfigs.where().findFirst();

  Future<void> saveLlmConfig(LlmConfig config) =>
      _isar.writeTxn(() async => _isar.llmConfigs.put(config));
}
