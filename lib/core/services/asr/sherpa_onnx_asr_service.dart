import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import 'asr_types.dart';
import 'local_asr_service.dart';
import 'asr_model_manager.dart';
import 'asr_settings.dart';

/// Implementation of LocalAsrService using sherpa_onnx.
class SherpaOnnxAsrService implements LocalAsrService {
  @override
  AsrState state = AsrState.uninitialized;

  @override
  AsrCallbacks callbacks;

  final _stateController = StreamController<AsrState>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  @override
  Stream<AsrState> get stateStream => _stateController.stream;
  @override
  Stream<String> get errorStream => _errorController.stream;

  SherpaOnnxAsrService({AsrCallbacks? callbacks})
      : callbacks = callbacks ?? const AsrCallbacks();

  OfflineRecognizer? _recognizer;

  @override
  Future<void> initialize() async {
    if (state == AsrState.ready || state == AsrState.initializing) return;

    try {
      state = AsrState.initializing;
      _stateController.add(state);

      final manager = OnDeviceAsrModelManager();
      await manager.initialize();

      final modelKey = await AsrSettings.getPreferredModel();
      final isInstalled = await manager.isInstalled(modelKey);

      if (!isInstalled) {
        state = AsrState.unavailable;
        _stateController.add(state);
        if (kDebugMode) print('SherpaOnnxAsrService: Model $modelKey not installed');
        return;
      }

      final modelEntry = manager.manifest.models.firstWhere((m) => m.key == modelKey);

      // Basic SenseVoice/Paraformer configuration (adjust based on actual manifest)
      // For SenseVoiceSmall as in manifest:
      final onnxMeta = modelEntry.files.firstWhere((f) => f.url.endsWith('.onnx'));
      final tokensMeta = modelEntry.files.firstWhere((f) => f.url.endsWith('tokens.txt'));

      final onnxPath = await manager.getLocalPath(modelKey, onnxMeta.url);
      final tokensPath = await manager.getLocalPath(modelKey, tokensMeta.url);

      if (onnxPath == null || tokensPath == null) {
        throw Exception('Model files missing despite isInstalled returning true');
      }

      final config = OfflineRecognizerConfig(
        model: OfflineModelConfig(
          senseVoice: OfflineSenseVoiceModelConfig(
            model: onnxPath,
            useInverseTextNormalization: true,
          ),
          tokens: tokensPath,
          numThreads: 1,
          debug: kDebugMode,
          provider: 'cpu',
        ),
      );

      _recognizer = OfflineRecognizer(config);
      state = AsrState.ready;
      _stateController.add(state);
      if (kDebugMode) print('SherpaOnnxAsrService: Initialized with $modelKey');
    } catch (e) {
      state = AsrState.error;
      _stateController.add(state);
      _errorController.add('ASR Init Error: $e');
      if (kDebugMode) print('SherpaOnnxAsrService Init Error: $e');
    }
  }

  @override
  Future<String> transcribe(Uint8List audioBytes) async {
    if (state != AsrState.ready) {
      await initialize();
      if (state != AsrState.ready) {
        throw Exception('ASR service not ready (State: $state)');
      }
    }

    try {
      state = AsrState.transcribing;
      _stateController.add(state);
      callbacks.onStart?.call();

      // SherpaOnnx expects 16kHz mono 16-bit PCM (float32 [-1, 1] for recognizer)
      // Conversion from AAC/other formats should happen before or here.
      // Assuming audioBytes is already Float32List for the sake of abstraction in this step,
      // or we handle conversion if we know the input format.
      // Usually, flutter_sound records to a file, then we read it.

      // WAV header is 44 bytes. Skip it if present.
      Uint8List pcmData = audioBytes;
      if (audioBytes.length > 44 &&
          audioBytes[0] == 0x52 && // R
          audioBytes[1] == 0x49 && // I
          audioBytes[2] == 0x46 && // F
          audioBytes[3] == 0x46) { // F
        pcmData = audioBytes.sublist(44);
      }

      // For now, assume we get PCM16 bytes and convert to Float32
      final float32Data = _pcm16ToFloat32(pcmData);

      final stream = _recognizer!.createStream();
      stream.acceptWaveform(samples: float32Data, sampleRate: 16000);
      _recognizer!.decode(stream);

      final result = _recognizer!.getResult(stream);
      final text = result.text;

      stream.free();

      state = AsrState.ready;
      _stateController.add(state);
      callbacks.onResult?.call(text);
      callbacks.onComplete?.call();

      return text;
    } catch (e) {
      state = AsrState.error;
      _stateController.add(state);
      callbacks.onError?.call(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    // SherpaOnnx offline recognizer doesn't really have an interruptable "stop"
    // like streaming, but we update state.
    if (state == AsrState.transcribing) {
      state = AsrState.ready;
      _stateController.add(state);
    }
  }

  @override
  void dispose() {
    _recognizer?.free();
    _stateController.close();
    _errorController.close();
  }

  Float32List _pcm16ToFloat32(Uint8List bytes) {
    final int16Data = bytes.buffer.asInt16List();
    final float32Data = Float32List(int16Data.length);
    for (var i = 0; i < int16Data.length; i++) {
      float32Data[i] = int16Data[i] / 32768.0;
    }
    return float32Data;
  }
}
