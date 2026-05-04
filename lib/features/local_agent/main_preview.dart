import 'package:flutter/material.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';

void main() {
  configureDependencies();
  runApp(const LocalAgentPreview());
}

class LocalAgentPreview extends StatelessWidget {
  const LocalAgentPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatPage(
        llmService: getIt<LlmService>(),
      ),
    );
  }
}
