import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/allergies/presentation/widgets/allergy_form.dart';

void main() {
  group('AllergyForm', () {
    Widget createWidgetUnderTest({
      Allergy? allergy,
      required Function(Allergy) onSave,
      VoidCallback? onDelete,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AllergyForm(
            allergy: allergy,
            onSave: onSave,
            onDelete: onDelete,
          ),
        ),
      );
    }

    testWidgets('should show "Nueva Alergia" title when creating', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(onSave: (_) {}));
      expect(find.text('Nueva Alergia'), findsOneWidget);
    });

    testWidgets('should show "Editar Alergia" title when editing', (tester) async {
      final allergy = Allergy(id: 1, allergen: 'Dust', severity: AllergySeverity.mild);
      await tester.pumpWidget(createWidgetUnderTest(allergy: allergy, onSave: (_) {}));
      expect(find.text('Editar Alergia'), findsOneWidget);
    });

    testWidgets('should show validation error when allergen is empty and save is pressed', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(onSave: (_) {}));

      await tester.tap(find.text('GUARDAR'));
      await tester.pump();

      expect(find.text('Campo requerido'), findsOneWidget);
    });

    testWidgets('should call onSave with correct data when valid', (tester) async {
      Allergy? savedAllergy;
      await tester.pumpWidget(createWidgetUnderTest(onSave: (a) => savedAllergy = a));

      await tester.enterText(find.byType(TextFormField).first, 'Milk');
      await tester.enterText(find.byType(TextFormField).last, 'Avoid dairy');

      // Select Moderate
      await tester.tap(find.text('Moderada'));
      await tester.pump();

      await tester.tap(find.text('GUARDAR'));
      await tester.pump();

      expect(savedAllergy, isNotNull);
      expect(savedAllergy!.allergen, 'Milk');
      expect(savedAllergy!.notes, 'Avoid dairy');
      expect(savedAllergy!.severity, AllergySeverity.moderate);
    });

    testWidgets('should show and call onDelete when provided', (tester) async {
      bool deleted = false;
      final allergy = Allergy(id: 1, allergen: 'Dust', severity: AllergySeverity.mild);

      await tester.pumpWidget(createWidgetUnderTest(
        allergy: allergy,
        onSave: (_) {},
        onDelete: () => deleted = true,
      ));

      expect(find.text('ELIMINAR'), findsOneWidget);
      await tester.tap(find.text('ELIMINAR'));
      expect(deleted, isTrue);
    });

    testWidgets('should not show ELIMINAR button when onDelete is null', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(onSave: (_) {}));
      expect(find.text('ELIMINAR'), findsNothing);
    });
  });
}
