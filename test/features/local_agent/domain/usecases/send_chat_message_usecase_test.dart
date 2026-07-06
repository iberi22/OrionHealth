import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/domain/chat_message.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/local_model_descriptor.dart';
import 'package:orionhealth_health/features/local_agent/domain/repositories/medical_knowledge_repository.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';
import 'package:orionhealth_health/features/local_agent/domain/usecases/send_chat_message_usecase.dart';

class MockLlmAdapter extends Mock implements LlmAdapter {}
class MockMedicalKnowledgeRepository extends Mock implements MedicalKnowledgeRepository {}
class FakeLocalModelDescriptor extends Fake implements LocalModelDescriptor {}

void main() {
  late SendChatMessageUseCase useCase;
  late MockLlmAdapter mockLlmAdapter;
  late MockMedicalKnowledgeRepository mockKnowledgeRepository;

  setUpAll(() {
    registerFallbackValue(FakeLocalModelDescriptor());
  });

  setUp(() {
    mockLlmAdapter = MockLlmAdapter();
    mockKnowledgeRepository = MockMedicalKnowledgeRepository();
    useCase = SendChatMessageUseCase(mockLlmAdapter, mockKnowledgeRepository);
  });

  group('SendChatMessageUseCase', () {
    const tMessage = 'What is ICD-10?';
    const tContext = 'ICD-10 is...';
    final tModel = LocalModelDescriptor(
      id: 'id',
      displayName: 'name',
      modelType: ModelType.gemmaIt,
      sizeLabel: '100MB',
      minRamMb: 1024,
      url: 'url',
    );
    final tResponse = ChatMessage(role: ChatRole.assistant, content: 'Response', timestamp: DateTime.now());

    test('should get context and generate response', () async {
      when(() => mockKnowledgeRepository.getRelevantContext(tMessage)).thenAnswer((_) async => tContext);
      when(() => mockLlmAdapter.generateResponse(tMessage, tContext, any())).thenAnswer((_) async => tResponse);

      final result = await useCase(tMessage, tModel);

      expect(result, tResponse);
      verify(() => mockKnowledgeRepository.getRelevantContext(tMessage)).called(1);
      verify(() => mockLlmAdapter.generateResponse(tMessage, tContext, tModel)).called(1);
    });
  });
}
