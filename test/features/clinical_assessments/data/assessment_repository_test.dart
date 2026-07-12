import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:isar/isar.dart';
import 'package:research_package/research_package.dart';
import 'package:orionhealth_health/features/clinical_assessments/data/assessment_repository.dart';
import 'package:orionhealth_health/features/clinical_assessments/domain/entities/clinical_assessment_record.dart';
import 'dart:convert';

class MockIsar extends Mock implements Isar {}

// We need to mock the specific collection
abstract class IsarCollectionClinicalAssessmentRecord extends IsarCollection<ClinicalAssessmentRecord> {}
class MockIsarCollection extends Mock implements IsarCollectionClinicalAssessmentRecord {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late AssessmentRepository repository;

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = AssessmentRepository(mockIsar);

    // Provide the collection to isar
    when(() => mockIsar.clinicalAssessmentRecords).thenReturn(mockCollection);
    
    // Register fallback for the generic writeTxn callback
    registerFallbackValue(() async {});
    
    // Mock writeTxn to execute the callback
    when(() => mockIsar.writeTxn<dynamic>(any(), silent: any(named: 'silent')))
        .thenAnswer((invocation) async {
      final callback = invocation.positionalArguments.first as Future<dynamic> Function();
      return await callback();
    });
  });

  setUpAll(() {
    registerFallbackValue(ClinicalAssessmentRecord());
  });

  group('AssessmentRepository Tests', () {
    test('saveAssessmentResult saves the correct record to Isar', () async {
      // Arrange
      final fakeResult = RPTaskResult(identifier: 'test_task');
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      // Act
      await repository.saveAssessmentResult('survey_test', fakeResult);

      // Assert
      final captured = verify(() => mockCollection.put(captureAny())).captured;
      expect(captured.length, 1);
      final record = captured.first as ClinicalAssessmentRecord;
      
      expect(record.assessmentType, 'survey_test');
      expect(record.resultJson, jsonEncode(fakeResult.toJson()));
      expect(record.completedAt, isNotNull);
    });
  });
}
