import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_research/presentation/widgets/research_result_card.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';

void main() {
  testWidgets('ResearchResultCard golden test', (tester) async {
    final tResult = ResearchResult(
      title: 'Estudio de Aspirina',
      content: 'La aspirina es efectiva para el dolor.',
      source: 'PubMed',
      url: 'https://pubmed.ncbi.nlm.nih.gov/12345678/',
      confidence: 0.95,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResearchResultCard(result: tResult),
        ),
      ),
    );
    await expectLater(
      find.byType(ResearchResultCard),
      matchesGoldenFile('goldens/research_result_card.png'),
    );
  });
}
