// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';

enum MessageRole { user, ai }

class VoiceChatMessage extends Equatable {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  const VoiceChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, role, content, timestamp];
}
