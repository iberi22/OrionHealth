import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:health/health.dart';
import 'package:orionhealth_health/features/health_data_import/data/repositories/health_data_repository_impl.dart';
import 'package:orionhealth_health/features/health_data_import/data/datasources/health_data_sensor_datasource.dart';
import 'package:orionhealth_health/features/health_data_import/data/datasources/health_data_file_datasource.dart';

class MockHealthDataSensorDataSource extends Mock implements HealthDataSensorDataSource {}
class MockHealthDataFileDataSource extends Mock implements HealthDataFileDataSource {}

void main() {
  late HealthDataImportRepositoryImpl repository;
  late MockHealthDataSensorDataSource mockSensorDataSource;
  late MockHealthDataFileDataSource mockFileDataSource;

  setUp(() {
    mockSensorDataSource = MockHealthDataSensorDataSource();
    mockFileDataSource = MockHealthDataFileDataSource();
    repository = HealthDataImportRepositoryImpl(
      mockSensorDataSource,
      mockFileDataSource,
    );
  });

  group('HealthDataImportRepositoryImpl Extra', () {
    test('requestAuthorization should default to READ permissions when not provided', () async {
      final types = [HealthDataType.STEPS, HealthDataType.BLOOD_GLUCOSE];

      when(() => mockSensorDataSource.requestAuthorization(any(), any()))
          .thenAnswer((_) async => true);

      await repository.requestAuthorization(types);

      verify(() => mockSensorDataSource.requestAuthorization(
        types,
        [HealthDataAccess.READ, HealthDataAccess.READ],
      )).called(1);
    });

    test('requestAuthorization should use provided permissions', () async {
      final types = [HealthDataType.STEPS];
      final permissions = [HealthDataAccess.READ_WRITE];

      when(() => mockSensorDataSource.requestAuthorization(any(), any()))
          .thenAnswer((_) async => true);

      await repository.requestAuthorization(types, permissions: permissions);

      verify(() => mockSensorDataSource.requestAuthorization(
        types,
        permissions,
      )).called(1);
    });
  });
}
