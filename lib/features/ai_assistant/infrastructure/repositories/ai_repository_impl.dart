import 'package:injectable/injectable.dart';
import '../../../../features/local_agent/infrastructure/llm_service.dart';
import '../../domain/entities/ai_query.dart';
import '../../domain/repositories/i_ai_repository.dart';

@Injectable(as: IAiRepository)
class AiRepositoryImpl implements IAiRepository {
  final LlmService _llmService;

  AiRepositoryImpl(this._llmService);

  @override
  Stream<String> askStreaming(AiQuery query) {
    return _llmService.generate(query.text);
  }
}
