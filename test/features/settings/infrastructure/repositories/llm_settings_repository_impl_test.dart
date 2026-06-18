import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';
import 'package:orionhealth_health/features/settings/infrastructure/repositories/llm_settings_repository_impl.dart';

void main() {
  late Isar isar;
  late LlmSettingsRepositoryImpl repository;
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
    tempDir = await Directory.systemTemp.createTemp('isar_settings_test');
  });

  tearDownAll(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    isar = await Isar.open(
      [LlmConfigSchema],
      directory: tempDir.path,
    );
    repository = LlmSettingsRepositoryImpl(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('LlmSettingsRepositoryImpl', () {
    test('getLlmConfig returns null when no config exists', () async {
      final result = await repository.getLlmConfig();
      expect(result, isNull);
    });

    test('saveLlmConfig and getLlmConfig should persist and retrieve config', () async {
      final config = LlmConfig(
        selectedModel: 'test-model',
        useCloudApi: false,
      );

      await repository.saveLlmConfig(config);

      final retrieved = await repository.getLlmConfig();
      expect(retrieved, isNotNull);
      expect(retrieved!.selectedModel, 'test-model');
      expect(retrieved.useCloudApi, false);
    });

    test('saveLlmConfig should update existing config and preserve record count', () async {
      final config1 = LlmConfig(selectedModel: 'model1');
      await repository.saveLlmConfig(config1);

      final retrieved1 = await repository.getLlmConfig();
      expect(retrieved1, isNotNull);
      final originalId = retrieved1!.id;

      final config2 = retrieved1.copyWith(selectedModel: 'model2');
      await repository.saveLlmConfig(config2);

      final retrieved2 = await repository.getLlmConfig();
      expect(retrieved2!.selectedModel, 'model2');
      expect(retrieved2.id, originalId);

      final count = await isar.llmConfigs.count();
      expect(count, 1);
    });
  });
}
