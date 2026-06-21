import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/pages/health_import_page.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/widgets/data_source_card.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/widgets/import_progress_dialog.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_cubit.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';
import '../../../../core/golden_test_utils.dart';

class MockHealthImportCubit extends Mock implements HealthImportCubit {}

void main() {
  late MockHealthImportCubit mockCubit;

  setUp(() {
    mockCubit = MockHealthImportCubit();
  });

  Widget buildTestWidget(HealthImportCubit cubit) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HealthImportCubit>.value(value: cubit),
      ],
      child: wrapWithMaterial(const HealthImportPage()),
    );
  }

  group('HealthImportPage Golden Tests', () {
    testWidgets('HealthImportPage - Initial State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(const HealthImportInitial());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.checkAvailableSources()).thenAnswer((_) async {});
      when(() => mockCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(mockCubit));
      await tester.pump();

      await expectLater(
        find.byType(HealthImportPage),
        matchesGoldenFile("../../../../golden/reference/health_import_initial.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('HealthImportPage - Loading State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(const HealthImportLoading());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.checkAvailableSources()).thenAnswer((_) async {});
      when(() => mockCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(mockCubit));
      await tester.pump();

      await expectLater(
        find.byType(HealthImportPage),
        matchesGoldenFile("../../../../golden/reference/health_import_loading.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('HealthImportPage - Ready State', (tester) async {
      setupGoldenTest(tester);

      const availability = {
        HealthDataSource.googleFit: true,
        HealthDataSource.appleHealth: false,
        HealthDataSource.samsungHealth: true,
      };

      when(() => mockCubit.state).thenReturn(
        const HealthImportReady(
          availableSources: [
            HealthDataSource.googleFit,
            HealthDataSource.samsungHealth,
          ],
          availability: availability,
        ),
      );
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.checkAvailableSources()).thenAnswer((_) async {});
      when(() => mockCubit.importFromSource(any())).thenAnswer((_) async {});
      when(() => mockCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(mockCubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await expectLater(
        find.byType(HealthImportPage),
        matchesGoldenFile("../../../../golden/reference/health_import_ready.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('HealthImportPage - Ready State All Unavailable', (
      tester,
    ) async {
      setupGoldenTest(tester);

      const availability = {
        HealthDataSource.googleFit: false,
        HealthDataSource.appleHealth: false,
        HealthDataSource.samsungHealth: false,
      };

      when(() => mockCubit.state).thenReturn(
        const HealthImportReady(
          availableSources: [],
          availability: availability,
        ),
      );
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.checkAvailableSources()).thenAnswer((_) async {});
      when(() => mockCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(mockCubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await expectLater(
        find.byType(HealthImportPage),
        matchesGoldenFile("../../../../golden/reference/health_import_ready_all_unavailable.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('HealthImportPage - Authenticating State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(
        const HealthImportAuthenticating(HealthDataSource.googleFit),
      );
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.checkAvailableSources()).thenAnswer((_) async {});
      when(() => mockCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(mockCubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await expectLater(
        find.byType(HealthImportPage),
        matchesGoldenFile("../../../../golden/reference/health_import_authenticating.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('HealthImportPage - Importing State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(
        const HealthImportImporting(
          source: HealthDataSource.googleFit,
          currentStep: 'Importing steps data...',
          totalSteps: 8,
          currentStepNum: 2,
          importedCount: 150,
        ),
      );
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.checkAvailableSources()).thenAnswer((_) async {});
      when(() => mockCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(mockCubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await expectLater(
        find.byType(HealthImportPage),
        matchesGoldenFile("../../../../golden/reference/health_import_importing.png"),
      );
      resetGoldenTest(tester);
    });
  });

  group('HealthImport Widgets Golden Tests', () {
    testWidgets('DataSourceCard - Available', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: DataSourceCard(
                source: HealthDataSource.googleFit,
                isAvailable: true,
                lastSync: DateTime.now().subtract(const Duration(hours: 2)),
                onImport: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(DataSourceCard),
        matchesGoldenFile("../../../../golden/reference/data_source_card_available.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('DataSourceCard - Unavailable', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: DataSourceCard(
                source: HealthDataSource.appleHealth,
                isAvailable: false,
                lastSync: null,
                onImport: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(DataSourceCard),
        matchesGoldenFile("../../../../golden/reference/data_source_card_unavailable.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ImportProgressDialog', (tester) async {
      setupGoldenTest(tester);

      const state = HealthImportImporting(
        source: HealthDataSource.samsungHealth,
        currentStep: 'Importing heart rate data...',
        totalSteps: 8,
        currentStepNum: 3,
        importedCount: 280,
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Center(child: ImportProgressDialog(state: state)),
          ),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(ImportProgressDialog),
        matchesGoldenFile("../../../../golden/reference/import_progress_dialog.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
