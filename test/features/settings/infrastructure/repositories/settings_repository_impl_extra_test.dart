import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/settings/domain/entities/app_settings.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';
import 'package:orionhealth_health/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:orionhealth_health/features/settings/infrastructure/datasources/settings_local_datasource.dart';

void main() {
  late Isar isar;
  late SettingsRepositoryImpl repository;
  late Directory tempDir;

  setUpAll(() async {
    // Note: Isar.initializeIsarCore(download: true) is not needed if libisar.so is in the root
    tempDir = await Directory.systemTemp.createTemp('isar_settings_extra_test');
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
    repository = SettingsRepositoryImpl(SettingsLocalDataSource(isar));
  });

  tearDown(() async {
    if (isar.isOpen) {
      await isar.close(deleteFromDisk: true);
    }
  });

  group('SettingsRepositoryImpl Extra', () {
    test('exportData returns a JSON string', () async {
      final result = await repository.exportData();
      expect(result, contains('"version"'));
      expect(result, contains('"data"'));
    });

    test('importData completes (mock)', () async {
      expect(repository.importData('{}'), completes);
    });

    test('getLlmConfig returns null if none exists', () async {
       final result = await repository.getLlmConfig();
       expect(result, isNull);
    });

    test('getAppSettings returns null if none exists', () async {
       final result = await repository.getAppSettings();
       expect(result, isNull);
    });
  });
}
