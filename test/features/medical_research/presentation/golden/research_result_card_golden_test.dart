import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_research/presentation/widgets/research_result_card.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';

void main() {
  testWidgets('ResearchResultCard golden test', (tester) async {
    const result = ResearchResult(
      title: 'Sample Medical Research',
      content: 'This is a sample medical research content for golden testing.',
      source: 'PubMed',
      url: 'https://pubmed.ncbi.nlm.nih.gov/12345678/',
      confidence: 0.95,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResearchResultCard(result: result),
        ),
      ),
    );
    await expectLater(
      find.byType(ResearchResultCard),
      matchesGoldenFile('goldens/research_result_card.png'),
    );
  });
}
