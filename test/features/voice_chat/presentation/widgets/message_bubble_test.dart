// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/voice_chat/domain/entities/voice_chat_message.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/widgets/message_bubble.dart';

void main() {
  testWidgets('MessageBubble renders user message correctly', (tester) async {
    final message = VoiceChatMessage(
      id: '1',
      role: MessageRole.user,
      content: 'User message',
      timestamp: DateTime(2025, 1, 1, 10, 30),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(message: message),
        ),
      ),
    );

    expect(find.text('User message'), findsOneWidget);
    expect(find.text('10:30'), findsOneWidget);

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, equals(Colors.blue[700]));
  });

  testWidgets('MessageBubble renders AI message correctly', (tester) async {
    final message = VoiceChatMessage(
      id: '2',
      role: MessageRole.ai,
      content: 'AI message',
      timestamp: DateTime(2025, 1, 1, 10, 31),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(message: message),
        ),
      ),
    );

    expect(find.text('AI message'), findsOneWidget);
    expect(find.text('10:31'), findsOneWidget);

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, equals(Colors.grey[850]));
  });
}
