import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/medical_research_page.dart';

void main() {
  testWidgets('MedicalResearchPage golden test - loading state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MedicalResearchPage()),
    );
    await expectLater(
      find.byType(MedicalResearchPage),
      matchesGoldenFile('goldens/medical_research_page_loading.png'),
    );
  });
}
