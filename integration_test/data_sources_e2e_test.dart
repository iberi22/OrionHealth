import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/data_sources/application/data_source_cubit.dart';
import 'package:orionhealth_health/features/data_sources/application/data_source_state.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';
import 'package:orionhealth_health/features/data_sources/presentation/pages/data_sources_config_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'utils/video_recorder.dart';

class MockDataSourceCubit extends Mock implements DataSourceCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockDataSourceCubit mockCubit;
  late StreamController<DataSourceState> stateController;

  final tSources = [
    const DataSource(
      id: 'sensors',
      name: 'Device Sensors',
      description: 'Steps, heart rate, and more.',
      type: DataSourceType.sensor,
      status: DataSourceStatus.disconnected,
    ),
    const DataSource(
      id: 'files',
      name: 'Health Files',
      description: 'Import records.',
      type: DataSourceType.file,
      status: DataSourceStatus.disconnected,
    ),
  ];

  setUpAll(() async {
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockCubit = MockDataSourceCubit();
    stateController = StreamController<DataSourceState>.broadcast();
    getIt.registerSingleton<DataSourceCubit>(mockCubit);

    when(() => mockCubit.loadDataSources()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async => stateController.close());
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
  });

  Widget createTestWidget(Widget home) {
    return MaterialApp(
      home: home,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
    );
  }

  group('Data Sources - E2E Tests', () {
    testWidgets('Full workflow: loading, connecting, syncing, and error', (WidgetTester tester) async {
      // 1. Loading state
      when(() => mockCubit.state).thenReturn(DataSourceLoading());
      await tester.pumpWidget(createTestWidget(const DataSourcesConfigPage()));
      await VideoRecorder.recordStep(tester, 'data_sources', '01_loading');

      // 2. Loaded state
      when(() => mockCubit.state).thenReturn(DataSourceLoaded(tSources));
      stateController.add(DataSourceLoaded(tSources));
      await tester.pumpAndSettle();
      expect(find.text('Device Sensors'), findsOneWidget);
      expect(find.text('Health Files'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'data_sources', '02_loaded');

      // 3. Connecting state
      final connectingSources = [
        tSources[0].copyWith(status: DataSourceStatus.connecting),
        tSources[1],
      ];
      when(() => mockCubit.state).thenReturn(DataSourceLoaded(connectingSources));
      stateController.add(DataSourceLoaded(connectingSources));
      when(() => mockCubit.toggleConnection('sensors')).thenAnswer((_) async {});

      await tester.tap(find.byType(Switch).first);
      await tester.pump();
      await VideoRecorder.recordStep(tester, 'data_sources', '03_connecting');

      // 4. Connected state
      final connectedSources = [
        tSources[0].copyWith(status: DataSourceStatus.connected),
        tSources[1],
      ];
      when(() => mockCubit.state).thenReturn(DataSourceLoaded(connectedSources));
      stateController.add(DataSourceLoaded(connectedSources));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.sync), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'data_sources', '04_connected');

      // 5. Syncing
      when(() => mockCubit.syncSource('sensors')).thenAnswer((_) async {});
      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();
      verify(() => mockCubit.syncSource('sensors')).called(1);
      await VideoRecorder.recordStep(tester, 'data_sources', '05_syncing');

      // 6. Error state
      when(() => mockCubit.state).thenReturn(const DataSourceError('Failed to sync'));
      stateController.add(const DataSourceError('Failed to sync'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Error: Failed to sync'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'data_sources', '06_error');
    });
  });
}
