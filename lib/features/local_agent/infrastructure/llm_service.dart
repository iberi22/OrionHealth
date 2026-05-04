/// Abstract service for streaming LLM generation
abstract class LlmService {
  Stream<String> generate(String prompt);
}
