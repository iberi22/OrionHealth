// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/services/audio/audio_player_service.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_cubit.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_state.dart';
import 'package:orionhealth_health/features/voice_chat/domain/entities/voice_chat_message.dart';
import 'package:orionhealth_health/features/voice_chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:orionhealth_health/features/voice_chat/domain/usecases/send_message_usecase.dart';
import 'package:orionhealth_health/features/voice_chat/domain/repositories/voice_chat_repository.dart';

class MockSendMessageUseCase extends Mock implements SendMessageUseCase {}
class MockGetChatHistoryUseCase extends Mock implements GetChatHistoryUseCase {}
class MockVoiceChatRepository extends Mock implements VoiceChatRepository {}
class MockAudioService extends Mock implements AudioService {}

void main() {
  late VoiceChatCubit cubit;
  late MockSendMessageUseCase mockSendMessageUseCase;
  late MockGetChatHistoryUseCase mockGetChatHistoryUseCase;
  late MockVoiceChatRepository mockRepository;
  late MockAudioService mockAudioService;

  late StreamController<double> volumeController;
  late StreamController<AudioState> audioStateController;

  setUpAll(() {
    registerFallbackValue(const VoiceChatState());
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(<VoiceChatMessage>[]);
  });

  setUp(() {
    mockSendMessageUseCase = MockSendMessageUseCase();
    mockGetChatHistoryUseCase = MockGetChatHistoryUseCase();
    mockRepository = MockVoiceChatRepository();
    mockAudioService = MockAudioService();

    volumeController = StreamController<double>.broadcast();
    audioStateController = StreamController<AudioState>.broadcast();

    when(() => mockAudioService.currentVolumeStream).thenAnswer((_) => volumeController.stream);
    when(() => mockAudioService.stateStream).thenAnswer((_) => audioStateController.stream);
    when(() => mockGetChatHistoryUseCase()).thenAnswer((_) async => []);

    cubit = VoiceChatCubit(
      mockSendMessageUseCase,
      mockGetChatHistoryUseCase,
      mockRepository,
      mockAudioService,
    );
  });

  tearDown(() {
    cubit.close();
    volumeController.close();
    audioStateController.close();
  });

  group('VoiceChatState', () {
    test('initial state is correct', () {
      const state = VoiceChatState();
      expect(state.status, VoiceChatStatus.initial);
      expect(state.messages, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.statusMessage, isNull);
      expect(state.currentAudioLevel, 0.0);
    });

    test('copyWith updates state', () {
      const state = VoiceChatState();
      final updated = state.copyWith(
        status: VoiceChatStatus.recording,
        statusMessage: 'Grabando...',
      );

      expect(updated.status, VoiceChatStatus.recording);
      expect(updated.statusMessage, 'Grabando...');
      expect(updated.messages, state.messages);
    });
  });

  group('VoiceChatCubit', () {
    test('init should load history and subscribe to audio streams', () async {
      final history = [
        VoiceChatMessage(id: '1', role: MessageRole.user, content: 'Hi', timestamp: DateTime.now()),
      ];
      when(() => mockGetChatHistoryUseCase()).thenAnswer((_) async => history);

      await cubit.init();

      expect(cubit.state.status, VoiceChatStatus.initial);
      expect(cubit.state.messages, history);
      expect(cubit.state.statusMessage, 'Listo para conversar');

      volumeController.add(0.5);
      await Future.delayed(Duration.zero);
      expect(cubit.state.currentAudioLevel, 0.5);

      audioStateController.add(AudioState.speaking);
      await Future.delayed(Duration.zero);
      expect(cubit.state.status, VoiceChatStatus.speaking);
      expect(cubit.state.statusMessage, 'Respondiendo...');
    });

    test('startRecording should update status and call audio service', () async {
      when(() => mockAudioService.startRecording()).thenAnswer((_) async => {});

      await cubit.startRecording();

      expect(cubit.state.status, VoiceChatStatus.recording);
      expect(cubit.state.statusMessage, 'Grabando...');
      verify(() => mockAudioService.startRecording()).called(1);
    });

    test('stopRecording should transcribe and send message', () async {
      final audioBytes = Uint8List.fromList([1, 2, 3]);
      when(() => mockAudioService.startRecording()).thenAnswer((_) async => {});
      when(() => mockAudioService.stopRecording()).thenAnswer((_) async => audioBytes);
      when(() => mockRepository.transcribeAudio(any())).thenAnswer((_) async => 'Test');
      when(() => mockSendMessageUseCase(any(), history: any(named: 'history')))
          .thenAnswer((_) async => VoiceChatMessage(
                id: '2',
                role: MessageRole.ai,
                content: 'Response',
                timestamp: DateTime.now(),
              ));
      when(() => mockAudioService.speakText(any())).thenAnswer((_) async => {});

      // Set state to recording first
      await cubit.startRecording();

      await cubit.stopRecording();

      expect(cubit.state.messages.any((m) => m.content == 'Test'), true);
      expect(cubit.state.messages.any((m) => m.content == 'Response'), true);
      verify(() => mockRepository.transcribeAudio(any())).called(1);
      verify(() => mockAudioService.speakText('Response')).called(1);
    });

    test('sendMessage should handle empty text', () async {
      await cubit.sendMessage('  ');
      expect(cubit.state.messages, isEmpty);
      verifyNever(() => mockSendMessageUseCase(any(), history: any(named: 'history')));
    });

    test('sendMessage should handle errors', () async {
      when(() => mockSendMessageUseCase(any(), history: any(named: 'history')))
          .thenThrow(Exception('Network error'));

      await cubit.sendMessage('Hello');

      expect(cubit.state.status, VoiceChatStatus.error);
      expect(cubit.state.errorMessage, contains('Network error'));
    });

    test('clearHistory should clear repository and state', () async {
      when(() => mockRepository.clearHistory()).thenAnswer((_) async => {});

      await cubit.clearHistory();

      expect(cubit.state.messages, isEmpty);
      expect(cubit.state.statusMessage, 'Conversación limpiada');
      verify(() => mockRepository.clearHistory()).called(1);
    });

    test('interrupt should stop audio and update state', () async {
      when(() => mockAudioService.stopAll()).thenAnswer((_) async => {});

      await cubit.interrupt();

      expect(cubit.state.status, VoiceChatStatus.initial);
      expect(cubit.state.statusMessage, 'Interrumpido');
      verify(() => mockAudioService.stopAll()).called(1);
    });
  });
}
