// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/voice_chat_message.dart';
import '../../domain/repositories/voice_chat_repository.dart';
import '../datasources/chat_ai_datasource.dart';

@LazySingleton(as: VoiceChatRepository)
class VoiceChatRepositoryImpl implements VoiceChatRepository {
  final ChatAiDatasource _datasource;
  final _uuid = const Uuid();

  VoiceChatRepositoryImpl(this._datasource);

  @override
  Future<VoiceChatMessage> sendMessage(String text, {List<VoiceChatMessage>? history}) async {
    final contextStr = await _datasource.getContextForQuery(text);
    final context = contextStr.isNotEmpty ? [contextStr] : <String>[];

    final response = await _datasource.getAiResponse(text, context: context);

    await _datasource.saveToMemory(text, response);

    return VoiceChatMessage(
      id: _uuid.v4(),
      role: MessageRole.ai,
      content: response,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<List<VoiceChatMessage>> getChatHistory({int limit = 20}) async {
    final rawHistory = await _datasource.getRecentHistory(limit: limit);
    final List<VoiceChatMessage> messages = [];

    for (var i = 0; i + 1 < rawHistory.length; i += 2) {
      messages.add(VoiceChatMessage(
        id: _uuid.v4(),
        role: MessageRole.user,
        content: rawHistory[i],
        timestamp: DateTime.now().subtract(Duration(minutes: rawHistory.length - i)),
      ));
      messages.add(VoiceChatMessage(
        id: _uuid.v4(),
        role: MessageRole.ai,
        content: rawHistory[i + 1],
        timestamp: DateTime.now().subtract(Duration(minutes: rawHistory.length - i - 1)),
      ));
    }

    return messages;
  }

  @override
  Future<void> clearHistory() async {
    await _datasource.clearMemory();
  }

  @override
  Future<String> transcribeAudio(List<int> audioBytes) async {
    return await _datasource.transcribe(audioBytes);
  }
}
