import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_research/presentation/widgets/research_result_card.dart';

void main() {
  testWidgets('ResearchResultCard golden test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ResearchResultCard())),
    );
    await expectLater(
      find.byType(ResearchResultCard),
      matchesGoldenFile('goldens/research_result_card.png'),
    );
  });
}
