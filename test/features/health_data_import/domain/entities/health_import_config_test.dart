import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_import_config.dart';

void main() {
  group('HealthImportConfig', () {
    test('constructor correctly assigns values', () {
      final startTime = DateTime(2024, 1, 1);
      final endTime = DateTime(2024, 1, 31);
      final types = [HealthDataType.STEPS, HealthDataType.HEART_RATE];

      final config = HealthImportConfig(
        source: HealthDataSource.googleFit,
        types: types,
        startTime: startTime,
        endTime: endTime,
      );

      expect(config.source, HealthDataSource.googleFit);
      expect(config.types, types);
      expect(config.startTime, startTime);
      expect(config.endTime, endTime);
    });
  });
}
