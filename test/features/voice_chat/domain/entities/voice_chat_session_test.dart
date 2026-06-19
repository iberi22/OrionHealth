// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/voice_chat/domain/entities/voice_chat_message.dart';
import 'package:orionhealth_health/features/voice_chat/domain/entities/voice_chat_session.dart';

void main() {
  group('VoiceChatSession', () {
    final createdAt = DateTime(2025, 1, 1);
    final messages = [
      VoiceChatMessage(
        id: '1',
        role: MessageRole.user,
        content: 'Hello',
        timestamp: createdAt,
      ),
    ];

    test('should support value equality', () {
      final session1 = VoiceChatSession(
        id: '1',
        title: 'Session 1',
        createdAt: createdAt,
        messages: messages,
      );
      final session2 = VoiceChatSession(
        id: '1',
        title: 'Session 1',
        createdAt: createdAt,
        messages: messages,
      );

      expect(session1, equals(session2));
    });

    test('copyWith should update fields correctly', () {
      final session = VoiceChatSession(
        id: '1',
        title: 'Session 1',
        createdAt: createdAt,
        messages: messages,
      );

      final updatedSession = session.copyWith(
        title: 'Updated Title',
        messages: [],
      );

      expect(updatedSession.id, '1');
      expect(updatedSession.title, 'Updated Title');
      expect(updatedSession.createdAt, createdAt);
      expect(updatedSession.messages, isEmpty);
    });

    test('props should contain all fields', () {
      final session = VoiceChatSession(
        id: '1',
        title: 'Session 1',
        createdAt: createdAt,
        messages: messages,
      );

      expect(session.props, [
        '1',
        'Session 1',
        createdAt,
        messages,
      ]);
    });
  });
}
