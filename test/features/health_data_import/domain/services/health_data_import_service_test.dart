import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';
import 'package:orionhealth_health/features/health_data_import/domain/services/health_data_import_service.dart';
import 'package:orionhealth_health/features/health_data_import/infrastructure/parsers/health_data_parser.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';

void main() {
  late HealthDataImportService service;

  setUp(() {
    service = HealthDataImportService();
  });

  group('HealthDataImportService - convertToVitalSigns', () {
    test('should convert various health data points to vital signs', () async {
      final date = DateTime(2023, 10, 27, 10);
      final healthData = [
        HealthDataPoint(
          uuid: 'uuid1',
          value: NumericHealthValue(numericValue: 1000),
          type: HealthDataType.STEPS,
          unit: HealthDataUnit.COUNT,
          dateFrom: date,
          dateTo: date,
          sourcePlatform: HealthPlatformType.googleHealthConnect,
          sourceDeviceId: 'deviceId',
          sourceId: 'sourceId',
          sourceName: 'sourceName',
        ),
        HealthDataPoint(
          uuid: 'uuid2',
          value: NumericHealthValue(numericValue: 72),
          type: HealthDataType.HEART_RATE,
          unit: HealthDataUnit.BEATS_PER_MINUTE,
          dateFrom: date,
          dateTo: date,
          sourcePlatform: HealthPlatformType.googleHealthConnect,
          sourceDeviceId: 'deviceId',
          sourceId: 'sourceId',
          sourceName: 'sourceName',
        ),
        HealthDataPoint(
          uuid: 'uuid3',
          value: NumericHealthValue(numericValue: 120),
          type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          unit: HealthDataUnit.MILLIMETER_OF_MERCURY,
          dateFrom: date,
          dateTo: date,
          sourcePlatform: HealthPlatformType.googleHealthConnect,
          sourceDeviceId: 'deviceId',
          sourceId: 'sourceId',
          sourceName: 'sourceName',
        ),
        HealthDataPoint(
          uuid: 'uuid4',
          value: NumericHealthValue(numericValue: 80),
          type: HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
          unit: HealthDataUnit.MILLIMETER_OF_MERCURY,
          dateFrom: date,
          dateTo: date,
          sourcePlatform: HealthPlatformType.googleHealthConnect,
          sourceDeviceId: 'deviceId',
          sourceId: 'sourceId',
          sourceName: 'sourceName',
        ),
        HealthDataPoint(
          uuid: 'uuid5',
          value: NumericHealthValue(numericValue: 98),
          type: HealthDataType.BLOOD_OXYGEN,
          unit: HealthDataUnit.PERCENT,
          dateFrom: date,
          dateTo: date,
          sourcePlatform: HealthPlatformType.googleHealthConnect,
          sourceDeviceId: 'deviceId',
          sourceId: 'sourceId',
          sourceName: 'sourceName',
        ),
      ];

      final results = await service.convertToVitalSigns(healthData, HealthDataSource.googleFit);

      expect(results.length, 5);
      expect(results.any((v) => v.type == VitalSignType.steps && v.value == 1000), isTrue);
      expect(results.any((v) => v.type == VitalSignType.heartRate && v.value == 72), isTrue);
      expect(results.any((v) => v.type == VitalSignType.bloodPressureSystolic && v.value == 120), isTrue);
      expect(results.any((v) => v.type == VitalSignType.bloodPressureDiastolic && v.value == 80), isTrue);
      expect(results.any((v) => v.type == VitalSignType.oxygenSaturation && v.value == 98), isTrue);
    });

    test('should handle height and weight conversion', () async {
      final date = DateTime(2023, 10, 27, 10);
      final healthData = [
        HealthDataPoint(
          uuid: 'uuid6',
          value: NumericHealthValue(numericValue: 1.75), // 1.75 meters
          type: HealthDataType.HEIGHT,
          unit: HealthDataUnit.METER,
          dateFrom: date,
          dateTo: date,
          sourcePlatform: HealthPlatformType.googleHealthConnect,
          sourceDeviceId: 'deviceId',
          sourceId: 'sourceId',
          sourceName: 'sourceName',
        ),
        HealthDataPoint(
          uuid: 'uuid7',
          value: NumericHealthValue(numericValue: 70), // 70 kg
          type: HealthDataType.WEIGHT,
          unit: HealthDataUnit.KILOGRAM,
          dateFrom: date,
          dateTo: date,
          sourcePlatform: HealthPlatformType.googleHealthConnect,
          sourceDeviceId: 'deviceId',
          sourceId: 'sourceId',
          sourceName: 'sourceName',
        ),
      ];

      final results = await service.convertToVitalSigns(healthData, HealthDataSource.googleFit);

      expect(results.length, 2);
      // Height is mapped to temperature type as a workaround in current implementation
      expect(results[0].value, 175.0); // 1.75 * 100
      expect(results[1].value, 70.0);
    });
  });

  group('HealthDataImportService - findDuplicates', () {
    test('should identify exact duplicates', () {
      final now = DateTime(2023, 10, 27, 10);
      final imported = [
        VitalSign(
          type: VitalSignType.heartRate,
          value: 72,
          unit: 'bpm',
          dateTime: now,
        ),
        VitalSign(
          type: VitalSignType.temperature,
          value: 36.6,
          unit: 'C',
          dateTime: now,
        ),
      ];

      final existing = [
        VitalSign(
          type: VitalSignType.heartRate,
          value: 72,
          unit: 'bpm',
          dateTime: now,
        ),
      ];

      final duplicates = service.findDuplicates(imported, existing);

      expect(duplicates.length, 1);
      expect(duplicates[0].type, VitalSignType.heartRate);
    });

    test('should handle small differences in floating point values', () {
      final now = DateTime(2023, 10, 27, 10);
      final imported = [
        VitalSign(
          type: VitalSignType.heartRate,
          value: 72.00001,
          unit: 'bpm',
          dateTime: now,
        ),
      ];

      final existing = [
        VitalSign(
          type: VitalSignType.heartRate,
          value: 72.0,
          unit: 'bpm',
          dateTime: now,
        ),
      ];

      final duplicates = service.findDuplicates(imported, existing);
      expect(duplicates.length, 1);
    });

    test('should not mark records with different timestamps as duplicates', () {
      final now = DateTime(2023, 10, 27, 10);
      final later = now.add(const Duration(seconds: 1));

      final imported = [
        VitalSign(
          type: VitalSignType.heartRate,
          value: 72,
          unit: 'bpm',
          dateTime: later,
        ),
      ];

      final existing = [
        VitalSign(
          type: VitalSignType.heartRate,
          value: 72,
          unit: 'bpm',
          dateTime: now,
        ),
      ];

      final duplicates = service.findDuplicates(imported, existing);
      expect(duplicates.length, 0);
    });

    test('should return empty list when no duplicates found', () {
      final now = DateTime(2023, 10, 27, 10);
      final imported = [
        VitalSign(
          type: VitalSignType.heartRate,
          value: 80,
          unit: 'bpm',
          dateTime: now,
        ),
      ];

      final existing = [
        VitalSign(
          type: VitalSignType.heartRate,
          value: 72,
          unit: 'bpm',
          dateTime: now,
        ),
      ];

      final duplicates = service.findDuplicates(imported, existing);
      expect(duplicates.isEmpty, isTrue);
    });

    test('should handle large datasets efficiently', () {
      final now = DateTime(2023, 10, 27, 10);
      final imported = List.generate(
        1000,
        (i) => VitalSign(
          type: VitalSignType.heartRate,
          value: 70.0 + (i % 10),
          unit: 'bpm',
          dateTime: now.add(Duration(minutes: i)),
        ),
      );

      final existing = List.generate(
        1000,
        (i) => VitalSign(
          type: VitalSignType.heartRate,
          value: 70.0 + (i % 10),
          unit: 'bpm',
          dateTime: now.add(Duration(minutes: i)),
        ),
      );

      final stopwatch = Stopwatch()..start();
      final duplicates = service.findDuplicates(imported, existing);
      stopwatch.stop();

      expect(duplicates.length, 1000);
      // O(N+M) should be very fast, much less than 100ms for 2000 items
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });

  group('HealthDataParser - Robust CSV', () {
    late HealthDataParser parser;

    setUp(() {
      parser = HealthDataParser();
    });

    test('should handle commas inside quoted fields', () {
      const csv = 'type,value,unit,dateTime\nheartRate,72,"bpm, with comma",2023-10-27T10:00:00Z';
      final results = parser.parseCsv(csv);
      expect(results[0].unit, 'bpm, with comma');
    });

    test('should handle escaped quotes inside quoted fields', () {
      const csv = 'type,value,unit,dateTime\nheartRate,72,"bpm ""quoted""",2023-10-27T10:00:00Z';
      final results = parser.parseCsv(csv);
      expect(results[0].unit, 'bpm quoted');
    });
  });
}
