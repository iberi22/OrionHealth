import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:orionhealth_health/core/services/app_logger.dart';
import 'package:orionhealth_health/core/services/audio/audio_recorder_service.dart';
import 'package:orionhealth_health/core/services/tts/tts_adapter.dart';
import 'package:orionhealth_health/core/services/tts/sherpa_onnx_adapter.dart';

enum AudioState { idle, recording, processing, speaking, playing, playbackCompleted, playbackStopped, ttsStopped, error }

/// Legacy alias — voice chat screens reference `AudioService`.
@lazySingleton
class AudioService extends AudioPlayerService {
  late final AudioRecorderService _recorder;
  final StreamController<AudioState> _audioStateController =
      StreamController<AudioState>.broadcast();

  AudioService({super.player, AudioRecorderService? recorder})
    : _recorder = recorder ?? AudioRecorderService();

  Stream<double> get currentVolumeStream => _recorder.currentVolumeStream;
  Stream<AudioState> get stateStream => _audioStateController.stream;

  SherpaOnnxTTSAdapter? _tts;
  bool _ttsInitialized = false;

  Future<void> _initTTS() async {
    if (_ttsInitialized) return;
    try {
      _tts = SherpaOnnxTTSAdapter(
        callbacks: TTSCallbacks(
          onStart: () {
            _audioStateController.add(AudioState.speaking);
          },
          onComplete: () {
            _audioStateController.add(AudioState.playbackCompleted);
          },
          onCancel: () {
            _audioStateController.add(AudioState.ttsStopped);
          },
          onError: (msg) {
            _errorController.add(msg ?? 'TTS error');
            _audioStateController.add(AudioState.error);
          },
        ),
      );
      await _tts!.initialize();
      _ttsInitialized = true;
    } catch (e) {
      AppLogger.e('AudioService', 'TTS init failed — using playAudioBytes fallback', error: e);
      _ttsInitialized = false;
    }
  }

  Future<void> speakText(String text) async {
    await _initTTS();
    if (_tts != null && _ttsInitialized) {
      _audioStateController.add(AudioState.speaking);
      await _tts!.speak(text);
    } else {
      _errorController.add('TTS not initialized — no speech available');
      _audioStateController.add(AudioState.error);
    }
  }

  Future<void> stopTTS() async {
    try {
      await _tts?.stop();
      _audioStateController.add(AudioState.ttsStopped);
    } catch (e) {
      _errorController.add('Failed to stop TTS: $e');
    }
  }

  Future<void> stopAll() async {
    await stopPlayback();
    await stopTTS();
  }

  Future<void> startRecording() async {
    await _recorder.startRecording();
  }

  Future<Uint8List?> stopRecording() async {
    return await _recorder.stopRecording();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _audioStateController.close();
    super.dispose();
  }
}

class AudioPlayerService {
  late final AudioPlayer _player;
  bool _isPlaying = false;

  AudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer();
  bool _isInitialized = false;

  final StreamController<bool> _playbackStateController =
      StreamController<bool>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  Stream<bool> get playbackStateStream => _playbackStateController.stream;
  Stream<String> get errorStream => _errorController.stream;

  bool get isPlaying => _isPlaying;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _playbackStateController.add(false);
      }
    });
    _isInitialized = true;
  }

  Future<void> playAudioBytes(Uint8List audioBytes) async {
    if (!_isInitialized) await initialize();
    if (_isPlaying) await stopPlayback();

    try {
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.wav',
      );
      await tempFile.writeAsBytes(audioBytes);

      _isPlaying = true;
      _playbackStateController.add(true);

      await _player.setFilePath(tempFile.path);
      await _player.play();
    } catch (e) {
      _isPlaying = false;
      _playbackStateController.add(false);
      _errorController.add('Failed to play audio: $e');
    }
  }

  Future<void> stopPlayback() async {
    if (!_isPlaying) return;
    try {
      await _player.stop();
      _isPlaying = false;
      _playbackStateController.add(false);
    } catch (e) {
      _errorController.add('Failed to stop playback: $e');
    }
  }

  void dispose() {
    _player.dispose();
    _playbackStateController.close();
    _errorController.close();
  }
}
