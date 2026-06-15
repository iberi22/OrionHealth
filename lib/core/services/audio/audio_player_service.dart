import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
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
