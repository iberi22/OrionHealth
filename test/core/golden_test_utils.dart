import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';

Widget wrapWithMaterial(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    home: child,
  );
}

void setupGoldenTest(WidgetTester tester) {
  GoogleFonts.config.allowRuntimeFetching = false;
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1.0;
}

void resetGoldenTest(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}
