import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/privacy_anonymizer.dart';
import '../../../../features/user_profile/domain/repositories/user_profile_repository.dart';
import '../../domain/services/llm_adapter.dart';
import 'gemini_model_wrapper.dart';

/// Gemini-based LLM Adapter for HiRAG Phase 2 integration
///
/// This adapter allows isar_agent_memory to use Gemini for automatic
/// summarization of memory layers in the hierarchical RAG system.
@LazySingleton(as: LlmAdapter)
@Named('gemini')
class GeminiLlmAdapter implements LlmAdapter {
  final PromptScrubber _scrubber;
  final UserProfileRepository _userProfileRepository;
  final GeminiModelWrapper? _testWrapper;

  GeminiLlmAdapter({
    required PromptScrubber scrubber,
    required UserProfileRepository userProfileRepository,
    GeminiModelWrapper? modelWrapper,
  })  : _scrubber = scrubber,
        _userProfileRepository = userProfileRepository,
        _testWrapper = modelWrapper;

  String get _apiKey => Platform.environment['GEMINI_API_KEY'] ?? '';

  GeminiModelWrapper? get _model {
    if (_testWrapper != null) return _testWrapper;
    if (_apiKey.isEmpty) return null;
    return GeminiModelWrapper(
      GenerativeModel(model: 'gemini-pro', apiKey: _apiKey),
    );
  }

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
      final responseText = await model.generateContent(scrubbedPrompt);
      return responseText ?? '';
    } catch (e) {
      throw Exception('Failed to generate summary: $e');
    }
  }

  @override
  Stream<int> installModel({required String modelId, required String url}) {
    throw UnsupportedError('Gemini is a cloud model and cannot be installed.');
  }

  @override
  Future<void> uninstallModel(String modelId) async {}

  @override
  Future<void> cancelDownload(String modelId) async {}
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  @override
  String toString() => 'SecurityException: $message';
}
