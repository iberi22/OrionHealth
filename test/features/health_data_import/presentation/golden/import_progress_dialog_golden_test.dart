import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/widgets/import_progress_dialog.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('ImportProgressDialog Golden Tests', () {
    testWidgets('Initial progress (0%)', (WidgetTester tester) async {
      setupGoldenTest(tester);

      const state = HealthImportImporting(
        source: HealthDataSource.googleFit,
        currentStep: 'Starting import...',
        totalSteps: 10,
        currentStepNum: 0,
        importedCount: 0,
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          const Scaffold(
            body: Center(
              child: ImportProgressDialog(state: state),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ImportProgressDialog),
        matchesGoldenFile("goldens/import_progress_dialog_initial.png"),
      );

      resetGoldenTest(tester);
    });

    testWidgets('Intermediate progress (50%)', (WidgetTester tester) async {
      setupGoldenTest(tester);

      const state = HealthImportImporting(
        source: HealthDataSource.googleFit,
        currentStep: 'Importing heart rate...',
        totalSteps: 10,
        currentStepNum: 5,
        importedCount: 150,
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          const Scaffold(
            body: Center(
              child: ImportProgressDialog(state: state),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ImportProgressDialog),
        matchesGoldenFile("goldens/import_progress_dialog_intermediate.png"),
      );

      resetGoldenTest(tester);
    });

    testWidgets('Near-completion progress (90%)', (WidgetTester tester) async {
      setupGoldenTest(tester);

      const state = HealthImportImporting(
        source: HealthDataSource.googleFit,
        currentStep: 'Finalizing...',
        totalSteps: 10,
        currentStepNum: 9,
        importedCount: 450,
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          const Scaffold(
            body: Center(
              child: ImportProgressDialog(state: state),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ImportProgressDialog),
        matchesGoldenFile("goldens/import_progress_dialog_finalizing.png"),
      );

      resetGoldenTest(tester);
    });
  });
}
