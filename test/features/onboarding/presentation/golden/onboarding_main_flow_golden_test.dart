import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_welcome_page.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_profile_page.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_vitals_page.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_allergies_page.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_complete_page.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('Onboarding Main Flow Golden Tests', () {
    testWidgets('OnboardingWelcomePage', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        OnboardingWelcomePage(onNext: () {}),
      ));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(OnboardingWelcomePage),
        matchesGoldenFile("../../../../../golden/reference/onboarding_welcome_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('OnboardingProfilePage', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        OnboardingProfilePage(onNext: (_) {}, initialData: const {}),
      ));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(OnboardingProfilePage),
        matchesGoldenFile("../../../../../golden/reference/onboarding_profile_page_v2.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('OnboardingVitalsPage', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        OnboardingVitalsPage(onNext: (_) {}, initialData: const {}),
      ));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(OnboardingVitalsPage),
        matchesGoldenFile("../../../../../golden/reference/onboarding_vitals_page_v2.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('OnboardingAllergiesPage', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        OnboardingAllergiesPage(onNext: (_) {}, initialData: const {}),
      ));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(OnboardingAllergiesPage),
        matchesGoldenFile("../../../../../golden/reference/onboarding_allergies_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('OnboardingCompletePage', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        OnboardingCompletePage(onComplete: () {}),
      ));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(OnboardingCompletePage),
        matchesGoldenFile("../../../../../golden/reference/onboarding_complete_page_v2.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
