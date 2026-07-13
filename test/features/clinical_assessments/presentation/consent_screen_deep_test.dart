import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:research_package/research_package.dart';
import 'package:orionhealth_health/features/clinical_assessments/data/assessment_repository.dart';
import 'package:orionhealth_health/features/clinical_assessments/domain/entities/clinical_assessment_record.dart';
import 'package:orionhealth_health/features/clinical_assessments/presentation/consent_screen.dart';
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

  group('ConsentScreen Deep Tests', () {
    testWidgets('renders RPUITask', (WidgetTester tester) async {
      await tester.pumpWidget(createCarpTestApp(
        ConsentScreen(repository: mockRepository),
      ));
      await tester.pump();

      expect(find.byType(RPUITask), findsOneWidget);
    });

    testWidgets('renders consent review step with correct title',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCarpTestApp(
        ConsentScreen(repository: mockRepository),
      ));
      await tester.pump();

      expect(find.byType(RPUITask), findsOneWidget);

      final rpuiTask = tester.widget<RPUITask>(find.byType(RPUITask));
      final task = rpuiTask.task;
      expect(task.steps.length, 1);
      expect(task.steps[0], isA<RPConsentReviewStep>());
      final consentStep = task.steps[0] as RPConsentReviewStep;
      expect(consentStep.title, 'Revisión de Consentimiento');
      expect(consentStep.consentDocument.title,
          'Consentimiento Informado - Orion Health');
    });

    testWidgets('has onSubmit callback that saves to repository',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCarpTestApp(
        ConsentScreen(repository: mockRepository),
      ));
      await tester.pump();

      final rpuiTask = tester.widget<RPUITask>(find.byType(RPUITask));

      final fakeResult = RPTaskResult(identifier: 'consent_task');
      rpuiTask.onSubmit?.call(fakeResult);

      verify(() => mockRepository.saveAssessmentResult(
          'informed_consent', fakeResult)).called(1);
    });

    testWidgets('has onCancel callback that does not throw',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCarpTestApp(
        ConsentScreen(repository: mockRepository),
      ));
      await tester.pump();

      final rpuiTask = tester.widget<RPUITask>(find.byType(RPUITask));

      expect(() => rpuiTask.onCancel?.call(null), returnsNormally);
    });
  });
}
