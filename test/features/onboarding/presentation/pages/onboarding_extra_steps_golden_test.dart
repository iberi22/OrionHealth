import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_profile_page.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_vitals_page.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Onboarding Extra Steps Golden Tests', () {
    testWidgets('OnboardingProfilePage Golden Test', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

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

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('OnboardingVitalsPage Golden Test', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: OnboardingVitalsPage(
              onNext: (_) {},
              initialData: const {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(OnboardingVitalsPage),
        matchesGoldenFile('goldens/onboarding_vitals_page.png'),
      );

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
