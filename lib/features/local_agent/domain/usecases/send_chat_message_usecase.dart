import 'package:injectable/injectable.dart';
import '../chat_message.dart';
import '../entities/local_model_descriptor.dart';
import '../repositories/medical_knowledge_repository.dart';
import '../services/llm_adapter.dart';

@injectable
class SendChatMessageUseCase {
  final LlmAdapter llmAdapter;
  final MedicalKnowledgeRepository knowledgeRepository;

  SendChatMessageUseCase(this.llmAdapter, this.knowledgeRepository);

  Future<ChatMessage> call(String userMessage, LocalModelDescriptor model) async {
    final context = await knowledgeRepository.getRelevantContext(userMessage);
    return llmAdapter.generateResponse(userMessage, context, model);
  }
}
