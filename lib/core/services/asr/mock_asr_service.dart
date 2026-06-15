import 'dart:async';
import 'dart:typed_data';
import 'package:orion/services/asr/asr_types.dart';
import 'package:orion/services/asr/local_asr_service.dart';

/// Mock ASR service for testing and fallback.
class MockAsrService implements LocalAsrService {
  @override
  AsrState state = AsrState.ready;

  @override
  AsrCallbacks callbacks = const AsrCallbacks();

  final _stateController = StreamController<AsrState>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  @override
  Stream<AsrState> get stateStream => _stateController.stream;
  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  Future<void> initialize() async {
    state = AsrState.ready;
    _stateController.add(state);
  }

  @override
  Future<String> transcribe(Uint8List audioBytes) async {
    state = AsrState.transcribing;
    _stateController.add(state);
    callbacks.onStart?.call();

    await Future.delayed(const Duration(seconds: 1));

    const result = 'Hola, esta es una transcripción simulada.';

    state = AsrState.ready;
    _stateController.add(state);
    callbacks.onResult?.call(result);
    callbacks.onComplete?.call();

    return result;
  }

  @override
  Future<void> stop() async {
    state = AsrState.ready;
    _stateController.add(state);
  }

  @override
  void dispose() {
    _stateController.close();
    _errorController.close();
  }
}
