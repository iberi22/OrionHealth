import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/services/llm_adapter.dart';

/// Gemma 4 adapter with hybrid local/cloud strategy.
///
/// Priority:
/// 1. Gemma 4 local via ML Kit GenAI Prompt API (AICore)
/// 2. Fallback: Gemini cloud via google_generative_ai
///
/// The adapter automatically detects whether AICore + Gemma 4
/// model is available on the device and routes to local inference
/// when possible. Falls back gracefully to Gemini cloud API.
///
/// Local models supported:
///   - Gemma 4 E2B (2B params) ~1.2 GB, fast for everyday tasks
///   - Gemma 4 E4B (4B params) ~2.4 GB, precision for deep analysis
///
/// Device requirements:
///   - Android 8+ (API 24+)
///   - AICore beta installed (Pixel 7+, Samsung S25+)
///   - Gemma 4 model downloaded via AICore app
///
/// See: docs/gemma4-integration.md for full setup guide.
/// Legacy adapter — kept for reference. Use FlutterGemmaAdapter instead.
// @LazySingleton(as: LlmAdapter)
// @Named('gemma')
class GemmaLlmAdapter implements LlmAdapter {
  static const _channel = MethodChannel('com.orionhealth/gemma4');
  GenerativeModel? _geminiModel;

  String get _apiKey => Platform.environment['GEMINI_API_KEY'] ?? '';

  @override
  String get modelName => 'gemma-4-e2b-local';

  @override
  Future<bool> isAvailable() async {
    // Check if local Gemma 4 is available (AICore + model downloaded)
    try {
      final localAvailable = await _channel
          .invokeMethod<bool>('isAvailable');
      if (localAvailable == true) return true;
    } catch (_) {
      // MethodChannel not available — device doesn't support AICore
      // or plugin not registered. Fall through to cloud check.
    }

    // Fallback: check if Gemini cloud API key is configured
    return _apiKey.isNotEmpty;
  }

  @override
  Future<String> generate(String prompt) async {
    // Attempt 1: Local Gemma 4 via ML Kit Prompt API (AICore)
    final localResult = await _tryLocalGeneration(prompt);
    if (localResult != null) return localResult;

    // Attempt 2: Fallback to Gemini cloud
    return _generateViaCloud(prompt);
  }

  /// Try to generate using on-device Gemma 4 via AICore/ML Kit
  Future<String?> _tryLocalGeneration(String prompt) async {
    try {
      final result = await _channel.invokeMethod<String>('generate', {
        'prompt': prompt,
        'model': 'gemma-4-e2b',
      });
      if (result != null && result.isNotEmpty) return result;
    } catch (e) {
      // Local inference failed — device might not support AICore
      // or model not downloaded. Graceful fallback.
    }
    return null;
  }

  /// Fallback: generate using Gemini cloud API
  Future<String> _generateViaCloud(String prompt) async {
    if (_geminiModel == null) {
      if (_apiKey.isEmpty) {
        throw Exception(
          'GEMINI_API_KEY not configured and local Gemma 4 unavailable. '
          'Set environment variable or run on a supported device.',
        );
      }
      _geminiModel = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
      );
    }

    try {
      final response = await _geminiModel!.generateContent([
        Content.text(prompt),
      ]);
      return response.text ?? '';
    } catch (e) {
      throw Exception('Gemma 4 generation failed (local + cloud): $e');
    }
  }

  @override
  Stream<int> installModel({required String modelId, required String url}) {
    throw UnsupportedError('GemmaLlmAdapter is legacy and does not support installations.');
  }

  @override
  Future<List<String>> listInstalledModels() async {
    return [];
  }

  @override
  Future<void> uninstallModel(String modelId) async {}

  @override
  Future<void> cancelDownload(String modelId) async {}

  @override
  Future<bool> isModelInstalled(String modelId) async => false;
}
