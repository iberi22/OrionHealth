import 'package:injectable/injectable.dart';
import '../../local_agent/infrastructure/llm_service.dart';
import '../domain/entities/ai_query.dart';
import '../domain/repositories/ai_repository.dart';

@LazySingleton(as: AiRepository)
class AiRepositoryImpl implements AiRepository {
  final LlmService _llmService;

  AiRepositoryImpl(this._llmService);

  @override
  Stream<String> askQuestion(AiQuery query) {
    return _llmService.generate(query.text);
  }
}
