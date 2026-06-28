import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:health/health.dart';
import 'package:orionhealth_health/features/health_data_import/infrastructure/health_data_import_repository_impl.dart';
import 'package:orionhealth_health/features/health_data_import/infrastructure/data_source.dart';

class MockSensorHealthDataSource extends Mock implements SensorHealthDataSource {}
class MockFileHealthDataSource extends Mock implements FileHealthDataSource {}

void main() {
  late HealthDataImportRepositoryImpl repository;
  late MockSensorHealthDataSource mockSensorDataSource;
  late MockFileHealthDataSource mockFileDataSource;

  setUp(() {
    mockSensorDataSource = MockSensorHealthDataSource();
    mockFileDataSource = MockFileHealthDataSource();
    repository = HealthDataImportRepositoryImpl(
      mockSensorDataSource,
      mockFileDataSource,
    );
  });

  group('HealthDataImportRepositoryImpl Extra', () {
    test('requestAuthorization should default to READ permissions when not provided', () async {
      final types = [HealthDataType.STEPS];

      when(() => mockSensorDataSource.requestAuthorization(any(), any()))
          .thenAnswer((_) async => true);

      await repository.requestAuthorization(types);

      verify(() => mockSensorDataSource.requestAuthorization(
        types,
        [HealthDataAccess.READ],
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
