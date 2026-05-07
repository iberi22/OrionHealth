import 'package:injectable/injectable.dart';
import 'package:openai_dart/openai_dart.dart';

import '../../domain/services/llm_adapter.dart';

/// OpenAI-compatible cloud LLM adapter.
///
/// Supports any OpenAI-compatible API endpoint (OpenAI, Anthropic proxy,
/// OpenRouter, Ollama with OpenAI proxy, etc.) via the `openai_dart` package.
///
/// ## Configuration
/// Call [configure] before first use with the user-provided API key, base URL,
/// and model name. The adapter is disabled until configured.
@LazySingleton(as: LlmAdapter)
@Named('openai')
class OpenaiCompatibleAdapter implements LlmAdapter {
  OpenAIClient? _client;
  String _modelName = '';
  bool _configured = false;

  /// Configure (or reconfigure) the adapter with provider settings.
  Future<void> configure({
    required String apiKey,
    required String modelName,
    String baseUrl = 'https://api.openai.com/v1',
  }) async {
    _modelName = modelName;
    _client?.close();
    _client = OpenAIClient.withApiKey(
      apiKey,
      baseUrl: baseUrl,
    );
    _configured = true;
  }

  @override
  String get modelName => _modelName;

  @override
  Future<bool> isAvailable() async => _configured && _client != null;

  @override
  Future<String> generate(String prompt) async {
    _ensureConfigured();

    try {
      final response = await _client!.chat.completions.create(
        ChatCompletionCreateRequest(
          model: _modelName,
          messages: [ChatMessage.user(prompt)],
          temperature: 0.7,
          maxTokens: 4096,
        ),
      );

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from provider');
      }
      return text;
    } catch (e) {
      throw Exception('API call failed: $e');
    }
  }

  /// Streamed generation. Yields tokens as they arrive.
  Stream<String> generateStream(String prompt) async* {
    _ensureConfigured();

    try {
      final stream = _client!.chat.completions.createStream(
        ChatCompletionCreateRequest(
          model: _modelName,
          messages: [ChatMessage.user(prompt)],
          temperature: 0.7,
          maxTokens: 4096,
        ),
      );

      await for (final event in stream) {
        final delta = event.textDelta;
        if (delta != null && delta.isNotEmpty) {
          yield delta;
        }
      }
    } catch (e) {
      throw Exception('Streaming failed: $e');
    }
  }

  /// Test the connection by sending a minimal request.
  /// Returns true on success, false on any error.
  Future<bool> verifyConnection() async {
    if (!_configured) return false;
    try {
      final response = await _client!.chat.completions.create(
        ChatCompletionCreateRequest(
          model: _modelName,
          messages: [ChatMessage.user('Respond with "ok".')],
          maxTokens: 10,
        ),
      );
      return response.text != null;
    } catch (_) {
      return false;
    }
  }

  void _ensureConfigured() {
    if (!_configured || _client == null) {
      throw StateError(
        'OpenAI adapter not configured. Call configure() with an API key first.',
      );
    }
  }
}
