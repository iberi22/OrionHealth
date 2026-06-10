import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late VitalSignRepositoryImpl repository;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_vitals');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [VitalSignSchema],
      directory: testDir,
    );
    repository = VitalSignRepositoryImpl(isar);
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    await isar.writeTxn(() => isar.vitalSigns.clear());
  });

  group('VitalSignRepositoryImpl', () {
    test('saveVitalSign and getAllVitalSigns', () async {
      final vital = VitalSign(
        type: VitalSignType.heartRate,
        value: 75.0,
        dateTime: DateTime.now(),
      );

      await repository.saveVitalSign(vital);

      final results = await repository.getAllVitalSigns();
      expect(results.length, 1);
      expect(results.first.type, VitalSignType.heartRate);
      expect(results.first.value, 75.0);
    });

    test('saveVitalSigns saves multiple records', () async {
      final vitals = [
        VitalSign(type: VitalSignType.heartRate, value: 70, dateTime: DateTime.now()),
        VitalSign(type: VitalSignType.temperature, value: 36.6, dateTime: DateTime.now()),
      ];

      await repository.saveVitalSigns(vitals);

      final results = await repository.getAllVitalSigns();
      expect(results.length, 2);
    });

    test('getAllVitalSigns returns sorted by dateTime desc', () async {
      final now = DateTime.now();
      final v1 = VitalSign(type: VitalSignType.heartRate, value: 70, dateTime: now.subtract(const Duration(minutes: 10)));
      final v2 = VitalSign(type: VitalSignType.heartRate, value: 80, dateTime: now);

      await repository.saveVitalSigns([v1, v2]);

      final results = await repository.getAllVitalSigns();
      expect(results.first.value, 80);
      expect(results.last.value, 70);
    });

    test('getLatestVitals returns the most recent for each type', () async {
      final now = DateTime.now();
      await repository.saveVitalSigns([
        VitalSign(type: VitalSignType.heartRate, value: 60, dateTime: now.subtract(const Duration(hours: 1))),
        VitalSign(type: VitalSignType.heartRate, value: 70, dateTime: now),
        VitalSign(type: VitalSignType.temperature, value: 37.0, dateTime: now),
      ]);

      final latest = await repository.getLatestVitals();
      expect(latest[VitalSignType.heartRate]?.value, 70);
      expect(latest[VitalSignType.temperature]?.value, 37.0);
      expect(latest[VitalSignType.spO2], isNull);
    });
  });
}
