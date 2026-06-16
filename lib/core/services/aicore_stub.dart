// Stub: AIService - minimal implementation for compilation
// TODO: Replace with real implementation

import 'dart:async';

enum AIServiceState { loading, ready, error }

class AIService {
  AIServiceState _state = AIServiceState.loading;
  AIServiceState get currentState => _state;
  Stream<AIServiceState> get stateStream => _stateController.stream;
  final StreamController<AIServiceState> _stateController =
      StreamController<AIServiceState>.broadcast();

  Future<void> initialize() async {
    _state = AIServiceState.ready;
    _stateController.add(_state);
  }

  Future<String> getResponse(String input, {List<String>? context}) async {
    return 'Respuesta simulada de IA';
  }

  Future<String> transcribeAudio(List<int> audioBytes) async {
    return 'Transcripción simulada';
  }

  void dispose() {
    _stateController.close();
  }
}
