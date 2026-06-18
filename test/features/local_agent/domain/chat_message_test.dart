import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/local_agent/domain/chat_message.dart';

void main() {
  group('ChatMessage', () {
    final now = DateTime(2026, 6, 18, 1, 0, 0);

    test('constructor assigns all fields correctly', () {
      final message = ChatMessage(
        id: 1,
        role: ChatRole.user,
        content: 'What is my blood pressure?',
        timestamp: now,
        citations: ['MedicalCode:E11'],
      );

      expect(message.id, 1);
      expect(message.role, ChatRole.user);
      expect(message.content, 'What is my blood pressure?');
      expect(message.timestamp, now);
      expect(message.citations, ['MedicalCode:E11']);
    });

    test('constructor uses defaults for optional fields', () {
      final message = ChatMessage(
        role: ChatRole.assistant,
        content: 'Your blood pressure is normal.',
        timestamp: now,
      );

      expect(message.id, Isar.autoIncrement);
      expect(message.citations, []);
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = ChatMessage(
          id: 1,
          role: ChatRole.user,
          content: 'Hello',
          timestamp: now,
          citations: ['cite1'],
        );

        final modified = original.copyWith(
          content: 'Updated',
          citations: ['cite1', 'cite2'],
        );

        expect(modified.id, 1);
        expect(modified.role, ChatRole.user);
        expect(modified.content, 'Updated');
        expect(modified.timestamp, now);
        expect(modified.citations, ['cite1', 'cite2']);
      });

      test('copyWith retains original values when not overridden', () {
        final original = ChatMessage(
          id: 1,
          role: ChatRole.user,
          content: 'Hello',
          timestamp: now,
          citations: ['cite1'],
        );

        final copy = original.copyWith();

        expect(copy.id, 1);
        expect(copy.role, ChatRole.user);
        expect(copy.content, 'Hello');
        expect(copy.timestamp, now);
        expect(copy.citations, ['cite1']);
      });
    });
  });

  group('ChatRole', () {
    test('has user and assistant values', () {
      expect(ChatRole.values, contains(ChatRole.user));
      expect(ChatRole.values, contains(ChatRole.assistant));
      expect(ChatRole.values.length, 2);
    });
  });
}
