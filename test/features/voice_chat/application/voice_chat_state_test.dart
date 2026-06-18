// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_state.dart';
import 'package:orionhealth_health/features/voice_chat/domain/entities/voice_chat_message.dart';

void main() {
  group('VoiceChatState', () {
    test('initial state should have correct defaults', () {
      const state = VoiceChatState();
      expect(state.status, VoiceChatStatus.initial);
      expect(state.messages, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.statusMessage, isNull);
      expect(state.currentAudioLevel, 0.0);
    });

    test('copyWith should update fields correctly', () {
      const state = VoiceChatState();
      final messages = [
        VoiceChatMessage(
          id: '1',
          role: MessageRole.user,
          content: 'Hi',
          timestamp: DateTime.now(),
        ),
      ];

      final updated = state.copyWith(
        status: VoiceChatStatus.recording,
        messages: messages,
        errorMessage: 'Error',
        statusMessage: 'Status',
        currentAudioLevel: 0.5,
      );

      expect(updated.status, VoiceChatStatus.recording);
      expect(updated.messages, messages);
      expect(updated.errorMessage, 'Error');
      expect(updated.statusMessage, 'Status');
      expect(updated.currentAudioLevel, 0.5);
    });

    test('props should contain all fields', () {
      const state = VoiceChatState(
        status: VoiceChatStatus.initial,
        messages: [],
        errorMessage: 'Error',
        statusMessage: 'Status',
        currentAudioLevel: 0.5,
      );

      expect(state.props, [
        VoiceChatStatus.initial,
        [],
        'Error',
        'Status',
        0.5,
      ]);
    });
  });
}
