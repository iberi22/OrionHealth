import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';

class MockLlmService implements LlmService {
  @override
  Stream<String> generate(String prompt) async* {
    final response = "This is a mock response to: $prompt. Orion AI is working in mock mode.";
    for (var i = 0; i < response.length; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      yield response[i];
    }
  }
}
