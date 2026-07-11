import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/datasources/sensor_api_datasource.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/datasources/file_import_datasource.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/datasources/health_connect_datasource.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/repositories/data_source_repository_impl.dart';

class MockSensorApiDataSource extends Mock implements SensorApiDataSource {}
class MockFileImportDataSource extends Mock implements FileImportDataSource {}
class MockHealthConnectDataSource extends Mock implements HealthConnectDataSource {}

void main() {
  group('DataSource Integration: Repository <-> DataSources', () {
    late DataSourceRepositoryImpl repository;
    late MockSensorApiDataSource mockSensor;
    late MockFileImportDataSource mockFile;
    late MockHealthConnectDataSource mockHealthConnect;

    setUp(() {
      mockSensor = MockSensorApiDataSource();
      mockFile = MockFileImportDataSource();
      mockHealthConnect = MockHealthConnectDataSource();
      repository = DataSourceRepositoryImpl(mockSensor, mockFile, mockHealthConnect);
    });

    test('1. Get data sources returns the 3 configured default sources', () async {
      final sources = await repository.getDataSources();

      expect(sources.length, 3);
      expect(sources.any((s) => s.id == 'sensors'), isTrue);
      expect(sources.any((s) => s.id == 'files'), isTrue);
      expect(sources.any((s) => s.id == 'health_connect'), isTrue);
      expect(sources.every((s) => s.status == DataSourceStatus.disconnected), isTrue);

      // Verify no side effects on underlying datasources
      verifyZeroInteractions(mockSensor);
      verifyZeroInteractions(mockFile);
      verifyZeroInteractions(mockHealthConnect);
    });

    test('2. Connect sensors -> requestAuthorization is called and returns true', () async {
      when(() => mockSensor.requestAuthorization()).thenAnswer((_) async => true);

      await repository.connectDataSource('sensors');

      verify(() => mockSensor.requestAuthorization()).called(1);
    });

    test('3. Connect sensors when authorization fails throws Exception', () async {
      when(() => mockSensor.requestAuthorization()).thenAnswer((_) async => false);

      expect(
        () => repository.connectDataSource('sensors'),
        throwsA(isA<Exception>()),
      );

      verify(() => mockSensor.requestAuthorization()).called(1);
    });

    test('4. Connect health_connect -> requestPermissions is called and returns true', () async {
      when(() => mockHealthConnect.requestPermissions()).thenAnswer((_) async => true);

      await repository.connectDataSource('health_connect');

      verify(() => mockHealthConnect.requestPermissions()).called(1);
    });

    test('5. Connect health_connect when permissions fail throws Exception', () async {
      when(() => mockHealthConnect.requestPermissions()).thenAnswer((_) async => false);

      expect(
        () => repository.connectDataSource('health_connect'),
        throwsA(isA<Exception>()),
      );

      verify(() => mockHealthConnect.requestPermissions()).called(1);
    });

    test('6. Connect files does not call any underlying datasource', () async {
      await repository.connectDataSource('files');

      verifyZeroInteractions(mockSensor);
      verifyZeroInteractions(mockFile);
      verifyZeroInteractions(mockHealthConnect);
    });

    test('7. Connect unknown id throws Exception', () async {
      expect(
        () => repository.connectDataSource('unknown'),
        throwsA(isA<Exception>()),
      );
    });

    test('8. Sync sensors calls fetchAndSaveData', () async {
      when(() => mockSensor.fetchAndSaveData()).thenAnswer((_) async => {});

      await repository.syncDataSource('sensors');

      verify(() => mockSensor.fetchAndSaveData()).called(1);
    });

    test('9. Sync health_connect calls syncData', () async {
      when(() => mockHealthConnect.syncData()).thenAnswer((_) async => {});

      await repository.syncDataSource('health_connect');

      verify(() => mockHealthConnect.syncData()).called(1);
    });

    test('10. Sync files calls pickAndProcessFile', () async {
      when(() => mockFile.pickAndProcessFile()).thenAnswer((_) async => 'extracted text');

      await repository.syncDataSource('files');

      verify(() => mockFile.pickAndProcessFile()).called(1);
    });

    test('11. Sync unknown id throws Exception', () async {
      expect(
        () => repository.syncDataSource('unknown'),
        throwsA(isA<Exception>()),
      );
    });

    test('12. Full flow: get -> connect -> sync works end-to-end', () async {
      // 1. Get sources
      final sources = await repository.getDataSources();
      expect(sources.length, 3);

      // 2. Connect sensors
      when(() => mockSensor.requestAuthorization()).thenAnswer((_) async => true);
      await repository.connectDataSource('sensors');
      verify(() => mockSensor.requestAuthorization()).called(1);

      // 3. Sync sensors
      when(() => mockSensor.fetchAndSaveData()).thenAnswer((_) async => {});
      await repository.syncDataSource('sensors');
      verify(() => mockSensor.fetchAndSaveData()).called(1);

      // 4. Disconnect sensors (no-op, but should not throw)
      await repository.disconnectDataSource('sensors');
    });

    test('13. Connect health_connect -> sync health_connect works end-to-end', () async {
      when(() => mockHealthConnect.requestPermissions()).thenAnswer((_) async => true);
      await repository.connectDataSource('health_connect');
      verify(() => mockHealthConnect.requestPermissions()).called(1);

      when(() => mockHealthConnect.syncData()).thenAnswer((_) async => {});
      await repository.syncDataSource('health_connect');
      verify(() => mockHealthConnect.syncData()).called(1);
    });

    test('14. Disconnect datasource does not throw', () async {
      // disconnectDataSource is a no-op currently; should not throw
      await repository.disconnectDataSource('sensors');
      await repository.disconnectDataSource('health_connect');
      await repository.disconnectDataSource('files');

      verifyZeroInteractions(mockSensor);
      verifyZeroInteractions(mockFile);
      verifyZeroInteractions(mockHealthConnect);
    });
  });
}
