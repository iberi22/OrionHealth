import 'package:injectable/injectable.dart';
import '../../domain/services/llm_adapter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Gemma GGUF Adapter with Gemini Cloud Fallback
///
/// Tries to load local Gemma GGUF model first.
/// Falls back to Gemini cloud if local model unavailable or fails.
@LazySingleton(as: LlmAdapter)
@Named('gemma')
class GemmaLlmAdapter implements LlmAdapter {
  bool _isLoaded = false;
  bool _localFailed = false;
  GenerativeModel? _geminiModel;
  static const String _modelPath = 'gemma-4-E2B-it-uncensored-Q4_K_M.gguf';

  GemmaLlmAdapter() {
    // Initialize Gemini for fallback - use GEMINI_API_KEY from environment
    final apiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (apiKey.isNotEmpty) {
      _geminiModel = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    }
  }

  @override
  String get modelName => _isLoaded ? 'gemma-4-e2b-local' : 'gemini-2.0-flash-cloud';

  @override
  Future<bool> isAvailable() async {
    return true; // Always available via fallback
  }

  Future<String> _generateLocal(String prompt) async {
    // For now, return error to trigger fallback
    // TODO: Implement llama.cpp inference when native build is fixed
    throw Exception('Local GGUF inference not yet available');
  }

  Future<String> _generateCloud(String prompt) async {
    if (_geminiModel == null) {
      // Try to get API key from environment at runtime
      final apiKey = Platform.environment['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY not configured. Set environment variable.');
      }
      _geminiModel = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    }
    
    final response = await _geminiModel!.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }

  @override
  Future<String> generate(String prompt) async {
    // Try local first if not failed
    if (!_localFailed) {
      try {
        return await _generateLocal(prompt);
      } catch (e) {
        _localFailed = true;
        print('Local Gemma failed, using cloud fallback: $e');
      }
    }
    
    // Fallback to Gemini cloud
    return await _generateCloud(prompt);
  }
}
