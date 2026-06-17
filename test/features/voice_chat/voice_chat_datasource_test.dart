// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/services/aicore_service.dart';
import 'package:orionhealth_health/core/services/asr/asr_service.dart';
import 'package:orionhealth_health/core/services/asr/asr_types.dart';
import 'package:orionhealth_health/features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart';

class MockAIService extends Mock implements AIService {}
class MockAsrService extends Mock implements AsrService {}
class MockAgentMemoryService extends Mock implements AgentMemoryService {}

void main() {
  late ChatAiDatasource datasource;
  late MockAIService mockAIService;
  late MockAsrService mockAsrService;
  late MockAgentMemoryService mockMemoryService;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockAIService = MockAIService();
    mockAsrService = MockAsrService();
    mockMemoryService = MockAgentMemoryService();
    datasource = ChatAiDatasource(mockAIService, mockAsrService, mockMemoryService);
  });

  group('ChatAiDatasource', () {
    test('getAiResponse should call AIService.getResponse', () async {
      const text = 'Hello';
      const context = ['Context'];
      when(() => mockAIService.getResponse(text, context: context))
          .thenAnswer((_) async => 'Hi');

      final result = await datasource.getAiResponse(text, context: context);

      expect(result, 'Hi');
      verify(() => mockAIService.getResponse(text, context: context)).called(1);
    });

    group('transcribe', () {
      final audioBytes = [1, 2, 3];
      final uint8AudioBytes = Uint8List.fromList(audioBytes);

      test('should use AIService fallback when AsrService is unavailable', () async {
        when(() => mockAsrService.currentState).thenReturn(AsrState.unavailable);
        when(() => mockAIService.transcribeAudio(audioBytes))
            .thenAnswer((_) async => 'Fallback transcription');

        final result = await datasource.transcribe(audioBytes);

        expect(result, 'Fallback transcription');
        verify(() => mockAIService.transcribeAudio(audioBytes)).called(1);
        verifyNever(() => mockAsrService.transcribe(any()));
      });

      test('should use AIService fallback when AsrService returns empty transcription', () async {
        when(() => mockAsrService.currentState).thenReturn(AsrState.ready);
        when(() => mockAsrService.transcribe(uint8AudioBytes))
            .thenAnswer((_) async => '  ');
        when(() => mockAIService.transcribeAudio(audioBytes))
            .thenAnswer((_) async => 'Fallback transcription');

        final result = await datasource.transcribe(audioBytes);

        expect(result, 'Fallback transcription');
        verify(() => mockAsrService.transcribe(uint8AudioBytes)).called(1);
        verify(() => mockAIService.transcribeAudio(audioBytes)).called(1);
      });

      test('should return transcription from AsrService when successful', () async {
        when(() => mockAsrService.currentState).thenReturn(AsrState.ready);
        when(() => mockAsrService.transcribe(uint8AudioBytes))
            .thenAnswer((_) async => 'Successful transcription');
        when(() => mockAIService.transcribeAudio(audioBytes))
            .thenAnswer((_) async => 'Fallback transcription');

        final result = await datasource.transcribe(audioBytes);

        expect(result, 'Successful transcription');
        verify(() => mockAsrService.transcribe(uint8AudioBytes)).called(1);
        verifyNever(() => mockAIService.transcribeAudio(any()));
      });

      test('should use AIService fallback on AsrService error', () async {
        when(() => mockAsrService.currentState).thenReturn(AsrState.ready);
        when(() => mockAsrService.transcribe(uint8AudioBytes))
            .thenThrow(Exception('ASR error'));
        when(() => mockAIService.transcribeAudio(audioBytes))
            .thenAnswer((_) async => 'Fallback transcription');

        final result = await datasource.transcribe(audioBytes);

        expect(result, 'Fallback transcription');
        verify(() => mockAIService.transcribeAudio(audioBytes)).called(1);
      });
    });

    group('Memory methods', () {
      test('getContextForQuery should call memory service', () async {
        when(() => mockMemoryService.getContextForQuery('test'))
            .thenAnswer((_) async => 'context');

        final result = await datasource.getContextForQuery('test');

        expect(result, 'context');
        verify(() => mockMemoryService.getContextForQuery('test')).called(1);
      });

      test('saveToMemory should call memory service', () async {
        when(() => mockMemoryService.addMemory(input: 'in', output: 'out'))
            .thenAnswer((_) async => {});

        await datasource.saveToMemory('in', 'out');

        verify(() => mockMemoryService.addMemory(input: 'in', output: 'out')).called(1);
      });

      test('getRecentHistory should call memory service', () async {
        when(() => mockMemoryService.getRecentHistory(limit: 10))
            .thenAnswer((_) async => ['h1', 'h2']);

        final result = await datasource.getRecentHistory(limit: 10);

        expect(result, ['h1', 'h2']);
        verify(() => mockMemoryService.getRecentHistory(limit: 10)).called(1);
      });

      test('clearMemory should be callable', () async {
        await datasource.clearMemory();
        // Currently a stub, but we verify it can be called without error
      });
    });
  });
}
