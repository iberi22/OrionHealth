import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/utils/health_wrapper.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/datasources/sensor_api_datasource.dart';

class MockHealthWrapper extends Mock implements HealthWrapper {
  @override
  Health? get health => _mockHealth;
  final MockHealth _mockHealth = MockHealth();
}

class MockHealth extends Mock implements Health {}

void main() {
  late SensorApiDataSourceImpl dataSource;
  late MockHealth mockHealth;

  final types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
  ];

  setUp(() {
    mockHealth = MockHealth();
    final wrapper = MockHealthWrapper();
    when(() => wrapper.health).thenReturn(mockHealth);
    dataSource = SensorApiDataSourceImpl(wrapper);
  });

  group('SensorApiDataSourceImpl', () {
    test('requestAuthorization calls health package with correct types', () async {
      when(() => mockHealth.requestAuthorization(types)).thenAnswer((_) async => true);

      final result = await dataSource.requestAuthorization();

      expect(result, isTrue);
      verify(() => mockHealth.requestAuthorization(types)).called(1);
    });

    test('hasPermissions returns true if health package returns true', () async {
      when(() => mockHealth.hasPermissions(types)).thenAnswer((_) async => true);

      final result = await dataSource.hasPermissions();

      expect(result, isTrue);
    });

    test('hasPermissions returns false if health package returns false or null', () async {
      when(() => mockHealth.hasPermissions(types)).thenAnswer((_) async => null);

      final result = await dataSource.hasPermissions();

      expect(result, isFalse);
    });

    test('fetchAndSaveData calls getHealthDataFromTypes', () async {
      when(() => mockHealth.getHealthDataFromTypes(
        types: any(named: 'types'),
        startTime: any(named: 'startTime'),
        endTime: any(named: 'endTime'),
      )).thenAnswer((_) async => []);

      await dataSource.fetchAndSaveData();

      verify(() => mockHealth.getHealthDataFromTypes(
        types: types,
        startTime: any(named: 'startTime'),
        endTime: any(named: 'endTime'),
      )).called(1);
    });
  });
}
