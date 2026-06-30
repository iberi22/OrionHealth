import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';
import 'package:orionhealth_health/features/medical_research/presentation/widgets/research_result_card.dart';

void main() {
  final testResult = ResearchResult(
    title: 'Estudio sobre Diabetes Tipo 2',
    content: 'Un estudio reciente muestra que la metformina sigue siendo el tratamiento de primera línea para diabetes tipo 2 en pacientes adultos.',
    source: 'PubMed',
    url: 'https://pubmed.ncbi.nlm.nih.gov/12345/',
    confidence: 0.87,
  );

  final fdaResult = ResearchResult(
    title: 'FDA Approval New Drug',
    content: 'La FDA ha aprobado un nuevo medicamento para el tratamiento de la hipertensión.',
    source: 'FDA',
    url: 'https://fda.gov/example',
    confidence: 0.95,
  );

  final whoResult = ResearchResult(
    title: 'WHO Guidelines',
    content: 'La OMS actualiza las guías de tratamiento para enfermedades tropicales desatendidas.',
    source: 'WHO',
    url: 'https://who.int/guidelines',
    confidence: 0.72,
  );

  final unknownResult = ResearchResult(
    title: 'Unknown Source Article',
    content: 'Some research content from an unknown source.',
    source: 'Other',
    url: 'https://example.com',
    confidence: 0.50,
  );

  testWidgets('ResearchResultCard renders title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResearchResultCard(result: testResult),
        ),
      ),
    );

    expect(find.text('Estudio sobre Diabetes Tipo 2'), findsOneWidget);
  });

  testWidgets('ResearchResultCard renders source badge', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResearchResultCard(result: testResult),
        ),
      ),
    );

    expect(find.text('PUBMED'), findsOneWidget);
  });

  testWidgets('ResearchResultCard renders source badge for FDA', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResearchResultCard(result: fdaResult),
        ),
      ),
    );

    expect(find.text('FDA'), findsOneWidget);
  });

  testWidgets('ResearchResultCard renders source badge for WHO', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResearchResultCard(result: whoResult),
        ),
      ),
    );

    expect(find.text('WHO'), findsOneWidget);
  });

  testWidgets('ResearchResultCard renders source badge for unknown source', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResearchResultCard(result: unknownResult),
        ),
      ),
    );

    expect(find.text('other'), findsOneWidget);
  });

  testWidgets('ResearchResultCard renders content text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResearchResultCard(result: testResult),
        ),
      ),
    );

    expect(
      find.textContaining('metformina sigue siendo el tratamiento de primera línea'),
      findsOneWidget,
    );
  });

  testWidgets('ResearchResultCard renders confidence percentage', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResearchResultCard(result: testResult),
        ),
      ),
    );

    expect(find.text('87% conf.'), findsOneWidget);
  });

  testWidgets('ResearchResultCard renders LEER MÁS button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResearchResultCard(result: testResult),
        ),
      ),
    );

    expect(find.text('LEER MÁS'), findsOneWidget);
  });

  testWidgets('ResearchResultCard hides confidence badge when confidence is 0', (tester) async {
    final noConfidenceResult = ResearchResult(
      title: 'Test',
      content: 'Content',
      source: 'PubMed',
      url: 'https://test.com',
      confidence: 0.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResearchResultCard(result: noConfidenceResult),
        ),
      ),
    );

    // Should not show "0% conf."
    expect(find.text('0% conf.'), findsNothing);
  });
}
