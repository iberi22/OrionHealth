import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/medical_node_onboarding.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('MedicalNodeOnboarding Golden Tests', () {
    testWidgets('Step 1: What Is Medical Network', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        const MedicalNodeOnboarding(),
      ));
      await tester.pumpAndSettle();

      // Ensure we are on first page
      await expectLater(
        find.byType(MedicalNodeOnboarding),
        matchesGoldenFile("../../../../../golden/reference/medical_node_onboarding_step1.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Step 2: Secure Data Sharing', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        const MedicalNodeOnboarding(),
      ));
      await tester.pumpAndSettle();

      // Navigate to step 2
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MedicalNodeOnboarding),
        matchesGoldenFile("../../../../../golden/reference/medical_node_onboarding_step2.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Step 3: Patient Benefits', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        const MedicalNodeOnboarding(),
      ));
      await tester.pumpAndSettle();

      // Navigate to step 3
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MedicalNodeOnboarding),
        matchesGoldenFile("../../../../../golden/reference/medical_node_onboarding_step3.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
