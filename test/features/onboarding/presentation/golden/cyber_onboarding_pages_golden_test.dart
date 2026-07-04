import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_welcome_page.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_complete_page.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('Cyber Onboarding Pages Golden Tests', () {
    testWidgets('OnboardingWelcomePage - First Slide', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: OnboardingWelcomePage(onNext: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(OnboardingWelcomePage),
        matchesGoldenFile("../../../../../golden/reference/onboarding_cyber_welcome.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('OnboardingCompletePage', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: OnboardingCompletePage(onComplete: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(OnboardingCompletePage),
        matchesGoldenFile("../../../../../golden/reference/onboarding_cyber_complete.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
