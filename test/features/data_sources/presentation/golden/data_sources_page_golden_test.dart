import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/data_sources/presentation/pages/data_sources_config_page.dart';
import 'package:orionhealth_health/features/data_sources/application/data_source_cubit.dart';
import 'package:orionhealth_health/features/data_sources/application/data_source_state.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import '../../../../core/golden_test_utils.dart';

class MockDataSourceCubit extends Mock implements DataSourceCubit {}

void main() {
  late MockDataSourceCubit mockCubit;

  setUpAll(() {
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockCubit = MockDataSourceCubit();
    getIt.registerSingleton<DataSourceCubit>(mockCubit);

    when(() => mockCubit.loadDataSources()).thenAnswer((_) async => {});
    when(() => mockCubit.close()).thenAnswer((_) async => {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return wrapWithMaterial(const DataSourcesConfigPage());
  }

  testWidgets('DataSourcesConfigPage matches golden - Loading state', (tester) async {
    when(() => mockCubit.state).thenReturn(DataSourceLoading());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    await expectLater(
      find.byType(DataSourcesConfigPage),
      matchesGoldenFile('goldens/data_sources_loading.png'),
    );
  });

  testWidgets('DataSourcesConfigPage matches golden - Loaded state', (tester) async {
    final tSources = [
      const DataSource(
        id: 'sensors',
        name: 'Device Sensors',
        description: 'Steps, heart rate, and more.',
        type: DataSourceType.sensor,
        status: DataSourceStatus.connected,
        lastSync: null,
      ),
      const DataSource(
        id: 'files',
        name: 'Health Files',
        description: 'Import records.',
        type: DataSourceType.file,
        status: DataSourceStatus.disconnected,
      ),
    ];

    when(() => mockCubit.state).thenReturn(DataSourceLoaded(tSources));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    await expectLater(
      find.byType(DataSourcesConfigPage),
      matchesGoldenFile('goldens/data_sources_loaded.png'),
    );
  });

  testWidgets('DataSourcesConfigPage matches golden - Error state', (tester) async {
    when(() => mockCubit.state).thenReturn(const DataSourceError('Failed to load data sources'));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    await expectLater(
      find.byType(DataSourcesConfigPage),
      matchesGoldenFile('goldens/data_sources_error.png'),
    );
  });

  testWidgets('DataSourcesConfigPage matches golden - Full Page Loaded', (tester) async {
    setupGoldenTest(tester);

    final tSources = [
      const DataSource(
        id: 'sensors',
        name: 'Device Sensors',
        description: 'Steps, heart rate, and more.',
        type: DataSourceType.sensor,
        status: DataSourceStatus.connected,
        lastSync: null,
      ),
      const DataSource(
        id: 'health_connect',
        name: 'Health Connect',
        description: 'Sync with Google Health Connect.',
        type: DataSourceType.healthConnect,
        status: DataSourceStatus.connected,
      ),
      const DataSource(
        id: 'files',
        name: 'Health Files',
        description: 'Import records from files.',
        type: DataSourceType.file,
        status: DataSourceStatus.disconnected,
      ),
    ];

    when(() => mockCubit.state).thenReturn(DataSourceLoaded(tSources));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(DataSourcesConfigPage),
      matchesGoldenFile('goldens/data_sources_page_loaded.png'),
    );

    resetGoldenTest(tester);
  });
}
