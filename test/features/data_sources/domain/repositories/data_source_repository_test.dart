import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';
import 'package:orionhealth_health/features/data_sources/domain/repositories/data_source_repository.dart';

class MockDataSourceRepository extends Mock implements DataSourceRepository {}

void main() {
  late MockDataSourceRepository mockRepository;

  setUp(() {
    mockRepository = MockDataSourceRepository();
  });

  group('DataSourceRepository Contract Tests', () {
    final tSources = [
      const DataSource(
        id: 'sensors',
        name: 'Device Sensors',
        description: 'Steps, heart rate, and more from your device.',
        type: DataSourceType.sensor,
        status: DataSourceStatus.disconnected,
      ),
      const DataSource(
        id: 'files',
        name: 'Health Files',
        description: 'Import PDF or image health records.',
        type: DataSourceType.file,
        status: DataSourceStatus.disconnected,
      ),
      const DataSource(
        id: 'health_connect',
        name: 'Health Connect',
        description: 'Sync data with Android Health Connect.',
        type: DataSourceType.healthConnect,
        status: DataSourceStatus.disconnected,
      ),
    ];

    test('getDataSources returns list of DataSources', () async {
      when(() => mockRepository.getDataSources()).thenAnswer((_) async => tSources);

      final result = await mockRepository.getDataSources();

      expect(result, isA<List<DataSource>>());
      expect(result.length, 3);
      expect(result, equals(tSources));
    });

    test('getDataSources returns empty list when no sources configured', () async {
      when(() => mockRepository.getDataSources()).thenAnswer((_) async => []);

      final result = await mockRepository.getDataSources();

      expect(result, isEmpty);
    });

    test('getDataSources propagates exceptions', () async {
      when(() => mockRepository.getDataSources()).thenThrow(Exception('DB error'));

      expect(() => mockRepository.getDataSources(), throwsException);
    });

    test('connectDataSource returns void on success', () async {
      when(() => mockRepository.connectDataSource(any())).thenAnswer((_) async => {});

      await expectLater(
        mockRepository.connectDataSource('sensors'),
        completes,
      );
    });

    test('connectDataSource propagates errors', () async {
      when(() => mockRepository.connectDataSource(any()))
          .thenThrow(Exception('Permission denied'));

      expect(
        () => mockRepository.connectDataSource('sensors'),
        throwsException,
      );
    });

    test('disconnectDataSource returns void on success', () async {
      when(() => mockRepository.disconnectDataSource(any())).thenAnswer((_) async => {});

      await expectLater(
        mockRepository.disconnectDataSource('sensors'),
        completes,
      );
    });

    test('disconnectDataSource propagates errors', () async {
      when(() => mockRepository.disconnectDataSource(any()))
          .thenThrow(Exception('Revoke failed'));

      expect(
        () => mockRepository.disconnectDataSource('sensors'),
        throwsException,
      );
    });

    test('syncDataSource returns void on success', () async {
      when(() => mockRepository.syncDataSource(any())).thenAnswer((_) async => {});

      await expectLater(
        mockRepository.syncDataSource('sensors'),
        completes,
      );
    });

    test('syncDataSource propagates errors', () async {
      when(() => mockRepository.syncDataSource(any()))
          .thenThrow(Exception('Sync timeout'));

      expect(
        () => mockRepository.syncDataSource('sensors'),
        throwsException,
      );
    });

    test('connectDataSource is idempotent when called multiple times', () async {
      when(() => mockRepository.connectDataSource(any())).thenAnswer((_) async => {});

      await mockRepository.connectDataSource('sensors');
      await mockRepository.connectDataSource('sensors');
      await mockRepository.connectDataSource('sensors');

      verify(() => mockRepository.connectDataSource('sensors')).called(3);
    });

    test('different data source ids route to correct underlying implementations', () async {
      when(() => mockRepository.connectDataSource('sensors')).thenAnswer((_) async => {});
      when(() => mockRepository.connectDataSource('health_connect')).thenAnswer((_) async => {});
      when(() => mockRepository.connectDataSource('files')).thenAnswer((_) async => {});

      await mockRepository.connectDataSource('sensors');
      await mockRepository.connectDataSource('health_connect');
      await mockRepository.connectDataSource('files');

      verify(() => mockRepository.connectDataSource('sensors')).called(1);
      verify(() => mockRepository.connectDataSource('health_connect')).called(1);
      verify(() => mockRepository.connectDataSource('files')).called(1);
    });
  });
}
