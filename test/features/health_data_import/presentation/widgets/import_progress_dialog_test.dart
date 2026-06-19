import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/widgets/import_progress_dialog.dart';

void main() {
  Widget createWidgetUnderTest(HealthImportImporting state) {
    return MaterialApp(
      home: Scaffold(
        body: ImportProgressDialog(state: state),
      ),
    );
  }

  group('ImportProgressDialog', () {
    testWidgets('renders correctly with given state', (tester) async {
      const state = HealthImportImporting(
        source: HealthDataSource.googleFit,
        currentStep: 'Importing steps...',
        totalSteps: 8,
        currentStepNum: 1,
        importedCount: 10,
      );

      await tester.pumpWidget(createWidgetUnderTest(state));

      expect(find.textContaining('Importing from'), findsOneWidget);
      expect(find.textContaining('Google Fit'), findsOneWidget);
      expect(find.text('Importing steps...'), findsOneWidget);
      expect(find.text('Step 1 of 8'), findsOneWidget);
      expect(find.text('10 imported'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      final indicator = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(indicator.value, 1/8);
    });

    testWidgets('calculates progress correctly', (tester) async {
      const state = HealthImportImporting(
        source: HealthDataSource.googleFit,
        currentStep: 'Importing heart rate...',
        totalSteps: 8,
        currentStepNum: 4,
        importedCount: 50,
      );

      await tester.pumpWidget(createWidgetUnderTest(state));

      final indicator = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(indicator.value, 4/8);
    });
  });
}
