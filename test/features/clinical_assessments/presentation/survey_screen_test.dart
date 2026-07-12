import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:research_package/research_package.dart';
import 'package:orionhealth_health/features/clinical_assessments/data/assessment_repository.dart';
import 'package:orionhealth_health/features/clinical_assessments/presentation/survey_screen.dart';

class MockAssessmentRepository extends Mock implements AssessmentRepository {}

void main() {
  late MockAssessmentRepository mockRepository;

  setUp(() {
    mockRepository = MockAssessmentRepository();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: SurveyScreen(repository: mockRepository),
      ),
    );
  }

  testWidgets('SurveyScreen renders RPUITask and displays content', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Verify that the ResearchPackage task UI is rendered
    expect(find.byType(RPUITask), findsOneWidget);
  });
}
