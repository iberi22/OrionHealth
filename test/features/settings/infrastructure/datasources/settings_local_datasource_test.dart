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
    tempDir = await Directory.systemTemp.createTemp('isar_settings_ds_test');
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

  group('SettingsLocalDataSource', () {
    group('LlmConfig', () {
      test('getLlmConfig returns null when empty', () async {
        final result = await dataSource.getLlmConfig();
        expect(result, isNull);
      });

      test('saveLlmConfig and getLlmConfig should persist and retrieve', () async {
        final config = LlmConfig(selectedModel: 'test-model');
        await dataSource.saveLlmConfig(config);

        final retrieved = await dataSource.getLlmConfig();
        expect(retrieved, isNotNull);
        expect(retrieved!.selectedModel, 'test-model');
      });
    });

    group('AppSettings', () {
      test('getAppSettings returns null when empty', () async {
        final result = await dataSource.getAppSettings();
        expect(result, isNull);
      });

      test('saveAppSettings and getAppSettings should persist and retrieve', () async {
        final settings = AppSettings(themeMode: 'light', languageCode: 'en');
        await dataSource.saveAppSettings(settings);

        final retrieved = await dataSource.getAppSettings();
        expect(retrieved, isNotNull);
        expect(retrieved!.themeMode, 'light');
        expect(retrieved.languageCode, 'en');
      });

      test('saveAppSettings updates existing settings', () async {
        final settings1 = AppSettings(themeMode: 'dark');
        await dataSource.saveAppSettings(settings1);

        final retrieved1 = await dataSource.getAppSettings();
        final id = retrieved1!.id;

        final settings2 = retrieved1.copyWith(themeMode: 'light');
        await dataSource.saveAppSettings(settings2);

        final retrieved2 = await dataSource.getAppSettings();
        expect(retrieved2!.themeMode, 'light');
        expect(retrieved2.id, id);

        final count = await isar.appSettings.count();
        expect(count, 1);
      });
    });
  });
}
