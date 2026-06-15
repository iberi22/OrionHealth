import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  DateTime? _recordingStartTime;
  Timer? _volumeMonitoringTimer;

  final StreamController<Duration> _recordingDurationController =
      StreamController<Duration>.broadcast();
  final StreamController<List<double>> _volumeLevelsController =
      StreamController<List<double>>.broadcast();
  final StreamController<double> _currentVolumeController =
      StreamController<double>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  Stream<Duration> get recordingDurationStream =>
      _recordingDurationController.stream;
  Stream<List<double>> get volumeLevelsStream => _volumeLevelsController.stream;
  Stream<double> get currentVolumeStream => _currentVolumeController.stream;
  Stream<String> get errorStream => _errorController.stream;

  bool get isRecording => _isRecording;

  Future<bool> requestMicrophonePermission() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (hasPermission) return true;

      final status = await Permission.microphone.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else if (status == PermissionStatus.permanentlyDenied) {
        _errorController.add(
          'Microphone permission permanently denied. Please enable it in settings.',
        );
      } else {
        _errorController.add('Microphone permission denied');
      }
      return false;
    } catch (e) {
      _errorController.add('Error requesting microphone permission: $e');
      return false;
    }
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    try {
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) return;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final recordPath = '${Directory.systemTemp.path}/audio_recording_$timestamp.wav';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: recordPath,
      );

      _isRecording = true;
      _recordingStartTime = DateTime.now();
      _startRecordingDurationTracking();
      _startVolumeMonitoring();
    } catch (e) {
      _errorController.add('Failed to start recording: $e');
    }
  }

  Future<Uint8List?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final path = await _recorder.stop();
      _isRecording = false;
      _volumeMonitoringTimer?.cancel();

      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final audioData = await file.readAsBytes();
          try {
            await file.delete();
          } catch (e) {
            if (kDebugMode) print('AudioRecorderService: Failed to delete temp file: $e');
          }
          return audioData;
        }
      }
      _errorController.add('Recording file not found');
      return null;
    } catch (e) {
      _isRecording = false;
      _errorController.add('Failed to stop recording: $e');
      return null;
    }
  }

  void _startRecordingDurationTracking() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRecording || _recordingStartTime == null) {
        timer.cancel();
        return;
      }
      final duration = DateTime.now().difference(_recordingStartTime!);
      _recordingDurationController.add(duration);
    });
  }

  void _startVolumeMonitoring() {
    _volumeMonitoringTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      final currentVolume = _generateDemoVolume();
      _currentVolumeController.add(currentVolume);
      final volumeLevels = _generateVolumeLevels(currentVolume);
      _volumeLevelsController.add(volumeLevels);
    });
  }

  double _generateDemoVolume() {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final baseVolume = 0.3 + (math.sin(time * 2.0) * 0.4);
    final noise = (math.Random().nextDouble() - 0.5) * 0.2;
    return (baseVolume + noise).clamp(0.0, 1.0);
  }

  List<double> _generateVolumeLevels(double currentVolume) {
    const int bands = 8;
    final levels = <double>[];
    for (int i = 0; i < bands; i++) {
      final frequencyMultiplier = 1.0 - (i / bands * 0.5);
      final randomVariation = (math.Random().nextDouble() - 0.5) * 0.2;
      final level = (currentVolume * frequencyMultiplier + randomVariation)
          .clamp(0.0, 1.0);
      levels.add(level);
    }
    return levels;
  }

  void dispose() {
    _recorder.dispose();
    _volumeMonitoringTimer?.cancel();
    _recordingDurationController.close();
    _volumeLevelsController.close();
    _currentVolumeController.close();
    _errorController.close();
  }
}
