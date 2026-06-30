import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/settings/infrastructure/datasources/settings_local_datasource.dart';
import 'package:orionhealth_health/features/settings/domain/entities/app_settings.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';

void main() {
  late Isar isar;
  late SettingsLocalDataSource dataSource;
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
    tempDir = await Directory.systemTemp.createTemp('isar_settings_ds_infra_test');
  });

  tearDownAll(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    isar = await Isar.open(
      [LlmConfigSchema, AppSettingsSchema],
      directory: tempDir.path,
    );
    dataSource = SettingsLocalDataSource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('SettingsLocalDataSource Infrastructure Test', () {
    test('getLlmConfig returns persisted config', () async {
      final config = LlmConfig(selectedModel: 'infra-test');
      await dataSource.saveLlmConfig(config);

      final result = await dataSource.getLlmConfig();
      expect(result?.selectedModel, 'infra-test');
    });

    test('getAppSettings returns persisted settings', () async {
      final settings = AppSettings(themeMode: 'system');
      await dataSource.saveAppSettings(settings);

      final result = await dataSource.getAppSettings();
      expect(result?.themeMode, 'system');
    });

    test('saveLlmConfig updates existing config', () async {
      final config1 = LlmConfig(selectedModel: 'model1');
      await dataSource.saveLlmConfig(config1);

      final saved1 = await dataSource.getLlmConfig();
      final id = saved1!.id;

      final config2 = saved1.copyWith(selectedModel: 'model2');
      await dataSource.saveLlmConfig(config2);

      final saved2 = await dataSource.getLlmConfig();
      expect(saved2!.selectedModel, 'model2');
      expect(saved2.id, id);
    });
  });
}
