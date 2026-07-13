// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:research_package/research_package.dart';
import 'package:orionhealth_health/features/clinical_assessments/domain/entities/clinical_assessment_record.dart';
import 'package:orionhealth_health/features/clinical_assessments/infrastructure/datasources/assessment_local_datasource.dart';
import 'package:orionhealth_health/features/clinical_assessments/infrastructure/repositories/assessment_repository_impl.dart';

class MockAssessmentLocalDataSource extends Mock implements AssessmentLocalDataSource {}
class MockRPTaskResult extends Mock implements RPTaskResult {}

void main() {
  late MockAssessmentLocalDataSource mockDataSource;
  late AssessmentRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAssessmentLocalDataSource();
    repository = AssessmentRepositoryImpl(mockDataSource);

    registerFallbackValue(ClinicalAssessmentRecord());
  });

  group('AssessmentRepositoryImpl', () {
    test('saveAssessmentResult delegates to datasource with correctly mapped record', () async {
      final mockResult = MockRPTaskResult();
      when(() => mockResult.toJson()).thenReturn({'id': 'test_result'});
      when(() => mockDataSource.saveRecord(any())).thenAnswer((_) async => {});

      await repository.saveAssessmentResult('phq9', mockResult);

      verify(() => mockDataSource.saveRecord(any(that: predicate<ClinicalAssessmentRecord>((record) {
        return record.assessmentType == 'phq9' &&
               record.resultJson == '{"id":"test_result"}';
      })))).called(1);
    });

    test('getAllAssessments returns records from datasource', () async {
      final records = [
        ClinicalAssessmentRecord(assessmentType: 'type1'),
        ClinicalAssessmentRecord(assessmentType: 'type2'),
      ];
      when(() => mockDataSource.getAllRecords()).thenAnswer((_) async => records);

      final result = await repository.getAllAssessments();

      expect(result, records);
      verify(() => mockDataSource.getAllRecords()).called(1);
    });

    test('saveAssessmentResult propagates errors from datasource', () async {
      final mockResult = MockRPTaskResult();
      when(() => mockResult.toJson()).thenReturn({});
      when(() => mockDataSource.saveRecord(any())).thenThrow(Exception('DB Error'));

      expect(
        () => repository.saveAssessmentResult('type', mockResult),
        throwsA(isA<Exception>()),
      );
    });
  });
}
