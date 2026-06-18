import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:health/health.dart';
import 'package:orionhealth_health/features/health_data_import/infrastructure/health_data_repository_impl.dart';
import 'package:orionhealth_health/features/health_data_import/infrastructure/data_source.dart';

class MockSensorHealthDataSource extends Mock implements SensorHealthDataSource {}
class MockFileHealthDataSource extends Mock implements FileHealthDataSource {}

void main() {
  late HealthDataRepositoryImpl repository;
  late MockSensorHealthDataSource mockSensorDataSource;
  late MockFileHealthDataSource mockFileDataSource;

  setUp(() {
    mockSensorDataSource = MockSensorHealthDataSource();
    mockFileDataSource = MockFileHealthDataSource();
    repository = HealthDataRepositoryImpl(
      mockSensorDataSource,
      mockFileDataSource,
    );
  });

  group('HealthDataRepositoryImpl', () {
    test('hasPermissions should delegate to sensor data source', () async {
      final types = [HealthDataType.STEPS];
      when(() => mockSensorDataSource.hasPermissions(types))
          .thenAnswer((_) async => true);

      final result = await repository.hasPermissions(types);

      expect(result, true);
      verify(() => mockSensorDataSource.hasPermissions(types)).called(1);
    });

    test('requestAuthorization should delegate to sensor data source', () async {
      final types = [HealthDataType.STEPS];
      when(() => mockSensorDataSource.requestAuthorization(types, any()))
          .thenAnswer((_) async => true);

      final result = await repository.requestAuthorization(types);

      expect(result, true);
      verify(() => mockSensorDataSource.requestAuthorization(types, any())).called(1);
    });

    test('fetchHealthData should delegate to sensor data source', () async {
      final type = HealthDataType.STEPS;
      final start = DateTime.now();
      final end = DateTime.now();
      when(() => mockSensorDataSource.fetchData(type, start, end))
          .thenAnswer((_) async => []);

      final result = await repository.fetchHealthData(type, start, end);

      expect(result, isEmpty);
      verify(() => mockSensorDataSource.fetchData(type, start, end)).called(1);
    });

    test('pickAndExtractFromFile should delegate to file data source', () async {
      when(() => mockFileDataSource.pickAndExtractText())
          .thenAnswer((_) async => 'extracted text');

      final result = await repository.pickAndExtractFromFile();

      expect(result, 'extracted text');
      verify(() => mockFileDataSource.pickAndExtractText()).called(1);
    });
  });
}
