import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/standards_viewer_page.dart';

void main() {
  testWidgets('StandardsViewerPage renders VISOR DE ESTÁNDARES title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StandardsViewerPage(),
      ),
    );

    expect(find.text('VISOR DE ESTÁNDARES'), findsOneWidget);
  });

  testWidgets('StandardsViewerPage shows ICD-10 standard', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StandardsViewerPage(),
      ),
    );

    expect(find.text('ICD-10'), findsOneWidget);
    expect(find.text('Clasificación Internacional de Enfermedades'), findsOneWidget);
    expect(find.text('14,000+ códigos'), findsOneWidget);
  });

  testWidgets('StandardsViewerPage shows LOINC standard', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StandardsViewerPage(),
      ),
    );

    expect(find.text('LOINC'), findsOneWidget);
    expect(find.text('Observaciones de Laboratorio'), findsOneWidget);
    expect(find.text('98,000+ códigos'), findsOneWidget);
  });

  testWidgets('StandardsViewerPage shows RxNorm standard', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StandardsViewerPage(),
      ),
    );

    expect(find.text('RxNorm'), findsOneWidget);
    expect(find.text('Terminología de Medicamentos'), findsOneWidget);
    expect(find.text('Normas de prescripción'), findsOneWidget);
  });

  testWidgets('StandardsViewerPage shows SNOMED CT standard', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StandardsViewerPage(),
      ),
    );

    expect(find.text('SNOMED CT'), findsOneWidget);
    expect(find.text('Terminología Clínica Sistematizada'), findsOneWidget);
    expect(find.text('350,000+ conceptos'), findsOneWidget);
  });

  testWidgets('StandardsViewerPage renders list tiles for all standards', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StandardsViewerPage(),
      ),
    );

    // Should have 4 ListTile widgets
    expect(find.byType(ListTile), findsNWidgets(4));
  });
}
