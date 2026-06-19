import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/home/infrastructure/datasources/health_summary_datasource.dart';

void main() {
  group('HealthSummaryDatasource', () {
    test('should be able to create an instance', () {
      final datasource = HealthSummaryDatasource();
      expect(datasource, isNotNull);
    });
  });
}
