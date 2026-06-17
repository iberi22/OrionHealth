// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../entities/voice_chat_message.dart';
import '../repositories/voice_chat_repository.dart';

@injectable
class SendMessageUseCase {
  final VoiceChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<VoiceChatMessage> call(String text, {List<VoiceChatMessage>? history}) {
    return repository.sendMessage(text, history: history);
  }
}
