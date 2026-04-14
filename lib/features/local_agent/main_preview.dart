import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const LocalAgentPreview());
}

class LocalAgentPreview extends StatelessWidget {
  const LocalAgentPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatPage(
        llmService: GetIt.I<LlmService>(),
      ),
    );
  }
}
