import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';

void main() {
  testWidgets('AppLocalizations can be loaded and provide translations', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Text(AppLocalizations.of(context)!.home),
            );
          },
        ),
      ),
    );

    expect(find.text('Inicio'), findsOneWidget);

    // Test another locale
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fr'),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Text(AppLocalizations.of(context)!.home),
            );
          },
        ),
      ),
    );

    expect(find.text('Accueil'), findsOneWidget);

    // Test Arabic (RTL)
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Text(AppLocalizations.of(context)!.home),
            );
          },
        ),
      ),
    );

    expect(find.text('الرئيسية'), findsOneWidget);
  });
}
