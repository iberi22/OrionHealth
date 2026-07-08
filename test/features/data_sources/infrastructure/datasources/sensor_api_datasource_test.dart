import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/datasources/sensor_api_datasource.dart';

void main() {
  late SensorApiDataSource dataSource;

  setUp(() {
    dataSource = SensorApiDataSource();
  });

  group('SensorApiDataSource', () {
    test('has default timeout', () {
      expect(dataSource.timeout, greaterThan(0));
    });

    test('returns null for unavailable sensor', () async {
      final result = await dataSource.readSensor('nonexistent');
      expect(result, isNull);
    });

    test('lists available sensors', () async {
      final sensors = await dataSource.listSensors();
      expect(sensors, isNotNull);
    });
  });
}
