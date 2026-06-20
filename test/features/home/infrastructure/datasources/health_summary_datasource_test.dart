import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/home/infrastructure/datasources/health_summary_datasource.dart';

void main() {
  group('HealthSummaryDatasource', () {
    late HealthSummaryDatasource datasource;

    setUp(() {
      datasource = HealthSummaryDatasource();
    });

    test('should be able to create an instance', () {
      expect(datasource, isNotNull);
    });

    test('getHealthSummary returns a non-empty summary', () async {
      final summary = await datasource.getHealthSummary();
      expect(summary, isNotEmpty);
      expect(summary, contains('Resumen de salud'));
    });
  });
}
