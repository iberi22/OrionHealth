import 'dart:async';
import 'dart:typed_data';
import 'asr_types.dart';

/// Abstract interface for local ASR services.
abstract class LocalAsrService {
  /// Current state of the ASR service.
  AsrState get state;

  /// Stream of state changes.
  Stream<AsrState> get stateStream;

  /// Stream of errors.
  Stream<String> get errorStream;

  /// Callbacks for transcription events.
  AsrCallbacks get callbacks;
  set callbacks(AsrCallbacks value);

  /// Initialize the ASR service and load models.
  Future<void> initialize();

  /// Transcribe audio bytes into text.
  Future<String> transcribe(Uint8List audioBytes);

  /// Stop any ongoing transcription.
  Future<void> stop();

  /// Release resources.
  void dispose();
}
