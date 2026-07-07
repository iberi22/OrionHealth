import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medications/presentation/widgets/medication_empty_view.dart';
import 'package:orionhealth_health/features/medications/presentation/widgets/medication_error_view.dart';

void main() {
  group('MedicationEmptyView', () {
    testWidgets('renders empty message and add button', (WidgetTester tester) async {
      bool addTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicationEmptyView(
              onAdd: () => addTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No hay medicamentos registrados'), findsOneWidget);
      expect(find.byIcon(Icons.medication_liquid), findsOneWidget);
      expect(find.text('Agregar Medicamento'), findsOneWidget);

      await tester.tap(find.text('Agregar Medicamento'));
      expect(addTapped, isTrue);
    });
  });

  group('MedicationErrorView', () {
    testWidgets('renders error message', (WidgetTester tester) async {
      const errorMessage = 'Error loading medications';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MedicationErrorView(
              message: errorMessage,
            ),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
