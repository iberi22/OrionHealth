import '../entities/ai_query.dart';

/// Abstract repository for AI Assistant
abstract class AiRepository {
  /// Asks a question to the AI and returns a stream of response chunks
  Stream<String> askQuestion(AiQuery query);
}
