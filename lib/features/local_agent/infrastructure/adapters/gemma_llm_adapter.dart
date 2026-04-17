import 'package:injectable/injectable.dart';
import 'package:orionhealth_health/core/services/aicore_service.dart';
import '../../domain/services/llm_adapter.dart';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Gemma 4 on-device via AICore + ML Kit with Gemini Cloud Fallback
///
/// Tries to use local Gemma 4 E2B/E4B via AICore first.
/// Falls back to Gemini cloud if AICore unavailable or fails.
@LazySingleton(as: LlmAdapter)
@Named('gemma')
class GemmaLlmAdapter implements LlmAdapter {
  final AicoreService _aicoreService;
  bool _localFailed = false;
  GenerativeModel? _geminiModel;

  GemmaLlmAdapter(this._aicoreService);

  String get _apiKey => Platform.environment['GEMINI_API_KEY'] ?? '';

  @override
  String get modelName =>
      _localFailed ? 'gemini-2.0-flash-cloud' : 'gemma-4-e2b-aicore';

  @override
  Future<bool> isAvailable() async {
    if (!_localFailed) {
      final status = await _aicoreService.checkAvailability();
      if (status == AicoreStatus.available) {
        return true;
      }
    }
    return _apiKey.isNotEmpty;
  }

  Future<String> _generateLocal(String prompt) async {
    try {
      if (!_aicoreService.isInitialized) {
        await _aicoreService.initialize(useFullModel: false);
        final avail = await _aicoreService.checkAvailability();
        if (avail == AicoreStatus.downloadable) {
          await _aicoreService.downloadModel();
        }
        await _aicoreService.warmup();
      }
      return await _aicoreService.generateContent(prompt);
    } catch (e) {
      _localFailed = true;
      throw Exception('AICore/Gemma generation failed: $e');
    }
  }

  Future<String> _generateCloud(String prompt) async {
    if (_geminiModel == null) {
      if (_apiKey.isEmpty) {
        throw Exception(
          'GEMINI_API_KEY not configured. Set environment variable.',
        );
      }
      _geminiModel = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
      );
    }

    final response = await _geminiModel!.generateContent([
      Content.text(prompt),
    ]);
    return response.text ?? '';
  }

  @override
  Future<String> generate(String prompt) async {
    if (!_localFailed) {
      try {
        return await _generateLocal(prompt);
      } catch (e) {
        _localFailed = true;
        print('Local Gemma AICore failed, using cloud fallback: $e');
      }
    }
    return await _generateCloud(prompt);
  }
}
