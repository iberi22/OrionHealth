import 'package:flutter/foundation.dart';

import 'tts_adapter.dart';
import 'tts_types.dart';

/// Adapter that wraps the platform system TTS via flutter_tts
///
/// NOTE: flutter_tts is not available in the current dependency set (dio HTTP 403
/// on pub.dev for Orion Health). System TTS has been stubbed out — all speak/stop
/// calls return errors directing users to use the sherpa_onnx adapter instead.
/// If flutter_tts becomes available in the future, restore the real implementation.
class SystemTTSAdapter implements TTSAdapter {
  @override
  TTSCallbacks callbacks;

  @override
  TTSState state = TTSState.uninitialized;

  SystemTTSAdapter({TTSCallbacks? callbacks})
    : callbacks = callbacks ?? const TTSCallbacks();

  @override
  Future<void> initialize() async {
    if (state != TTSState.uninitialized) return;
    callbacks.onError?.call(
      'System TTS not available — use sherpa_onnx adapter instead',
    );
    state = TTSState.error;
    if (kDebugMode) {
      print(
        'SystemTTSAdapter: flutter_tts not available, stubbed out. Use sherpa_onnx.',
      );
    }
  }

  @override
  Future<void> speak(String text) async {
    callbacks.onError?.call(
      'System TTS not available — use sherpa_onnx adapter instead',
    );
  }

  @override
  Future<void> stop() async {
    state = TTSState.stopped;
  }

  @override
  Future<void> pause() async {
    state = TTSState.paused;
  }

  @override
  Future<List<String>> getLanguages() async {
    return ['es-ES', 'en-US'];
  }

  @override
  Future<List<Map<String, String>>> getVoices() async {
    return [
      {'name': 'es-ES', 'lang': 'es-ES'},
    ];
  }

  @override
  Future<void> setLanguage(String language) async {
    // No-op: not available
  }

  @override
  Future<void> setPitch(double pitch) async {
    // No-op: not available
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    // No-op: not available
  }

  @override
  Future<void> setVolume(double volume) async {
    // No-op: not available
  }

  @override
  void dispose() {
    // No-op: not available
  }
}
