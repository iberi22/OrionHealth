import 'package:injectable/injectable.dart';
import '../../domain/services/llm_adapter.dart';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Gemma GGUF Adapter with Gemini Cloud Fallback
///
/// Tries to load local Gemma GGUF model first.
/// Falls back to Gemini cloud if local model unavailable or fails.
@LazySingleton(as: LlmAdapter)
@Named('gemma')
class GemmaLlmAdapter implements LlmAdapter {
  bool _localFailed = false;
  GenerativeModel? _geminiModel;

  String get _apiKey => Platform.environment['GEMINI_API_KEY'] ?? '';

  @override
  String get modelName => 'gemini-2.0-flash-cloud';

  @override
  Future<bool> isAvailable() async {
    return _apiKey.isNotEmpty;
  }

  Future<String> _generateLocal(String prompt) async {
    // For now, return error to trigger fallback
    // TODO: Implement llama.cpp inference when native build is fixed
    throw Exception('Local GGUF inference not yet available');
  }

  Future<String> _generateCloud(String prompt) async {
    if (_geminiModel == null) {
      if (_apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY not configured. Set environment variable.');
      }
      _geminiModel = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);
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
