import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:injectable/injectable.dart';
import '../../domain/services/llm_adapter.dart';

@LazySingleton(as: LlmAdapter)
@Named('gemma')
class GemmaLlmAdapter implements LlmAdapter {
  dynamic _model;

  GemmaLlmAdapter();

  @override
  String get modelName => 'gemma-4-e2b';

  @override
  Future<bool> isAvailable() async {
    return true;
  }

  @override
  Future<String> generate(String prompt) async {
    _model ??= await FlutterGemma.getActiveModel(
      maxTokens: 2048,
      preferredBackend: PreferredBackend.gpu,
    );

    final chat = await _model.createChat();
    await chat.addQueryChunk(Message.text(text: prompt, isUser: true));

    String fullResponse = '';
    await for (final response in chat.generateChatResponseAsync()) {
      if (response is TextResponse) {
        fullResponse += response.token;
      }
    }

    return fullResponse;
  }
}
