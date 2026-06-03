import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/services/privacy_anonymizer.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/medical_code.dart';
import 'package:orionhealth_health/features/local_agent/domain/repositories/medical_knowledge_repository.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart';

class MockMedicalKnowledgeRepository extends Mock implements MedicalKnowledgeRepository {}
class MockPromptScrubber extends Mock implements PromptScrubber {}

void main() {
  late MockMedicalKnowledgeRepository mockRepo;
  late MockPromptScrubber mockScrubber;
  late SymphonyClinicalReasonerService reasoner;

  setUp(() {
    mockRepo = MockMedicalKnowledgeRepository();
    mockScrubber = MockPromptScrubber();
    reasoner = SymphonyClinicalReasonerService(mockRepo, mockScrubber);

    // Default scrubber behavior (no-op)
    when(() => mockScrubber.scrub(any(), apiName: any(named: 'apiName')))
        .thenAnswer((invocation) async => invocation.positionalArguments[0] as String);
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
      expect(results.first.score, closeTo(0.9, 0.05));
      expect(results.first.reasoning, contains('Infarto'));
    });

    test('analyzeSymptoms handles typos via fuzzy matching', () async {
      // Arrange
      final symptomsMapping = [
        {
          "symptom": "Fatiga",
          "searchTerms": ["tiredness"],
          "matches": [
            {"code": "R53.83", "score": 0.8, "reason": "Cansancio general"}
          ]
        }
      ];

      final mockCode = MedicalCode(
        code: 'R53.83',
        displayName: 'Fatiga',
        category: 'Symptom',
        standard: 'ICD-10',
      );

      when(() => mockRepo.getSymptomMappings()).thenReturn(symptomsMapping);
      when(() => mockRepo.searchByCode('R53.83')).thenAnswer((_) async => mockCode);

      // Act
      final results = await reasoner.analyzeSymptoms('Siento mucha fatiiga'); // Typo: fatiiga

      // Assert
      expect(results.length, 1);
      expect(results.first.code.code, 'R53.83');
      expect(results.first.score, lessThan(0.8));
      expect(results.first.score, greaterThan(0.6));
      expect(results.first.reasoning, contains('confianza'));
    });

    test('analyzeSymptoms respects negation', () async {
      // Arrange
      final symptomsMapping = [
        {
          "symptom": "Fiebre",
          "matches": [
            {"code": "R50.9", "score": 0.7, "reason": "Temperatura alta"}
          ]
        }
      ];

      when(() => mockRepo.getSymptomMappings()).thenReturn(symptomsMapping);

      // Act
      final results = await reasoner.analyzeSymptoms('No tengo fiebre');

      // Assert
      expect(results, isEmpty);
    });

    test('analyzeSymptoms handles multi-word symptoms and synonyms', () async {
      // Arrange
      final symptomsMapping = [
        {
          "symptom": "Dificultad para respirar",
          "searchTerms": ["disnea", "falta de aire"],
          "matches": [
            {"code": "R06.0", "score": 0.9, "reason": "Problema respiratorio"}
          ]
        }
      ];

      final mockCode = MedicalCode(
        code: 'R06.0',
        displayName: 'Disnea',
        category: 'Respiratory',
        standard: 'ICD-10',
      );

      when(() => mockRepo.getSymptomMappings()).thenReturn(symptomsMapping);
      when(() => mockRepo.searchByCode('R06.0')).thenAnswer((_) async => mockCode);

      // Act
      final results = await reasoner.analyzeSymptoms('Siento mucha falta de aire al caminar');

      // Assert
      expect(results.length, 1);
      expect(results.first.code.code, 'R06.0');
      expect(results.first.reasoning, contains('falta de aire'));
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

    test('analyzeSymptoms handles multi-sentence input with mixed findings', () async {
      final symptomsMapping = [
        {
          "symptom": "Fiebre",
          "matches": [
            {"code": "R50.9", "score": 0.7, "reason": "Temperatura alta"}
          ]
        },
        {
          "symptom": "Tos",
          "matches": [
            {"code": "R05", "score": 0.6, "reason": "Tos seca"}
          ]
        }
      ];

      when(() => mockRepo.getSymptomMappings()).thenReturn(symptomsMapping);
      when(() => mockRepo.searchByCode(any())).thenAnswer((invocation) async {
        final code = invocation.positionalArguments[0] as String;
        return MedicalCode(code: code, displayName: 'Test', category: 'Symptom', standard: 'ICD-10');
      });

      final results = await reasoner.analyzeSymptoms('Tengo mucha fiebre. Pero no tengo tos.');

      expect(results.any((m) => m.code.code == 'R50.9'), true);
      expect(results.any((m) => m.code.code == 'R05'), false); // Negated
    });

    test('analyzeSymptoms handles numbers and units', () async {
      final symptomsMapping = [
        {
          "symptom": "Presión alta",
          "searchTerms": ["140 90", "130 80"],
          "matches": [
            {"code": "I10", "score": 0.9, "reason": "Hipertensión"}
          ]
        }
      ];

      when(() => mockRepo.getSymptomMappings()).thenReturn(symptomsMapping);
      when(() => mockRepo.searchByCode('I10')).thenAnswer((_) async =>
        MedicalCode(code: 'I10', displayName: 'Hipertensión', category: 'CVD', standard: 'ICD-10'));

      // The reasoner tokenizes by \w+, so 140/90 becomes tokens [140, 90]
      final results = await reasoner.analyzeSymptoms('Mi presión es de 140/90 mmHg');

      expect(results.isNotEmpty, true);
      expect(results.first.code.code, 'I10');
    });

    test('analyzeSymptoms handles Portuguese input (partial support)', () async {
      final symptomsMapping = [
        {
          "symptom": "Dolor de pecho",
          "searchTerms": ["dor no peito"],
          "matches": [
            {"code": "I21", "score": 0.9, "reason": "Infarto"}
          ]
        }
      ];

      when(() => mockRepo.getSymptomMappings()).thenReturn(symptomsMapping);
      when(() => mockRepo.searchByCode('I21')).thenAnswer((_) async =>
        MedicalCode(code: 'I21', displayName: 'Infarto', category: 'CVD', standard: 'ICD-10'));

      final results = await reasoner.analyzeSymptoms('Eu tenho dor no peito');

      expect(results.isNotEmpty, true);
      expect(results.first.code.code, 'I21');
    });

    test('analyzeSymptoms handles extremely long input', () async {
      final symptomsMapping = [
        {
          "symptom": "Fatiga",
          "matches": [
            {"code": "R53.83", "score": 0.8, "reason": "Cansancio"}
          ]
        }
      ];

      when(() => mockRepo.getSymptomMappings()).thenReturn(symptomsMapping);
      when(() => mockRepo.searchByCode('R53.83')).thenAnswer((_) async =>
        MedicalCode(code: 'R53.83', displayName: 'Fatiga', category: 'Symptom', standard: 'ICD-10'));

      final longText = 'Fatiga ' * 100;
      final results = await reasoner.analyzeSymptoms(longText);

      expect(results.isNotEmpty, true);
    });

    test('analyzeSymptoms handles null-like/empty input', () async {
      when(() => mockRepo.getSymptomMappings()).thenReturn([]);
      final results = await reasoner.analyzeSymptoms('');
      expect(results, isEmpty);
    });

    test('analyzeSymptoms handles special characters', () async {
      final symptomsMapping = [
        {
          "symptom": "Asma",
          "matches": [
            {"code": "J45", "score": 0.9, "reason": "Asma"}
          ]
        }
      ];

      when(() => mockRepo.getSymptomMappings()).thenReturn(symptomsMapping);
      when(() => mockRepo.searchByCode('J45')).thenAnswer((_) async =>
        MedicalCode(code: 'J45', displayName: 'Asma', category: 'Respiratory', standard: 'ICD-10'));

      final results = await reasoner.analyzeSymptoms('¿Tengo asma?!!! (No lo sé)');

      expect(results.isNotEmpty, true);
      expect(results.first.code.code, 'J45');
    });

    test('analyzeSymptoms scrubs PII from input before processing', () async {
      // Arrange
      final piiInput = 'Mi correo es test@example.com y tengo fiebre';
      final scrubbedInput = 'Mi correo es [EMAIL] y tengo fiebre';

      when(() => mockScrubber.scrub(piiInput, apiName: 'clinical-reasoner'))
          .thenAnswer((_) async => scrubbedInput);

      final symptomsMapping = [
        {
          "symptom": "Fiebre",
          "matches": [
            {"code": "R50.9", "score": 0.7, "reason": "Temperatura alta"}
          ]
        }
      ];

      when(() => mockRepo.getSymptomMappings()).thenReturn(symptomsMapping);
      when(() => mockRepo.searchByCode('R50.9')).thenAnswer((_) async =>
        MedicalCode(code: 'R50.9', displayName: 'Fiebre', category: 'Symptom', standard: 'ICD-10'));

      // Act
      final results = await reasoner.analyzeSymptoms(piiInput);

      // Assert
      verify(() => mockScrubber.scrub(piiInput, apiName: 'clinical-reasoner')).called(1);
      expect(results.isNotEmpty, true);
      expect(results.first.code.code, 'R50.9');
    });
  });
}
