import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/pages/health_import_page.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/widgets/data_source_card.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/widgets/import_progress_dialog.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_cubit.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';
import '../../../../core/golden_test_utils.dart';

class MockHealthImportCubit extends Mock implements HealthImportCubit {}

void main() {
  late MockHealthImportCubit mockCubit;

  setUp(() async {
    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.allowReassignment = true;
    mockCubit = MockHealthImportCubit();
    getIt.registerFactory<HealthImportCubit>(() => mockCubit);

    when(() => mockCubit.checkAvailableSources()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget buildTestWidget() {
    return wrapWithMaterial(const HealthImportPage());
  }

  group('HealthImport Widgets Golden Tests', () {
    testWidgets('HealthImportPage - Initial State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(const HealthImportInitial());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await expectLater(
        find.byType(HealthImportPage),
        matchesGoldenFile("goldens/health_import_initial.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('HealthImportPage - Loading State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(const HealthImportLoading());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await expectLater(
        find.byType(HealthImportPage),
        matchesGoldenFile("goldens/health_import_loading.png"),
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

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(HealthImportPage),
        matchesGoldenFile("goldens/health_import_ready_all_unavailable.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('HealthImportPage - Authenticating State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(
        const HealthImportAuthenticating(HealthDataSource.googleFit),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(HealthImportPage),
        matchesGoldenFile("goldens/health_import_authenticating.png"),
      );
      resetGoldenTest(tester);
    });

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
                lastSync: DateTime(2025, 1, 1, 10, 0),
                onImport: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(DataSourceCard),
        matchesGoldenFile("goldens/data_source_card_available.png"),
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
        matchesGoldenFile("goldens/data_source_card_unavailable.png"),
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
        matchesGoldenFile("goldens/import_progress_dialog.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
