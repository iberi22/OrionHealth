import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/privacy_anonymizer.dart';
import '../../../../features/user_profile/domain/repositories/user_profile_repository.dart';
import '../../domain/services/llm_adapter.dart';

/// Gemini-based LLM Adapter for HiRAG Phase 2 integration
///
/// This adapter allows isar_agent_memory to use Gemini for automatic
/// summarization of memory layers in the hierarchical RAG system.
@LazySingleton(as: LlmAdapter)
@Named('gemini')
class GeminiLlmAdapter implements LlmAdapter {
  final PromptScrubber _scrubber;
  final UserProfileRepository _userProfileRepository;

  GeminiLlmAdapter({
    required PromptScrubber scrubber,
    required UserProfileRepository userProfileRepository,
  })  : _scrubber = scrubber,
        _userProfileRepository = userProfileRepository;

  String get _apiKey => Platform.environment['GEMINI_API_KEY'] ?? '';

  GenerativeModel? get _model => _apiKey.isNotEmpty
      ? GenerativeModel(model: 'gemini-pro', apiKey: _apiKey)
      : null;

  @override
  String get modelName => 'gemini-pro';

  @override
  Future<bool> isAvailable() async {
    return _model != null;
  }

  @override
  Future<List<String>> listInstalledModels() async => [];

  @override
  Future<bool> isModelInstalled(String modelId) async => false;

  @override
  Future<String> generate(String prompt) async {
    final profile = await _userProfileRepository.getUserProfile();
    if (profile?.allowCloudApi == false) {
      throw SecurityException('Cloud API calls are disabled for privacy.');
    }

    final model = _model;
    if (model == null) {
      throw StateError(
        'Gemini API key not configured. Cannot generate summaries.',
      );
    }

    try {
      final scrubbedPrompt = await _scrubber.scrub(prompt, apiName: 'gemini');
      final response = await model.generateContent([Content.text(scrubbedPrompt)]);
      return response.text ?? '';
    } catch (e) {
      throw Exception('Failed to generate summary: $e');
    }
  }
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  @override
  String toString() => 'SecurityException: $message';
}
