// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/voice_chat/domain/entities/voice_chat_message.dart';
import 'package:orionhealth_health/features/voice_chat/domain/repositories/voice_chat_repository.dart';

class MockVoiceChatRepository extends Mock implements VoiceChatRepository {}

void main() {
  group('VoiceChatRepository Interface', () {
    late MockVoiceChatRepository mockRepository;

    setUp(() {
      mockRepository = MockVoiceChatRepository();
    });

    final tMessage = VoiceChatMessage(
      id: '1',
      role: MessageRole.ai,
      content: 'Hello',
      timestamp: DateTime(2025),
    );

    test('can be mocked and called for sendMessage', () async {
      when(() => mockRepository.sendMessage(any(), history: any(named: 'history')))
          .thenAnswer((_) async => tMessage);

      final result = await mockRepository.sendMessage('Hi');

      expect(result, tMessage);
      verify(() => mockRepository.sendMessage('Hi')).called(1);
    });

    test('can be mocked and called for getChatHistory', () async {
      when(() => mockRepository.getChatHistory(limit: any(named: 'limit')))
          .thenAnswer((_) async => [tMessage]);

      final result = await mockRepository.getChatHistory(limit: 10);

      expect(result, [tMessage]);
      verify(() => mockRepository.getChatHistory(limit: 10)).called(1);
    });

    test('can be mocked and called for clearHistory', () async {
      when(() => mockRepository.clearHistory()).thenAnswer((_) async {});

      await mockRepository.clearHistory();

      verify(() => mockRepository.clearHistory()).called(1);
    });

    test('can be mocked and called for transcribeAudio', () async {
      const tTranscription = 'Transcribed text';
      when(() => mockRepository.transcribeAudio(any()))
          .thenAnswer((_) async => tTranscription);

      final result = await mockRepository.transcribeAudio([1, 2, 3]);

      expect(result, tTranscription);
      verify(() => mockRepository.transcribeAudio([1, 2, 3])).called(1);
    });
  });
}
