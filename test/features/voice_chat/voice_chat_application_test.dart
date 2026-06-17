import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_state.dart';
import 'package:orionhealth_health/features/voice_chat/domain/entities/voice_chat_message.dart';

void main() {
  group('VoiceChatState', () {
    test('initial state is correct', () {
      const state = VoiceChatState();
      expect(state.status, VoiceChatStatus.initial);
      expect(state.messages, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.statusMessage, isNull);
      expect(state.currentAudioLevel, 0.0);
    });

    test('copyWith updates state', () {
      const state = VoiceChatState();
      final updated = state.copyWith(
        status: VoiceChatStatus.recording,
        statusMessage: 'Grabando...',
      );

      expect(updated.status, VoiceChatStatus.recording);
      expect(updated.statusMessage, 'Grabando...');
      expect(updated.messages, state.messages);
    });
  });
}
