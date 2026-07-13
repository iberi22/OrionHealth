import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import "package:orionhealth_health/features/clinical_assessments/domain/repositories/i_assessment_repository.dart";
import 'package:orionhealth_health/features/clinical_assessments/presentation/survey_screen.dart';
import '../../../../core/golden_test_utils.dart';
import '../../helpers/carp_test_utils.dart';

class MockAssessmentRepository extends Mock implements IAssessmentRepository {}

void main() {
  late MockAssessmentRepository mockRepository;

  setUp(() {
    mockRepository = MockAssessmentRepository();
  });

  group('SurveyScreen Golden Tests', () {
    testWidgets('SurveyScreen creates RPUITask without crashing', (tester) async {
      setupGoldenTest(tester);

      // SurveyScreen uses audioplayers internally via research_package.
      // We verify the widget tree loads in CupertinoApp context with CarpColors.
      // Full golden PNG generation is not feasible because audioplayers
      // creates dynamic platform channels (with UUIDs) that cannot be mocked
      // ahead of time in the test VM. The widget-level tests (survey_screen_test.dart)
      // already cover renders.

      await tester.pumpWidget(createCarpTestApp(
        SurveyScreen(repository: mockRepository),
      ));
      await tester.pump();

      // Verify the SurveyScreen widget is mounted
      expect(find.byType(SurveyScreen), findsOneWidget);

      resetGoldenTest(tester);
    });
  });
}
