import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import '../../domain/services/llm_adapter.dart';

/// Gemini-based LLM Adapter for HiRAG Phase 2 integration
///
/// This adapter allows isar_agent_memory to use Gemini for automatic
/// summarization of memory layers in the hierarchical RAG system.
@LazySingleton(as: LlmAdapter)
@Named('gemini')
class GeminiLlmAdapter implements LlmAdapter {
  GenerativeModel? _model;

  GeminiLlmAdapter({String? apiKey})
    : _model = apiKey != null && apiKey.isNotEmpty
          ? GenerativeModel(model: 'gemini-pro', apiKey: apiKey)
          : null;

  void updateApiKey(String apiKey) {
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  }

  @override
  String get modelName => 'gemini-pro';

  @override
  Future<bool> isAvailable() async {
    return _model != null;
  }

  Future<String> generateSummary(String prompt) async {
    if (_model == null) {
      throw StateError(
        'Gemini API key not configured. Cannot generate summaries.',
      );
    }

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (e) {
      throw Exception('Failed to generate summary: $e');
    }
  }

  Stream<String> generateStream(String prompt) async* {
    if (_model == null) {
      yield 'Error: Gemini API key not configured.';
      return;
    }

    try {
      final responses = _model!.generateContentStream([Content.text(prompt)]);
      await for (final response in responses) {
        if (response.text != null) {
          yield response.text!;
        }
      }
    } catch (e) {
      yield 'Error calling Gemini: $e';
    }
  }

  // Implementation for LlmService interface (via mixin or similar if needed, but here we just name them differently or use one for both if return types matched)
  // Since they don't match, we have a conflict if we try to implement both as 'generate'

  @override
  Future<String> generate(String prompt) => generateSummary(prompt);
}
