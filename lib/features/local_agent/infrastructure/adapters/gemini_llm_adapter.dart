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
  final GenerativeModel? _model;

  GeminiLlmAdapter({String? apiKey})
    : _model = apiKey != null && apiKey.isNotEmpty
          ? GenerativeModel(model: 'gemini-pro', apiKey: apiKey)
          : null;

  @override
  String get modelName => 'gemini-pro';

  @override
  Future<bool> isAvailable() async {
    return _model != null;
  }

  @override
  Future<String> generate(String prompt) async {
    if (_model == null) {
      throw StateError(
        'Gemini API key not configured. Cannot generate summaries.',
      );
    }

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (e) {
      throw Exception('Failed to generate summary: $e');
    }
  }
}
