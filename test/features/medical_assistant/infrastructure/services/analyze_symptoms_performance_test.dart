import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/services/privacy_anonymizer.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/medical_code.dart';
import 'package:orionhealth_health/features/local_agent/domain/repositories/medical_knowledge_repository.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart';

class MockMedicalKnowledgeRepository extends Mock implements MedicalKnowledgeRepository {}
class MockScrubber extends Mock implements PromptScrubber {}

void main() {
  late MockMedicalKnowledgeRepository mockRepo;
  late MockScrubber mockScrubber;
  late SymphonyClinicalReasonerService reasoner;

  setUp(() {
    mockRepo = MockMedicalKnowledgeRepository();
    mockScrubber = MockScrubber();
    reasoner = SymphonyClinicalReasonerService(mockRepo, mockScrubber);
  });

  test('Benchmark analyzeSymptoms with large number of mappings', () async {
    // Generate 500 mock mappings
    final mappings = List.generate(500, (i) => {
      'symptom': 'Symptom $i',
      'searchTerms': ['Term ${i}_a', 'Term ${i}_b'],
      'matches': [
        {'code': 'CODE_$i', 'score': 0.8, 'reason': 'Reason $i'}
      ]
    });

    when(() => mockRepo.getSymptomMappings()).thenReturn(mappings);
    when(() => mockScrubber.scrub(any(), apiName: any(named: 'apiName'))).thenAnswer((_) async => 'scrubbed text');
    when(() => mockRepo.searchByCode(any())).thenAnswer((invocation) async {
      final code = invocation.positionalArguments[0] as String;
      return MedicalCode(code: code, displayName: 'Test $code', category: 'Symptom', standard: 'ICD-10');
    });

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10; i++) {
      await reasoner.analyzeSymptoms('I have Symptom 250 and also Term 400_a');
    }
    stopwatch.stop();
    print('Baseline analyzeSymptoms time for 10 iterations (500 mappings): ${stopwatch.elapsedMilliseconds}ms');
  });
}
