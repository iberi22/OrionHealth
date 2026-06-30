import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';

void main() {
  testWidgets('Localization test - English', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: LocalizationChecker(),
      ),
    );

    expect(find.text('Home'), findsWidgets); // homeTitle and navHome
    expect(find.text('OrionHealth'), findsOneWidget);
  });

  testWidgets('Localization test - Spanish', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('es'),
        home: LocalizationChecker(),
      ),
    );

    expect(find.text('Inicio'), findsWidgets); // homeTitle and navHome
    expect(find.text('OrionHealth'), findsOneWidget);
  });
}

class LocalizationChecker extends StatelessWidget {
  const LocalizationChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Text(l10n.homeTitle),
    );
  }
}
