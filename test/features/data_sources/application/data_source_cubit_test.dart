import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/data_sources/application/data_source_cubit.dart';
import 'package:orionhealth_health/features/data_sources/application/data_source_state.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';
import 'package:orionhealth_health/features/data_sources/domain/repositories/data_source_repository.dart';

class MockDataSourceRepository extends Mock implements DataSourceRepository {}

void main() {
  late DataSourceCubit cubit;
  late MockDataSourceRepository mockRepository;

  final tSources = [
    const DataSource(
      id: 'sensors',
      name: 'Sensors',
      description: 'Desc',
      type: DataSourceType.sensor,
      status: DataSourceStatus.disconnected,
    ),
  ];

  setUp(() {
    mockRepository = MockDataSourceRepository();
    cubit = DataSourceCubit(mockRepository);
  });

  group('DataSourceCubit', () {
    test('initial state is DataSourceInitial', () {
      expect(cubit.state, DataSourceInitial());
    });

    test('loadDataSources emits [Loading, Loaded] when successful', () async {
      when(() => mockRepository.getDataSources()).thenAnswer((_) async => tSources);

      final states = <DataSourceState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.loadDataSources();
      await Future.delayed(Duration.zero);

      expect(states, [
        DataSourceLoading(),
        DataSourceLoaded(tSources),
      ]);
      await subscription.cancel();
    });

    test('loadDataSources emits [Loading, Error] when failure', () async {
      when(() => mockRepository.getDataSources()).thenThrow(Exception('error'));

      final states = <DataSourceState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.loadDataSources();
      await Future.delayed(Duration.zero);

      expect(states, [
        DataSourceLoading(),
        const DataSourceError('Exception: error'),
      ]);
      await subscription.cancel();
    });

    group('toggleConnection', () {
      test('connect successful updates status to connected', () async {
        when(() => mockRepository.connectDataSource(any())).thenAnswer((_) async => {});

        cubit.emit(DataSourceLoaded(tSources));

        final states = <DataSourceState>[];
        final subscription = cubit.stream.listen(states.add);

        await cubit.toggleConnection('sensors');
        await Future.delayed(Duration.zero);

        expect(states, [
          DataSourceLoaded([tSources[0].copyWith(status: DataSourceStatus.connecting)]),
          DataSourceLoaded([tSources[0].copyWith(status: DataSourceStatus.connected)]),
        ]);
        await subscription.cancel();
      });

      test('connect failure updates status to error', () async {
        when(() => mockRepository.connectDataSource(any())).thenThrow(Exception('fail'));

        cubit.emit(DataSourceLoaded(tSources));

        final states = <DataSourceState>[];
        final subscription = cubit.stream.listen(states.add);

        await cubit.toggleConnection('sensors');
        await Future.delayed(Duration.zero);

        expect(states, [
          DataSourceLoaded([tSources[0].copyWith(status: DataSourceStatus.connecting)]),
          DataSourceLoaded([tSources[0].copyWith(status: DataSourceStatus.error, errorMessage: 'Exception: fail')]),
        ]);
        await subscription.cancel();
      });

      test('disconnect successful updates status to disconnected', () async {
        when(() => mockRepository.disconnectDataSource(any())).thenAnswer((_) async => {});

        final connectedSource = tSources[0].copyWith(status: DataSourceStatus.connected);
        cubit.emit(DataSourceLoaded([connectedSource]));

        final states = <DataSourceState>[];
        final subscription = cubit.stream.listen(states.add);

        await cubit.toggleConnection('sensors');
        await Future.delayed(Duration.zero);

        expect(states, [
          DataSourceLoaded([connectedSource.copyWith(status: DataSourceStatus.disconnected)]),
        ]);
        await subscription.cancel();
      });
    });

    group('syncSource', () {
      test('sync successful updates lastSync', () async {
        when(() => mockRepository.syncDataSource(any())).thenAnswer((_) async => {});

        cubit.emit(DataSourceLoaded(tSources));

        await cubit.syncSource('sensors');

        final state = cubit.state as DataSourceLoaded;
        expect(state.dataSources[0].lastSync, isNotNull);
      });

      test('sync failure emits Error', () async {
        when(() => mockRepository.syncDataSource(any())).thenThrow(Exception('sync fail'));

        cubit.emit(DataSourceLoaded(tSources));

        final states = <DataSourceState>[];
        final subscription = cubit.stream.listen(states.add);

        await cubit.syncSource('sensors');
        await Future.delayed(Duration.zero);

        expect(states, [
          const DataSourceError('Sync failed: Exception: sync fail'),
        ]);
        await subscription.cancel();
      });
    });
  });
}
