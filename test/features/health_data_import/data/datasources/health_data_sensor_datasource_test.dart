import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_data_import/data/datasources/health_data_sensor_datasource.dart';

void main() {
  late HealthDataSensorDataSource datasource;

  setUp(() {
    datasource = HealthDataSensorDataSource();
  });

  group('HealthDataSensorDataSource', () {
    test('instance exists', () {
      expect(datasource, isNotNull);
    });
  });
}
