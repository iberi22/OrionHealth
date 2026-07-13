import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:research_package/research_package.dart';
import 'package:orionhealth_health/features/clinical_assessments/application/clinical_assessments_cubit.dart';
import 'package:orionhealth_health/features/clinical_assessments/domain/repositories/i_assessment_repository.dart';
import 'package:orionhealth_health/features/clinical_assessments/domain/entities/clinical_assessment_record.dart';

class MockAssessmentRepository extends Mock implements IAssessmentRepository {}

void main() {
  late ClinicalAssessmentsCubit cubit;
  late MockAssessmentRepository mockRepository;

  setUp(() {
    mockRepository = MockAssessmentRepository();
    cubit = ClinicalAssessmentsCubit(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(RPTaskResult(identifier: 'test'));
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is ClinicalAssessmentsInitial', () {
    expect(cubit.state, const ClinicalAssessmentsInitial());
  });

  group('loadAssessments', () {
    test('emits [Loading, Loaded] on success', () async {
      final tAssessments = [
        ClinicalAssessmentRecord(assessmentType: 'test'),
      ];
      when(() => mockRepository.loadAssessments())
          .thenAnswer((_) async => tAssessments);

      final expectedStates = [
        const ClinicalAssessmentsLoading(),
        ClinicalAssessmentsLoaded(tAssessments),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadAssessments();

      verify(() => mockRepository.loadAssessments()).called(1);
    });

    test('emits [Loading, Error] on failure', () async {
      when(() => mockRepository.loadAssessments())
          .thenThrow(Exception('load error'));

      final expectedStates = [
        const ClinicalAssessmentsLoading(),
        const ClinicalAssessmentsError('Exception: load error'),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadAssessments();
    });
  });

  group('saveConsentResult', () {
    test('emits [Loading, ConsentCompleted] when successful', () async {
      final tResult = RPTaskResult(identifier: 'consent');
      when(() => mockRepository.saveAssessmentResult(any(), any()))
          .thenAnswer((_) async => {});

      final expectedStates = [
        const ClinicalAssessmentsLoading(),
        const ConsentCompleted(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.saveConsentResult(tResult);

      verify(() => mockRepository.saveAssessmentResult('informed_consent', tResult)).called(1);
    });

    test('emits [Loading, Error] when repository throws', () async {
      final tResult = RPTaskResult(identifier: 'consent');
      when(() => mockRepository.saveAssessmentResult(any(), any()))
          .thenThrow(Exception('test error'));

      final expectedStates = [
        const ClinicalAssessmentsLoading(),
        const ClinicalAssessmentsError('Exception: test error'),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.saveConsentResult(tResult);
    });
  });

  group('saveSurveyResult', () {
    test('emits [Loading, SurveyCompleted] when successful', () async {
      final tResult = RPTaskResult(identifier: 'survey');
      when(() => mockRepository.saveAssessmentResult(any(), any()))
          .thenAnswer((_) async => {});

      final expectedStates = [
        const ClinicalAssessmentsLoading(),
        const SurveyCompleted(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.saveSurveyResult(tResult);

      verify(() => mockRepository.saveAssessmentResult('health_survey', tResult)).called(1);
    });
  });

  group('States Equatable', () {
    test('ClinicalAssessmentsInitial supports value equality', () {
      expect(const ClinicalAssessmentsInitial(), const ClinicalAssessmentsInitial());
    });
    test('ClinicalAssessmentsLoading supports value equality', () {
      expect(const ClinicalAssessmentsLoading(), const ClinicalAssessmentsLoading());
    });
    test('ClinicalAssessmentsLoaded supports value equality', () {
      final tAssessments = [ClinicalAssessmentRecord(assessmentType: 'test')];
      expect(ClinicalAssessmentsLoaded(tAssessments), ClinicalAssessmentsLoaded(tAssessments));
    });
    test('ConsentCompleted supports value equality', () {
      expect(const ConsentCompleted(), const ConsentCompleted());
    });
    test('SurveyCompleted supports value equality', () {
      expect(const SurveyCompleted(), const SurveyCompleted());
    });
    test('ClinicalAssessmentsError supports value equality', () {
      expect(const ClinicalAssessmentsError('error'), const ClinicalAssessmentsError('error'));
    });
  });
}
