import '../entities/ai_query.dart';

abstract class IAiRepository {
  Stream<String> askStreaming(AiQuery query);
}
