import 'package:flutter/material.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/mock_llm_service.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';

void main() {
  runApp(const LocalAgentPreview());
}

class LocalAgentPreview extends StatelessWidget {
  const LocalAgentPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatPage(
        llmService: MockLlmService(),
      ),
    );
  }
}
