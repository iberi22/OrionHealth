// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/audio/audio_player_service.dart';
import '../domain/entities/voice_chat_message.dart';
import '../domain/usecases/get_chat_history_usecase.dart';
import '../domain/usecases/send_message_usecase.dart';
import '../domain/repositories/voice_chat_repository.dart';
import 'voice_chat_state.dart';

@injectable
class VoiceChatCubit extends Cubit<VoiceChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final GetChatHistoryUseCase _getChatHistoryUseCase;
  final VoiceChatRepository _repository;
  final AudioService _audioService;

  StreamSubscription? _volumeSubscription;
  StreamSubscription? _audioStateSubscription;

  VoiceChatCubit(
    this._sendMessageUseCase,
    this._getChatHistoryUseCase,
    this._repository,
    this._audioService,
  ) : super(const VoiceChatState());

  Future<void> init() async {
    emit(state.copyWith(status: VoiceChatStatus.loading));
    try {
      final history = await _getChatHistoryUseCase();

      _volumeSubscription = _audioService.currentVolumeStream.listen((vol) {
        emit(state.copyWith(currentAudioLevel: vol));
      });

      _audioStateSubscription = _audioService.stateStream.listen((audioState) {
        if (audioState == AudioState.speaking || audioState == AudioState.playing) {
          emit(state.copyWith(status: VoiceChatStatus.speaking, statusMessage: 'Respondiendo...'));
        } else if (audioState == AudioState.playbackCompleted || audioState == AudioState.playbackStopped || audioState == AudioState.ttsStopped) {
          emit(state.copyWith(status: VoiceChatStatus.initial, statusMessage: 'Listo para conversar'));
        }
      });

      emit(state.copyWith(
        status: VoiceChatStatus.initial,
        messages: history,
        statusMessage: 'Listo para conversar',
      ));
    } catch (e) {
      emit(state.copyWith(status: VoiceChatStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> startRecording() async {
    if (state.status == VoiceChatStatus.recording) return;

    emit(state.copyWith(status: VoiceChatStatus.recording, statusMessage: 'Grabando...'));
    await _audioService.startRecording();
  }

  Future<void> stopRecording() async {
    if (state.status != VoiceChatStatus.recording) return;

    emit(state.copyWith(status: VoiceChatStatus.processing, statusMessage: 'Transcribiendo audio...'));

    try {
      final audioBytes = await _audioService.stopRecording();
      if (audioBytes == null || audioBytes.isEmpty) {
        emit(state.copyWith(status: VoiceChatStatus.error, errorMessage: 'No se pudo capturar el audio'));
        return;
      }

      final transcription = await _repository.transcribeAudio(audioBytes);
      if (transcription.trim().isEmpty) {
        emit(state.copyWith(status: VoiceChatStatus.error, errorMessage: 'Transcripción vacía'));
        return;
      }

      await sendMessage(transcription);
    } catch (e) {
      emit(state.copyWith(status: VoiceChatStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = VoiceChatMessage(
      id: const Uuid().v4(),
      role: MessageRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(
      status: VoiceChatStatus.processing,
      statusMessage: 'Generando respuesta...',
      messages: [...state.messages, userMessage],
    ));

    try {
      final aiMessage = await _sendMessageUseCase(text, history: state.messages);

      emit(state.copyWith(
        messages: [...state.messages, aiMessage],
        status: VoiceChatStatus.speaking,
        statusMessage: 'Respondiendo...',
      ));

      await _audioService.speakText(aiMessage.content);
    } catch (e) {
      emit(state.copyWith(status: VoiceChatStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> clearHistory() async {
    await _repository.clearHistory();
    emit(state.copyWith(messages: [], statusMessage: 'Conversación limpiada'));
  }

  Future<void> interrupt() async {
    await _audioService.stopAll();
    emit(state.copyWith(status: VoiceChatStatus.initial, statusMessage: 'Interrumpido'));
  }

  @override
  Future<void> close() {
    _volumeSubscription?.cancel();
    _audioStateSubscription?.cancel();
    return super.close();
  }
}
