import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/allergies/presentation/widgets/allergy_form.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('Allergy Form Golden Tests', () {
    testWidgets('AllergyForm (New) Golden Test', (WidgetTester tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: AllergyForm(
              onSave: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AllergyForm),
        matchesGoldenFile("goldens/allergy_form_new.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('AllergyForm (Edit) Golden Test', (WidgetTester tester) async {
      setupGoldenTest(tester);

      final allergy = Allergy(
        id: 1,
        allergen: 'Maní',
        severity: AllergySeverity.severe,
        notes: 'Reacción anafiláctica inmediata.',
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: AllergyForm(
              allergy: allergy,
              onSave: (_) {},
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AllergyForm),
        matchesGoldenFile("goldens/allergy_form_edit.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
