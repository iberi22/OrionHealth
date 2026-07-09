import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/data_sources/application/data_source_cubit.dart';
import 'package:orionhealth_health/features/data_sources/application/data_source_state.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';
import 'package:orionhealth_health/features/data_sources/presentation/pages/data_sources_config_page.dart';
import 'package:orionhealth_health/features/data_sources/presentation/widgets/data_source_tile.dart';
import 'package:get_it/get_it.dart';

class MockDataSourceCubit extends MockCubit<DataSourceState> implements DataSourceCubit {}

void main() {
  late MockDataSourceCubit mockCubit;

  final tSources = [
    const DataSource(
      id: 'sensors',
      name: 'Sensors',
      description: 'Desc',
      type: DataSourceType.sensor,
      status: DataSourceStatus.disconnected,
    ),
  ];

  setUpAll(() {
    final getIt = GetIt.instance;
    mockCubit = MockDataSourceCubit();
    if (!getIt.isRegistered<DataSourceCubit>()) {
      getIt.registerFactory<DataSourceCubit>(() => mockCubit);
    }
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: DataSourcesConfigPage(),
    );
  }

  group('DataSourcesConfigPage', () {
    testWidgets('renders loading state', (tester) async {
      when(() => mockCubit.state).thenReturn(DataSourceLoading());
      when(() => mockCubit.loadDataSources()).thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state', (tester) async {
      when(() => mockCubit.state).thenReturn(const DataSourceError('error msg'));
      when(() => mockCubit.loadDataSources()).thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.textContaining('error msg'), findsOneWidget);
    });

    testWidgets('renders loaded state with tiles', (tester) async {
      when(() => mockCubit.state).thenReturn(DataSourceLoaded(tSources));
      when(() => mockCubit.loadDataSources()).thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(DataSourceTile), findsOneWidget);
      expect(find.text('Sensors'), findsOneWidget);
    });

    testWidgets('calls toggleConnection on tile toggle', (tester) async {
      when(() => mockCubit.state).thenReturn(DataSourceLoaded(tSources));
      when(() => mockCubit.loadDataSources()).thenAnswer((_) async => {});
      when(() => mockCubit.toggleConnection(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byType(Switch));

      verify(() => mockCubit.toggleConnection('sensors')).called(1);
    });

    testWidgets('calls syncSource on sync button press', (tester) async {
      final connectedSources = [tSources[0].copyWith(status: DataSourceStatus.connected)];
      when(() => mockCubit.state).thenReturn(DataSourceLoaded(connectedSources));
      when(() => mockCubit.loadDataSources()).thenAnswer((_) async => {});
      when(() => mockCubit.syncSource(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byIcon(Icons.sync));

      verify(() => mockCubit.syncSource('sensors')).called(1);
    });
  });
}
