import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import 'tts_adapter.dart';
import 'tts_types.dart';

/// Adapter that calls a local Python KittenTTS FastAPI bridge and plays WAV bytes
class KittenBridgeAdapter implements TTSAdapter {
  @override
  TTSCallbacks callbacks;

  @override
  TTSState state = TTSState.uninitialized;

  late final AudioPlayer _player;
  late final http.Client _httpClient;

  String _language = 'es-ES';
  double _rate = 0.5;
  double _pitch = 1.0;

  KittenBridgeAdapter({
    TTSCallbacks? callbacks,
    AudioPlayer? player,
    http.Client? httpClient,
  }) : callbacks = callbacks ?? const TTSCallbacks(),
       _player = player ?? AudioPlayer(),
       _httpClient = httpClient ?? http.Client();

  @override
  Future<void> initialize() async {
    if (state != TTSState.uninitialized) return;
    _player.playerStateStream.listen((plState) {
      if (plState.processingState == ProcessingState.completed) {
        state = TTSState.completed;
        callbacks.onComplete?.call();
      }
    });
    state = TTSState.initialized;
  }

  Uri _buildUri(String path) {
    final base = AppConfig.kittenBridgeUrl ?? 'http://127.0.0.1:8000';
    return Uri.parse(base + path);
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) {
      callbacks.onError?.call('Cannot speak empty text');
      return;
    }

    try {
      callbacks.onStart?.call();
      state = TTSState.starting;

      final reqBody = {
        'text': text,
        'sample_rate': AppConfig.ttsSampleRate,
        'voice': AppConfig.ttsVoice,
        'language': _language,
        'rate': _rate,
        'pitch': _pitch,
      };

      final resp = await _httpClient.post(
        _buildUri('/synthesize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reqBody),
      );

      if (resp.statusCode != 200) {
        throw Exception('Bridge error ${resp.statusCode}: ${resp.body}');
      }

      // Expect audio/wav bytes
      final bytes = resp.bodyBytes;
      await _playWavBytes(bytes);
    } catch (e) {
      state = TTSState.error;
      callbacks.onError?.call('Kitten bridge speak error: $e');
      if (kDebugMode) print('KittenBridgeAdapter error: $e');
    }
  }

  Future<void> _playWavBytes(Uint8List bytes) async {
    // Stop any current playback
    if (_player.playing) {
      await _player.stop();
    }

    // Write to temp file and play with just_audio
    final tempDir = Directory.systemTemp;
    final tempFile = File(
      '${tempDir.path}/kitten_tts_${DateTime.now().millisecondsSinceEpoch}.wav',
    );
    await tempFile.writeAsBytes(bytes);
    await _player.setFilePath(tempFile.path);
    unawaited(
      _player.playerStateStream.firstWhere(
        (s) => s.processingState == ProcessingState.completed,
      ).then((_) => tempFile.delete().catchError((_) {
        return tempFile;
      })),
    );
    await _player.play();
  }

  @override
  Future<void> stop() async {
    if (_player.playing) {
      await _player.stop();
    }
    state = TTSState.stopped;
    callbacks.onCancel?.call();
  }

  @override
  Future<void> pause() async {
    if (_player.playing) {
      await _player.pause();
    }
    state = TTSState.paused;
    callbacks.onPause?.call();
  }

  @override
  Future<List<String>> getLanguages() async {
    return ['es-ES', 'en-US'];
  }

  @override
  Future<List<Map<String, String>>> getVoices() async {
    return [
      {'name': AppConfig.ttsVoice, 'lang': _language},
    ];
  }

  @override
  Future<void> setLanguage(String language) async {
    _language = language;
  }

  @override
  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    _rate = rate;
  }

  @override
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
  }
}
