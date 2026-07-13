import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:isar/isar.dart';
import 'package:research_package/research_package.dart';
import 'package:orionhealth_health/features/clinical_assessments/data/assessment_repository.dart';
import 'package:orionhealth_health/features/clinical_assessments/domain/entities/clinical_assessment_record.dart';
import 'dart:convert';

/// Custom minimal Isar implementation for testing.
/// Extends Fake (from mocktail) to get noSuchMethod fallback,
/// then manually overrides only the methods used by AssessmentRepository.
class FakeIsar extends Fake implements Isar {
  final IsarCollection<ClinicalAssessmentRecord> _clinicalCollection;

  FakeIsar(this._clinicalCollection);

  @override
  IsarCollection<T> collection<T>() {
    if (T == ClinicalAssessmentRecord) {
      return _clinicalCollection as IsarCollection<T>;
    }
    throw UnimplementedError('collection<$T> not mocked');
  }

  @override
  IsarCollection<ClinicalAssessmentRecord> get clinicalAssessmentRecords =>
      _clinicalCollection;

  @override
  Future<T> writeTxn<T>(Future<T> Function() callback,
      {bool silent = false, bool? requiresFlutter}) async {
    return await callback();
  }
}

class MockCollection extends Mock
    implements IsarCollection<ClinicalAssessmentRecord> {}

void main() {
  late FakeIsar fakeIsar;
  late MockCollection mockCollection;
  late AssessmentRepository repository;

  setUp(() {
    mockCollection = MockCollection();
    fakeIsar = FakeIsar(mockCollection);
    repository = AssessmentRepository(fakeIsar);
  });

  setUpAll(() {
    registerFallbackValue(ClinicalAssessmentRecord());
  });

  group('AssessmentRepository Tests', () {
    test('saveAssessmentResult calls put on clinicalAssessmentRecords',
        () async {
      ClinicalAssessmentRecord? savedRecord;

      when(() => mockCollection.put(any())).thenAnswer((invocation) async {
        savedRecord =
            invocation.positionalArguments.first as ClinicalAssessmentRecord;
        return 1;
      });

      final fakeResult = RPTaskResult(identifier: 'test_task');
      await repository.saveAssessmentResult('survey_test', fakeResult);

      expect(savedRecord, isNotNull);
      expect(savedRecord!.assessmentType, 'survey_test');
      expect(savedRecord!.resultJson, jsonEncode(fakeResult.toJson()));
      expect(savedRecord!.completedAt, isNotNull);
    });

    test('saveAssessmentResult stores consent type correctly', () async {
      String? storedType;

      when(() => mockCollection.put(any())).thenAnswer((invocation) async {
        final record =
            invocation.positionalArguments.first as ClinicalAssessmentRecord;
        storedType = record.assessmentType;
        return 1;
      });

      final fakeResult = RPTaskResult(identifier: 'consent_task');
      await repository.saveAssessmentResult('informed_consent', fakeResult);

      expect(storedType, 'informed_consent');
    });

    test('saveAssessmentResult stores health_survey type correctly',
        () async {
      String? storedType;

      when(() => mockCollection.put(any())).thenAnswer((invocation) async {
        final record =
            invocation.positionalArguments.first as ClinicalAssessmentRecord;
        storedType = record.assessmentType;
        return 1;
      });

      final fakeResult = RPTaskResult(identifier: 'health_survey_task');
      await repository.saveAssessmentResult('health_survey', fakeResult);

      expect(storedType, 'health_survey');
    });
  });
}
