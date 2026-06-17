// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';
import '../domain/entities/voice_chat_message.dart';

enum VoiceChatStatus { initial, loading, recording, processing, speaking, error }

class VoiceChatState extends Equatable {
  final VoiceChatStatus status;
  final List<VoiceChatMessage> messages;
  final String? errorMessage;
  final String? statusMessage;
  final double currentAudioLevel;

  const VoiceChatState({
    this.status = VoiceChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.statusMessage,
    this.currentAudioLevel = 0.0,
  });

  VoiceChatState copyWith({
    VoiceChatStatus? status,
    List<VoiceChatMessage>? messages,
    String? errorMessage,
    String? statusMessage,
    double? currentAudioLevel,
  }) {
    return VoiceChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      statusMessage: statusMessage ?? this.statusMessage,
      currentAudioLevel: currentAudioLevel ?? this.currentAudioLevel,
    );
  }

  @override
  List<Object?> get props => [status, messages, errorMessage, statusMessage, currentAudioLevel];
}
