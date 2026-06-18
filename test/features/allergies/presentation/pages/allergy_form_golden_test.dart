import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/allergies/presentation/pages/allergies_page.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';

void main() {
  group('Allergy Form Golden Tests', () {
    testWidgets('AllergyForm (New) Golden Test', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(), // Use a default dark theme for simplicity or CyberTheme
          home: Scaffold(
            body: AllergyForm(
              onSave: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AllergyForm),
        matchesGoldenFile('goldens/allergy_form_new.png'),
      );

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('AllergyForm (Edit) Golden Test', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      final allergy = Allergy(
        id: 1,
        allergen: 'Maní',
        severity: AllergySeverity.severe,
        notes: 'Reacción anafiláctica inmediata.',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
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
        matchesGoldenFile('goldens/allergy_form_edit.png'),
      );

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
