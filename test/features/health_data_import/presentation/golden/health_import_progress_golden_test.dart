import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/widgets/import_progress_dialog.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  testWidgets('Import Progress Dialog - Progressing', (WidgetTester tester) async {
    setupGoldenTest(tester);

    const state = HealthImportImporting(
      source: HealthDataSource.googleFit,
      currentStep: 'Importing heart rate...',
      totalSteps: 8,
      currentStepNum: 3,
      importedCount: 45,
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
      matchesGoldenFile("goldens/import_progress_dialog.png"),
    );

    resetGoldenTest(tester);
  });
}
