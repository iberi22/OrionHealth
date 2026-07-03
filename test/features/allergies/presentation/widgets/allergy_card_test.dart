import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/allergies/presentation/widgets/allergy_card.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';

void main() {
  group('AllergyCard', () {
    final tAllergy = Allergy(
      id: 1,
      allergen: 'Peanuts',
      severity: AllergySeverity.severe,
      notes: 'Anaphylaxis risk',
    );

    Widget createWidgetUnderTest({
      required Allergy allergy,
      bool isCritical = false,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AllergyCard(
            allergy: allergy,
            isCritical: isCritical,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('should render allergen name and notes', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(allergy: tAllergy));

      expect(find.text('Peanuts'), findsOneWidget);
      expect(find.text('Anaphylaxis risk'), findsOneWidget);
    });

    testWidgets('should render "Desconocido" when allergen is null', (tester) async {
      final allergy = Allergy(id: 2, severity: AllergySeverity.mild);
      await tester.pumpWidget(createWidgetUnderTest(allergy: allergy));

      expect(find.text('Desconocido'), findsOneWidget);
    });

    testWidgets('should display correct severity badge', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(allergy: tAllergy));
      expect(find.text('Severa'), findsOneWidget);

      await tester.pumpWidget(createWidgetUnderTest(
        allergy: Allergy(id: 3, severity: AllergySeverity.moderate),
      ));
      expect(find.text('Moderada'), findsOneWidget);

      await tester.pumpWidget(createWidgetUnderTest(
        allergy: Allergy(id: 4, severity: AllergySeverity.mild),
      ));
      expect(find.text('Leve'), findsOneWidget);
    });

    testWidgets('should call onTap when pressed', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(createWidgetUnderTest(
        allergy: tAllergy,
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });

    testWidgets('should apply critical decoration when isCritical is true', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        allergy: tAllergy,
        isCritical: true,
      ));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GlassmorphicCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      // We know from code it's Colors.red.withValues(alpha: 0.5)
    });
  });
}
