// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/voice_chat/domain/entities/voice_chat_message.dart';

void main() {
  group('VoiceChatMessage', () {
    final timestamp = DateTime(2025, 1, 1);

    test('should support value equality', () {
      final message1 = VoiceChatMessage(
        id: '1',
        role: MessageRole.user,
        content: 'Hello',
        timestamp: timestamp,
      );
      final message2 = VoiceChatMessage(
        id: '1',
        role: MessageRole.user,
        content: 'Hello',
        timestamp: timestamp,
      );

      expect(message1, equals(message2));
    });

    test('props should contain all fields', () {
      final message = VoiceChatMessage(
        id: '1',
        role: MessageRole.user,
        content: 'Hello',
        timestamp: timestamp,
      );

      expect(message.props, [
        '1',
        MessageRole.user,
        'Hello',
        timestamp,
      ]);
    });
  });
}
