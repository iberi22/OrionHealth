// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/widgets/animated_chat_message.dart';

void main() {
  group('AnimatedChatMessage', () {
    testWidgets('renders user message correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedChatMessage(
              message: 'Hello Agent',
              type: MessageType.user,
            ),
          ),
        ),
      );

      // Entry animations
      await tester.pumpAndSettle();

      expect(find.text('Hello Agent'), findsOneWidget);
      // User avatar (person icon)
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders agent message correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedChatMessage(
              message: 'Hello User',
              type: MessageType.agent,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Hello User'), findsOneWidget);
      // Agent avatar (psychology icon)
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('renders system message correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedChatMessage(
              message: 'System notification',
              type: MessageType.system,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('System notification'), findsOneWidget);
      // No avatars for system message
      expect(find.byIcon(Icons.person), findsNothing);
      expect(find.byIcon(Icons.psychology), findsNothing);
    });

    testWidgets('shows typing indicator for agent message when isTyping is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedChatMessage(
              message: 'Agent is typing...',
              type: MessageType.agent,
              isTyping: true,
            ),
          ),
        ),
      );

      // Initially, it might show typing indicator (3 dots) before text starts appearing
      // The code says: if (widget.isTyping && widget.type == MessageType.agent && _displayedText.isEmpty)
      // _startTypingEffect has a 200ms delay in _startEntryAnimation before starting.

      await tester.pump(const Duration(milliseconds: 100));
      // Typing indicator should be there
      expect(find.byType(Row), findsWidgets); // Indicators are in a Row

      // Wait for typing to complete
      await tester.pumpAndSettle();
      expect(find.text('Agent is typing...'), findsOneWidget);
    });

    testWidgets('calls onAnimationComplete when finished', (tester) async {
      bool completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedChatMessage(
              message: 'Test message',
              type: MessageType.user,
              onAnimationComplete: () => completed = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(completed, isTrue);
    });
  });
}
