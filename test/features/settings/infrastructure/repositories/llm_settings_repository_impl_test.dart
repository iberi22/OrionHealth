import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/settings/domain/entities/app_settings.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';
import 'package:orionhealth_health/features/settings/data/repositories/llm_settings_repository_impl.dart';
import 'package:orionhealth_health/features/settings/data/datasources/settings_local_datasource.dart';

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
      [LlmConfigSchema, AppSettingsSchema],
      directory: tempDir.path,
    );
    repository = LlmSettingsRepositoryImpl(SettingsLocalDataSource(isar));
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
      final config = LlmConfig(selectedModel: 'model1');
      await repository.saveLlmConfig(config);

      final retrieved = await repository.getLlmConfig();
      expect(retrieved, isNotNull);
      expect(retrieved!.selectedModel, 'model1');
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

    group('AppSettings', () {
      test('getAppSettings returns null when no settings exist', () async {
        final result = await repository.getAppSettings();
        expect(result, isNull);
      });

      test('saveAppSettings and getAppSettings should persist and retrieve settings', () async {
        final settings = AppSettings(
          themeMode: 'light',
          languageCode: 'en',
          notificationsEnabled: false,
        );

        await repository.saveAppSettings(settings);

        final retrieved = await repository.getAppSettings();
        expect(retrieved, isNotNull);
        expect(retrieved!.themeMode, 'light');
        expect(retrieved.languageCode, 'en');
        expect(retrieved.notificationsEnabled, false);
      });

      test('saveAppSettings should update existing settings and preserve record count', () async {
        final settings1 = AppSettings(themeMode: 'dark');
        await repository.saveAppSettings(settings1);

        final retrieved1 = await repository.getAppSettings();
        expect(retrieved1, isNotNull);
        final originalId = retrieved1!.id;

        final settings2 = retrieved1.copyWith(themeMode: 'light');
        await repository.saveAppSettings(settings2);

        final retrieved2 = await repository.getAppSettings();
        expect(retrieved2!.themeMode, 'light');
        expect(retrieved2.id, originalId);

        final count = await isar.appSettings.count();
        expect(count, 1);
      });
    });

    group('Data Portability', () {
      test('exportData returns a mock FHIR bundle string', () async {
        final result = await repository.exportData();
        expect(result, isA<String>());
        expect(result, contains('FHIR Bundle Mock'));
      });

      test('importData completes without error', () async {
        expect(repository.importData('dummy data'), completes);
      });
    });
  });
}
