import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/voice_chat/state/voice_chat_state.dart';

void main() {
  group('VoiceChatState', () {
    late VoiceChatState state;

    setUp(() {
      state = VoiceChatState();
      state.reset();
    });

    test('starts with idle status and default message', () {
      expect(state.status, VoiceChatStatus.idle);
      expect(state.statusMessage, 'Listo para conversar');
      expect(state.isIdle, isTrue);
      expect(state.isRecording, isFalse);
      expect(state.isProcessing, isFalse);
      expect(state.isSpeaking, isFalse);
      expect(state.hasError, isFalse);
    });

    test('can start recording when idle', () {
      expect(state.canStartRecording, isTrue);
      expect(state.canStopRecording, isFalse);
      expect(state.canInterrupt, isFalse);
    });

    test('updateStatus changes status and message', () {
      state.updateStatus(VoiceChatStatus.recording, message: 'Grabando...');

      expect(state.status, VoiceChatStatus.recording);
      expect(state.isRecording, isTrue);
      expect(state.statusMessage, 'Grabando...');
      expect(state.canStartRecording, isFalse);
      expect(state.canStopRecording, isTrue);
    });

    test('updateStatus provides default message when none given', () {
      state.updateStatus(VoiceChatStatus.recording);
      expect(state.statusMessage, 'Grabando...');

      state.updateStatus(VoiceChatStatus.processing);
      expect(state.statusMessage, 'Procesando...');

      state.updateStatus(VoiceChatStatus.speaking);
      expect(state.statusMessage, 'Hablando...');

      state.updateStatus(VoiceChatStatus.completed);
      expect(state.statusMessage, 'Conversación completada');
    });

    test('updateTranscription stores value', () {
      state.updateTranscription('Hola mundo');
      expect(state.currentTranscription, 'Hola mundo');
    });

    test('updateAiResponse stores value', () {
      state.updateAiResponse('Hola, soy Orion');
      expect(state.currentAiResponse, 'Hola, soy Orion');
    });

    test('updateTranscription broadcasts on stream', () async {
      final futures = <String>[];
      state.transcriptionStream.listen((t) => futures.add(t));

      state.updateTranscription('Hola mundo');

      // Use a microtask delay to let the broadcast stream deliver
      await Future<void>.delayed(Duration.zero);
      expect(futures, contains('Hola mundo'));
    });

    test('updateAiResponse broadcasts on stream', () async {
      final futures = <String>[];
      state.responseStream.listen((r) => futures.add(r));

      state.updateAiResponse('Hola, soy Orion');

      await Future<void>.delayed(Duration.zero);
      expect(futures, contains('Hola, soy Orion'));
    });

    test('setError changes status and message', () {
      state.setError('Algo salió mal');

      expect(state.status, VoiceChatStatus.error);
      expect(state.hasError, isTrue);
      expect(state.errorMessage, 'Algo salió mal');
      expect(state.statusMessage, 'Error: Algo salió mal');
    });

    test('clearError resets to idle', () {
      state.setError('Error temporal');
      expect(state.hasError, isTrue);

      state.clearError();
      expect(state.status, VoiceChatStatus.idle);
      expect(state.errorMessage, isNull);
      expect(state.hasError, isFalse);
    });

    test('updateMemoryStatus stores values', () {
      expect(state.isMemoryAvailable, isFalse);
      expect(state.memoryCount, 0);

      state.updateMemoryStatus(true, 42);

      expect(state.isMemoryAvailable, isTrue);
      expect(state.memoryCount, 42);
    });

    test('addConversationTurn adds to history', () {
      expect(state.conversationHistory, isEmpty);

      state.addConversationTurn('Hola', 'Hola, soy Orion');

      expect(state.conversationHistory.length, 1);
      expect(state.conversationHistory.first.userInput, 'Hola');
      expect(state.conversationHistory.first.aiResponse, 'Hola, soy Orion');
    });

    test('clearHistory removes all turns', () {
      state.addConversationTurn('Hola', 'Respuesta');
      state.addConversationTurn('¿Cómo estás?', 'Bien');
      expect(state.conversationHistory.length, 2);

      state.clearHistory();
      expect(state.conversationHistory, isEmpty);
    });

    test('conversationHistory returns unmodifiable list', () {
      state.addConversationTurn('Hola', 'Respuesta');

      expect(
        () => state.conversationHistory.removeLast(),
        throwsUnsupportedError,
      );
    });

    test('reset returns to initial state', () {
      state.updateStatus(VoiceChatStatus.recording);
      state.updateTranscription('Algo');
      state.updateAiResponse('Respuesta');
      state.addConversationTurn('Algo', 'Respuesta');

      state.reset();

      expect(state.status, VoiceChatStatus.idle);
      expect(state.currentTranscription, '');
      expect(state.currentAiResponse, '');
      expect(state.conversationHistory, isEmpty);
      expect(state.errorMessage, isNull);
    });

    test('updateRecordingDuration stores duration', () {
      expect(state.recordingDuration, Duration.zero);

      state.updateRecordingDuration(const Duration(seconds: 30));

      expect(state.recordingDuration, const Duration(seconds: 30));
    });
  });

  group('ConversationTurn', () {
    test('creates with required fields', () {
      final now = DateTime(2026, 6, 15, 19, 0, 0);
      final turn = ConversationTurn(
        userInput: 'Hola',
        aiResponse: 'Respuesta',
        timestamp: now,
      );

      expect(turn.userInput, 'Hola');
      expect(turn.aiResponse, 'Respuesta');
      expect(turn.timestamp, now);
    });

    test('toString includes user and ai preview', () {
      final turn = ConversationTurn(
        userInput: 'Hello, how are you?',
        aiResponse: 'I am fine, thank you!',
        timestamp: DateTime(2026, 6, 15),
      );

      expect(turn.toString(), contains('Hello, how are you?'));
      expect(turn.toString(), contains('I am fine, thank you!'));
    });
  });

  group('VoiceChatStatus', () {
    test('has all expected values', () {
      expect(VoiceChatStatus.values, hasLength(6));
      expect(VoiceChatStatus.values, containsAll([
        VoiceChatStatus.idle,
        VoiceChatStatus.recording,
        VoiceChatStatus.processing,
        VoiceChatStatus.speaking,
        VoiceChatStatus.completed,
        VoiceChatStatus.error,
      ]));
    });
  });
}
