import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/medical_node_onboarding.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('Medical Node Onboarding Golden Tests', () {
    testWidgets('Step 1: What is Medical Network', (tester) async {
      setupGoldenTest(tester, size: const Size(1080, 1920));

      await tester.pumpWidget(wrapWithMaterial(const MedicalNodeOnboarding()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MedicalNodeOnboarding),
        matchesGoldenFile("../../../../../golden/reference/medical_node_onboarding_step_0.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Step 2: Secure Data Sharing', (tester) async {
      setupGoldenTest(tester, size: const Size(1080, 1920));

      await tester.pumpWidget(wrapWithMaterial(const MedicalNodeOnboarding()));
      await tester.pumpAndSettle();

      // Navigate to second page
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MedicalNodeOnboarding),
        matchesGoldenFile("../../../../../golden/reference/medical_node_onboarding_step_1.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Step 3: Patient Benefits', (tester) async {
      setupGoldenTest(tester, size: const Size(1080, 1920));

      await tester.pumpWidget(wrapWithMaterial(const MedicalNodeOnboarding()));
      await tester.pumpAndSettle();

      // Navigate to third page
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MedicalNodeOnboarding),
        matchesGoldenFile("../../../../../golden/reference/medical_node_onboarding_step_2.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
