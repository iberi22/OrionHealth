import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/scraper_config_page.dart';

void main() {
  testWidgets('ScraperConfigPage renders CONFIGURACIÓN DEL SCRAPER title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScraperConfigPage(),
      ),
    );

    expect(find.text('CONFIGURACIÓN DEL SCRAPER'), findsOneWidget);
  });

  testWidgets('ScraperConfigPage shows FUENTES DE DATOS section', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScraperConfigPage(),
      ),
    );

    expect(find.text('FUENTES DE DATOS'), findsOneWidget);
  });

  testWidgets('ScraperConfigPage shows all four source switches', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScraperConfigPage(),
      ),
    );

    expect(find.text('PubMed'), findsOneWidget);
    expect(find.text('FDA'), findsOneWidget);
    expect(find.text('WHO / OMS'), findsOneWidget);
    expect(find.text('ClinicalTrials.gov'), findsOneWidget);
  });

  testWidgets('ScraperConfigPage shows PARÁMETROS TÉCNICOS section', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScraperConfigPage(),
      ),
    );

    expect(find.text('PARÁMETROS TÉCNICOS'), findsOneWidget);
  });

  testWidgets('ScraperConfigPage shows timeout slider with initial value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScraperConfigPage(),
      ),
    );

    expect(find.text('Timeout de búsqueda: 30s'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('ScraperConfigPage renders PubMed SwitchListTile', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScraperConfigPage(),
      ),
    );

    final pubmedSwitch = find.byWidgetPredicate(
      (widget) => widget is SwitchListTile && widget.title is Text && (widget.title as Text).data == 'PubMed',
    );
    expect(pubmedSwitch, findsOneWidget);
  });
}
