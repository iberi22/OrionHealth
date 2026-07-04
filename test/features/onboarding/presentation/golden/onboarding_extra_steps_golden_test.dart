import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_profile_page.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_vitals_page.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('Onboarding Extra Steps Golden Tests', () {
    testWidgets('OnboardingProfilePage Golden Test', (WidgetTester tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: OnboardingProfilePage(
            onNext: (_) {},
            initialData: const {},
          ),
        ),
      ));

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(OnboardingProfilePage),
        matchesGoldenFile("../../../../../golden/reference/onboarding_profile_page.png"),
      );

      resetGoldenTest(tester);
    });

    testWidgets('OnboardingVitalsPage Golden Test', (WidgetTester tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: OnboardingVitalsPage(
            onNext: (_) {},
            initialData: const {},
          ),
        ),
      ));

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(OnboardingVitalsPage),
        matchesGoldenFile("../../../../../golden/reference/onboarding_vitals_page.png"),
      );

      resetGoldenTest(tester);
    });
  });
}
