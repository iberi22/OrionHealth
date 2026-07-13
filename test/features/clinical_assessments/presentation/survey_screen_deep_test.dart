import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:research_package/research_package.dart';
import 'package:orionhealth_health/features/clinical_assessments/data/assessment_repository.dart';
import 'package:orionhealth_health/features/clinical_assessments/domain/entities/clinical_assessment_record.dart';
import 'package:orionhealth_health/features/clinical_assessments/presentation/survey_screen.dart';
import '../helpers/carp_test_utils.dart';

class MockAssessmentRepository extends Mock implements AssessmentRepository {}

void main() {
  late MockAssessmentRepository mockRepository;

  setUp(() {
    mockRepository = MockAssessmentRepository();

    registerFallbackValue(RPTaskResult(identifier: 'test'));
    registerFallbackValue(ClinicalAssessmentRecord());

    when(() => mockRepository.saveAssessmentResult(any(), any()))
        .thenAnswer((_) async {});
  });

  group('SurveyScreen Deep Tests', () {
    testWidgets('renders RPUITask', (WidgetTester tester) async {
      await tester.pumpWidget(createCarpTestApp(
        SurveyScreen(repository: mockRepository),
      ));
      await tester.pump();

      expect(find.byType(RPUITask), findsOneWidget);
    });

    testWidgets('renders health survey with correct task identifier',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCarpTestApp(
        SurveyScreen(repository: mockRepository),
      ));
      await tester.pump();

      final rpuiTask = tester.widget<RPUITask>(find.byType(RPUITask));
      expect(rpuiTask.task.identifier, 'health_survey_task');
    });

    testWidgets('has onSubmit callback that saves health_survey to repository',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCarpTestApp(
        SurveyScreen(repository: mockRepository),
      ));
      await tester.pump();

      final rpuiTask = tester.widget<RPUITask>(find.byType(RPUITask));

      final fakeResult = RPTaskResult(identifier: 'health_survey_task');
      rpuiTask.onSubmit?.call(fakeResult);

      verify(() => mockRepository.saveAssessmentResult(
          'health_survey', fakeResult)).called(1);
    });

    testWidgets('has onCancel callback that does not throw',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCarpTestApp(
        SurveyScreen(repository: mockRepository),
      ));
      await tester.pump();

      final rpuiTask = tester.widget<RPUITask>(find.byType(RPUITask));

      expect(() => rpuiTask.onCancel?.call(null), returnsNormally);
    });

    testWidgets('survey task has correct 4 steps',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCarpTestApp(
        SurveyScreen(repository: mockRepository),
      ));
      await tester.pump();

      final rpuiTask = tester.widget<RPUITask>(find.byType(RPUITask));
      final task = rpuiTask.task;
      expect(task.steps.length, 4);

      expect(task.steps[0].identifier, 'instructionID');
      expect(task.steps[1].identifier, 'pain_level_step');
      expect(task.steps[2].identifier, 'medication_step');
      expect(task.steps[3].identifier, 'completionID');
    });
  });
}
