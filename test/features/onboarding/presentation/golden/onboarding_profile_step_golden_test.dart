import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_profile_page.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  testWidgets('OnboardingProfilePage Golden Test', (WidgetTester tester) async {
    setupGoldenTest(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: OnboardingProfilePage(
            onNext: (_) {},
            initialData: const {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(OnboardingProfilePage),
      matchesGoldenFile('goldens/onboarding_profile_page.png'),
    );

    resetGoldenTest(tester);
  });
}
