import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/datasources/health_connect_datasource.dart';

void main() {
  late HealthConnectDataSource dataSource;

  setUp(() {
    dataSource = HealthConnectDataSource();
  });

  group('HealthConnectDataSource', () {
    test('returns false when not connected', () async {
      final connected = await dataSource.isConnected();
      expect(connected, isFalse);
    });

    test('returns empty list for unavailable data', () async {
      final data = await dataSource.fetchHealthData();
      expect(data, isEmpty);
    });

    test('supports heart rate type', () {
      final types = dataSource.supportedDataTypes;
      expect(types, contains('heart_rate'));
    });

    test('supports step count type', () {
      final types = dataSource.supportedDataTypes;
      expect(types, contains('steps'));
    });
  });
}
