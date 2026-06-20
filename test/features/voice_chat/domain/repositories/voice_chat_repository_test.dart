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

    test('can be mocked and called for all methods', () async {
      final tMessage = VoiceChatMessage(
        id: '1',
        role: MessageRole.ai,
        content: 'Response',
        timestamp: DateTime.now(),
      );
      final tHistory = [
        VoiceChatMessage(
          id: '0',
          role: MessageRole.user,
          content: 'Hello',
          timestamp: DateTime.now(),
        ),
      ];
      const tAudioBytes = [1, 2, 3];
      const tTranscription = 'Transcription';

      when(() => mockRepository.sendMessage(any(), history: any(named: 'history')))
          .thenAnswer((_) async => tMessage);
      when(() => mockRepository.getChatHistory(limit: any(named: 'limit')))
          .thenAnswer((_) async => tHistory);
      when(() => mockRepository.clearHistory()).thenAnswer((_) async {});
      when(() => mockRepository.transcribeAudio(any()))
          .thenAnswer((_) async => tTranscription);

      final message = await mockRepository.sendMessage('Hello', history: tHistory);
      final history = await mockRepository.getChatHistory(limit: 10);
      await mockRepository.clearHistory();
      final transcription = await mockRepository.transcribeAudio(tAudioBytes);

      expect(message, tMessage);
      expect(history, tHistory);
      expect(transcription, tTranscription);

      verify(() => mockRepository.sendMessage('Hello', history: tHistory)).called(1);
      verify(() => mockRepository.getChatHistory(limit: 10)).called(1);
      verify(() => mockRepository.clearHistory()).called(1);
      verify(() => mockRepository.transcribeAudio(tAudioBytes)).called(1);
    });
  });
}
