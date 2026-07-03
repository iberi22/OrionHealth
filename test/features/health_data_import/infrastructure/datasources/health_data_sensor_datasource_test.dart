import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_data_import/infrastructure/data_source.dart';

void main() {
  late SensorHealthDataSource datasource;

  setUp(() {
    datasource = SensorHealthDataSourceImpl();
  });

  group('SensorHealthDataSource', () {
    test('instance exists', () {
      expect(datasource, isNotNull);
    });
  });
}
