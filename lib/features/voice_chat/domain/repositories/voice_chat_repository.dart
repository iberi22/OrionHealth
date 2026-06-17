// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import '../entities/voice_chat_message.dart';

abstract class VoiceChatRepository {
  Future<VoiceChatMessage> sendMessage(String text, {List<VoiceChatMessage>? history});
  Future<List<VoiceChatMessage>> getChatHistory({int limit = 20});
  Future<void> clearHistory();
  Future<String> transcribeAudio(List<int> audioBytes);
}
