import 'package:isar/isar.dart';

part 'llm_config.g.dart';

@collection
class LlmConfig {
  Id id = Isar.autoIncrement;

  String? modelName;

  bool useLocalModel;

  String? apiKey;

  LlmConfig({
    this.modelName = 'gemma-2b',
    this.useLocalModel = true,
    this.apiKey,
  });

  LlmConfig copyWith({
    String? modelName,
    bool? useLocalModel,
    String? apiKey,
  }) {
    return LlmConfig(
      modelName: modelName ?? this.modelName,
      useLocalModel: useLocalModel ?? this.useLocalModel,
      apiKey: apiKey ?? this.apiKey,
    )..id = this.id;
  }
}
