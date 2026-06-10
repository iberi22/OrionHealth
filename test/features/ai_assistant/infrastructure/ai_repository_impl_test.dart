import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/ai_assistant/domain/entities/ai_query.dart';
import 'package:orionhealth_health/features/ai_assistant/infrastructure/ai_repository_impl.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';

class MockLlmService extends Mock implements LlmService {}

void main() {
  late AiRepositoryImpl repository;
  late MockLlmService mockLlmService;

  setUp(() {
    mockLlmService = MockLlmService();
    repository = AiRepositoryImpl(mockLlmService);
  });

  group('AiRepositoryImpl', () {
    test('askQuestion calls llmService.generate', () {
      const query = AiQuery(text: 'Hello');
      when(() => mockLlmService.generate(any()))
          .thenAnswer((_) => Stream.fromIterable(['Hi']));

      final result = repository.askQuestion(query);

      expect(result, emitsInOrder(['Hi', emitsDone]));
      verify(() => mockLlmService.generate('Hello')).called(1);
    });
  });
}
