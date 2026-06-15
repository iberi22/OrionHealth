/// Shared ASR types and states
enum AsrState {
  uninitialized,
  initializing,
  ready,
  transcribing,
  stopped,
  error,
  unavailable, // When model is missing
}

/// Model types for SherpaOnnx ASR
enum AsrModelType {
  whisper,
  senseVoice,
  paraformer,
  zipformer,
}

/// ASR callbacks for event handling
class AsrCallbacks {
  final void Function()? onStart;
  final void Function(String text)? onResult;
  final void Function()? onComplete;
  final void Function(String error)? onError;

  const AsrCallbacks({
    this.onStart,
    this.onResult,
    this.onComplete,
    this.onError,
  });
}
