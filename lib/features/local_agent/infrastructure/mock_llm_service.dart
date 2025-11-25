import 'package:injectable/injectable.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';

@LazySingleton(as: LlmService)
class MockLlmService implements LlmService {
  @override
  Stream<String> generate(String prompt) async* {
    final mockResponse =
        "This is a mock response from the LlmService. It supports **Markdown** and will be displayed in the chat UI. Here are some examples:\n\n"
        "* Bullet point 1\n"
        "* Bullet point 2\n\n"
        "1. Numbered list item 1\n"
        "2. Numbered list item 2\n\n"
        "Here is some code:\n"
        "```dart\n"
        "void main() {\n"
        "  print('Hello, OrionHealth!');\n"
        "}\n"
        "```";

    for (var i = 0; i < mockResponse.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      yield mockResponse[i];
    }
  }
}
