// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../entities/voice_chat_message.dart';
import '../repositories/voice_chat_repository.dart';

@injectable
class GetChatHistoryUseCase {
  final VoiceChatRepository repository;

  GetChatHistoryUseCase(this.repository);

  Future<List<VoiceChatMessage>> call({int limit = 20}) {
    return repository.getChatHistory(limit: limit);
  }
}
