// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';
import 'voice_chat_message.dart';

class VoiceChatSession extends Equatable {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<VoiceChatMessage> messages;

  const VoiceChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    this.messages = const [],
  });

  @override
  List<Object?> get props => [id, title, createdAt, messages];

  VoiceChatSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    List<VoiceChatMessage>? messages,
  }) {
    return VoiceChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      messages: messages ?? this.messages,
    );
  }
}
