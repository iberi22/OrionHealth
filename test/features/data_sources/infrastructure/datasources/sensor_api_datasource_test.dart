import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/datasources/sensor_api_datasource.dart';
import '../../../../helpers/mock_health.dart';

class FakeDateTime extends Fake implements DateTime {}

void main() {
  late SensorApiDataSourceImpl dataSource;
  late MockHealthWrapper mockWrapper;
  late MockHealth mockHealth;

  final expectedTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
  ];

  setUpAll(() {
    registerFallbackValue(HealthDataType.STEPS);
    registerFallbackValue(FakeDateTime());
  });

  setUp(() {
    mockWrapper = MockHealthWrapper();
    mockHealth = MockHealth();
    when(() => mockWrapper.health).thenReturn(mockHealth);
    dataSource = SensorApiDataSourceImpl(mockWrapper);
  });

  group('SensorApiDataSourceImpl', () {
    group('requestAuthorization', () {
      test(
        'calls health package with correct types and returns true',
        () async {
          when(
            () => mockHealth.requestAuthorization(expectedTypes),
          ).thenAnswer((_) async => true);

          final result = await dataSource.requestAuthorization();

          expect(result, isTrue);
          verify(
            () => mockHealth.requestAuthorization(expectedTypes),
          ).called(1);
        },
      );

      test('returns false if requestAuthorization fails', () async {
        when(
          () => mockHealth.requestAuthorization(any()),
        ).thenAnswer((_) async => false);

        final result = await dataSource.requestAuthorization();

        expect(result, isFalse);
      });

      test('returns false if health is null', () async {
        when(() => mockWrapper.health).thenReturn(null);

        final result = await dataSource.requestAuthorization();

        expect(result, isFalse);
      });

      test('returns false if requestAuthorization throws exception', () async {
        when(
          () => mockHealth.requestAuthorization(any()),
        ).thenThrow(Exception('Auth error'));

        final result = await dataSource.requestAuthorization();

        expect(result, isFalse);
      });
    });

    group('hasPermissions', () {
      test('returns true if health package returns true', () async {
        when(
          () => mockHealth.hasPermissions(expectedTypes),
        ).thenAnswer((_) async => true);

        final result = await dataSource.hasPermissions();

        expect(result, isTrue);
        verify(() => mockHealth.hasPermissions(expectedTypes)).called(1);
      });

      test('returns false if health package returns false or null', () async {
        when(
          () => mockHealth.hasPermissions(any()),
        ).thenAnswer((_) async => null);

        final result = await dataSource.hasPermissions();

        expect(result, isFalse);
      });

      test('returns false if health is null', () async {
        when(() => mockWrapper.health).thenReturn(null);

        final result = await dataSource.hasPermissions();

        expect(result, isFalse);
      });

      test('returns false if hasPermissions throws exception', () async {
        when(
          () => mockHealth.hasPermissions(any()),
        ).thenThrow(Exception('Permission check error'));

        final result = await dataSource.hasPermissions();

        expect(result, isFalse);
      });
    });

    group('fetchAndSaveData', () {
      test('calls getHealthDataFromTypes with correct parameters', () async {
        when(
          () => mockHealth.getHealthDataFromTypes(
            types: any(named: 'types'),
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          ),
        ).thenAnswer((_) async => []);

        await dataSource.fetchAndSaveData();

        verify(
          () => mockHealth.getHealthDataFromTypes(
            types: expectedTypes,
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          ),
        ).called(1);
      });

      test('handles null health gracefully', () async {
        when(() => mockWrapper.health).thenReturn(null);

        await dataSource.fetchAndSaveData();
      });

      test(
        'handles exception from getHealthDataFromTypes gracefully',
        () async {
          when(
            () => mockHealth.getHealthDataFromTypes(
              types: any(named: 'types'),
              startTime: any(named: 'startTime'),
              endTime: any(named: 'endTime'),
            ),
          ).thenThrow(Exception('Fetch error'));

          await dataSource.fetchAndSaveData();
        },
      );
    });
  });
}
