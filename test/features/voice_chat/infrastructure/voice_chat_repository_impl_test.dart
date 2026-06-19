// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/voice_chat/domain/entities/voice_chat_message.dart';
import 'package:orionhealth_health/features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart';
import 'package:orionhealth_health/features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart';

class MockChatAiDatasource extends Mock implements ChatAiDatasource {}

void main() {
  late VoiceChatRepositoryImpl repository;
  late MockChatAiDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockChatAiDatasource();
    repository = VoiceChatRepositoryImpl(mockDatasource);
  });

  group('VoiceChatRepositoryImpl', () {
    test('sendMessage should fetch context, get AI response, and save to memory', () async {
      const text = 'Hello';
      const context = 'User context';
      const response = 'Hi there';

      when(() => mockDatasource.getContextForQuery(text))
          .thenAnswer((_) async => context);
      when(() => mockDatasource.getAiResponse(text, context: [context]))
          .thenAnswer((_) async => response);
      when(() => mockDatasource.saveToMemory(text, response))
          .thenAnswer((_) async => {});

      final result = await repository.sendMessage(text);

      expect(result.content, response);
      expect(result.role, MessageRole.ai);
      verify(() => mockDatasource.getContextForQuery(text)).called(1);
      verify(() => mockDatasource.getAiResponse(text, context: [context])).called(1);
      verify(() => mockDatasource.saveToMemory(text, response)).called(1);
    });

    test('sendMessage should handle empty context', () async {
      const text = 'Hello';
      const response = 'Hi there';

      when(() => mockDatasource.getContextForQuery(text))
          .thenAnswer((_) async => '');
      when(() => mockDatasource.getAiResponse(text, context: []))
          .thenAnswer((_) async => response);
      when(() => mockDatasource.saveToMemory(text, response))
          .thenAnswer((_) async => {});

      final result = await repository.sendMessage(text);

      expect(result.content, response);
      verify(() => mockDatasource.getAiResponse(text, context: [])).called(1);
    });

    test('getChatHistory should parse history correctly', () async {
      final rawHistory = ['Hello', 'Hi', 'How are you?', 'I am fine'];
      when(() => mockDatasource.getRecentHistory(limit: any(named: 'limit')))
          .thenAnswer((_) async => rawHistory);

      final result = await repository.getChatHistory(limit: 20);

      expect(result.length, 4);
      expect(result[0].content, 'Hello');
      expect(result[0].role, MessageRole.user);
      expect(result[1].content, 'Hi');
      expect(result[1].role, MessageRole.ai);
      expect(result[2].content, 'How are you?');
      expect(result[2].role, MessageRole.user);
      expect(result[3].content, 'I am fine');
      expect(result[3].role, MessageRole.ai);
    });

    test('clearHistory should call datasource clearMemory', () async {
      when(() => mockDatasource.clearMemory()).thenAnswer((_) async => {});

      await repository.clearHistory();

      verify(() => mockDatasource.clearMemory()).called(1);
    });

    test('transcribeAudio should call datasource transcribe', () async {
      final audioBytes = [1, 2, 3];
      const transcription = 'Test transcription';
      when(() => mockDatasource.transcribe(audioBytes))
          .thenAnswer((_) async => transcription);

      final result = await repository.transcribeAudio(audioBytes);

      expect(result, transcription);
      verify(() => mockDatasource.transcribe(audioBytes)).called(1);
    });
  });
}
