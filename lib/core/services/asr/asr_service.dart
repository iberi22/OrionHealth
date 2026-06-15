import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:orion/services/asr/asr_types.dart';
import 'package:orion/services/asr/local_asr_service.dart';
import 'package:orion/services/asr/sherpa_onnx_asr_service.dart';
import 'package:orion/services/asr/mock_asr_service.dart';
import 'package:orion/services/asr/asr_settings.dart';

/// Central factory/manager for ASR services.
class AsrService {
  static final AsrService _instance = AsrService._internal();
  factory AsrService() => _instance;
  AsrService._internal();

  LocalAsrService? _adapter;
  bool _isInitialized = false;

  final _stateController = StreamController<AsrState>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<AsrState> get stateStream => _stateController.stream;
  Stream<String> get errorStream => _errorController.stream;
  AsrState get currentState => _adapter?.state ?? AsrState.uninitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final provider = await AsrSettings.getAsrProvider();
    _adapter = _createAdapter(provider);

    _adapter!.stateStream.listen((s) => _stateController.add(s));
    _adapter!.errorStream.listen((e) => _errorController.add(e));

    await _adapter!.initialize();
    _isInitialized = true;
  }

  LocalAsrService _createAdapter(String provider) {
    if (provider == 'ondevice') {
      return SherpaOnnxAsrService();
    }
    return MockAsrService();
  }

  Future<String> transcribe(Uint8List audioBytes) async {
    if (!_isInitialized) await initialize();
    return await _adapter!.transcribe(audioBytes);
  }

  void dispose() {
    _adapter?.dispose();
    _stateController.close();
    _errorController.close();
  }
}
