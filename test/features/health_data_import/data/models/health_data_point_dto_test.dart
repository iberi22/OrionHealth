import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:orionhealth_health/features/health_data_import/data/models/health_data_point_dto.dart';

void main() {
  group('HealthDataPointDto', () {
    test('toJson returns correct map', () {
      final dateFrom = DateTime(2023, 1, 1);
      final dateTo = DateTime(2023, 1, 1, 1);
      final dto = HealthDataPointDto(
        type: HealthDataType.STEPS,
        value: 100,
        dateFrom: dateFrom,
        dateTo: dateTo,
        unit: HealthDataUnit.COUNT,
        source: 'test_source',
      );

      final json = dto.toJson();

      expect(json['type'], HealthDataType.STEPS.toString());
      expect(json['value'], 100);
      expect(json['dateFrom'], dateFrom.toIso8601String());
      expect(json['dateTo'], dateTo.toIso8601String());
      expect(json['unit'], HealthDataUnit.COUNT.toString());
      expect(json['source'], 'test_source');
    });

    test('toJson handles null optional fields', () {
      final dateFrom = DateTime(2023, 1, 1);
      final dateTo = DateTime(2023, 1, 1, 1);
      final dto = HealthDataPointDto(
        type: HealthDataType.STEPS,
        value: 100,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      final json = dto.toJson();

      expect(json.containsKey('unit'), isFalse);
      expect(json.containsKey('source'), isFalse);
    });
  });
}
