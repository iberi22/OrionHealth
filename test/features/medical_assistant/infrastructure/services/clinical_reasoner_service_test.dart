import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/medical_code.dart';
import 'package:orionhealth_health/features/local_agent/domain/repositories/medical_knowledge_repository.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart';

class MockMedicalKnowledgeRepository extends Mock implements MedicalKnowledgeRepository {}

void main() {
  late MockMedicalKnowledgeRepository mockRepo;
  late SymphonyClinicalReasonerService reasoner;

  setUp(() {
    mockRepo = MockMedicalKnowledgeRepository();
    reasoner = SymphonyClinicalReasonerService(mockRepo);
  });

  group('ClinicalReasonerService', () {
    test('analyzeSymptoms returns correct matches for common symptoms', () async {
      // Arrange
      final symptomsMapping = [
        {
          "symptom": "Dolor de pecho",
          "searchTerms": ["chest pain"],
          "matches": [
            {"code": "I21", "score": 0.9, "reason": "Infarto"}
          ]
        }
      ];

      final mockCode = MedicalCode(
        code: 'I21',
        displayName: 'Infarto agudo de miocardio',
        category: 'Cardiovascular',
        standard: 'ICD-10',
        mentalHealthImpact: 'Ansiedad severa',
      );

      when(() => mockRepo.getSymptomMappings()).thenReturn(symptomsMapping);
      when(() => mockRepo.searchByCode('I21')).thenAnswer((_) async => mockCode);

      // Act
      final results = await reasoner.analyzeSymptoms('Tengo un fuerte dolor de pecho');

      // Assert
      expect(results.length, 1);
      expect(results.first.code.code, 'I21');
      expect(results.first.score, 0.9);
      expect(results.first.reasoning, contains('Infarto'));
    });

    test('synthesizeHolisticSummary generates correct mental-physical bridge', () {
      // Arrange
      final codes = [
        MedicalCode(
          code: 'I21',
          displayName: 'Infarto',
          category: 'Cardiovascular',
          standard: 'ICD-10',
          mentalHealthImpact: 'Riesgo de ansiedad reactiva.',
        ),
        MedicalCode(
          code: 'F32',
          displayName: 'Depresión',
          category: 'Mental',
          standard: 'ICD-10',
          physicalHealthImpact: 'Alteración del cortisol.',
        ),
      ];

      // Act
      final summary = reasoner.synthesizeHolisticSummary(codes);

      // Assert
      expect(summary, contains('Impacto en Salud Mental'));
      expect(summary, contains('Riesgo de ansiedad reactiva'));
      expect(summary, contains('Manifestaciones Físicas'));
      expect(summary, contains('Alteración del cortisol'));
    });
  });
}
