import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_cubit.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_import_result.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/pages/health_import_page.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/widgets/data_source_card.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/widgets/import_progress_dialog.dart';

class MockHealthImportCubit extends Mock implements HealthImportCubit {}

void main() {
  late MockHealthImportCubit mockCubit;
  late StreamController<HealthImportState> stateController;

  setUpAll(() {
    mockCubit = MockHealthImportCubit();
    GetIt.instance.registerSingleton<HealthImportCubit>(mockCubit);
  });

  setUp(() {
    reset(mockCubit);
    stateController = StreamController<HealthImportState>.broadcast();
    when(() => mockCubit.checkAvailableSources()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    stateController.close();
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<HealthImportCubit>.value(
        value: mockCubit,
        child: const HealthImportPage(),
      ),
    );
  }

  testWidgets('displays loading indicator when state is HealthImportLoading', (tester) async {
    when(() => mockCubit.state).thenReturn(HealthImportLoading());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays ready view with data sources when state is HealthImportReady', (tester) async {
    when(() => mockCubit.state).thenReturn(const HealthImportReady(
      availableSources: [HealthDataSource.googleFit],
      availability: {
        HealthDataSource.googleFit: true,
        HealthDataSource.appleHealth: false,
        HealthDataSource.samsungHealth: false,
      },
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Import Health Data'), findsAtLeastNWidgets(1));
    expect(find.text('Data Sources'), findsOneWidget);
    expect(find.byType(DataSourceCard), findsNWidgets(HealthDataSource.values.length));
  });

  testWidgets('displays progress dialog when state is HealthImportImporting', (tester) async {
    when(() => mockCubit.state).thenReturn(const HealthImportImporting(
      source: HealthDataSource.googleFit,
      currentStep: 'Importing steps...',
      totalSteps: 8,
      currentStepNum: 1,
      importedCount: 0,
    ));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(ImportProgressDialog), findsOneWidget);
    expect(find.text('Importing steps...'), findsOneWidget);
  });

  testWidgets('displays authenticating view when state is HealthImportAuthenticating', (tester) async {
    when(() => mockCubit.state).thenReturn(const HealthImportAuthenticating(HealthDataSource.appleHealth));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Authenticating with Apple Health...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
