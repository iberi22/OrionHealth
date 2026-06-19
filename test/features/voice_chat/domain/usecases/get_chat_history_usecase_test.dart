// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/voice_chat/domain/entities/voice_chat_message.dart';
import 'package:orionhealth_health/features/voice_chat/domain/repositories/voice_chat_repository.dart';
import 'package:orionhealth_health/features/voice_chat/domain/usecases/get_chat_history_usecase.dart';

class MockVoiceChatRepository extends Mock implements VoiceChatRepository {}

void main() {
  late GetChatHistoryUseCase useCase;
  late MockVoiceChatRepository mockRepository;

  setUp(() {
    mockRepository = MockVoiceChatRepository();
    useCase = GetChatHistoryUseCase(mockRepository);
  });

  test('should get chat history from repository', () async {
    final history = [
      VoiceChatMessage(
        id: '1',
        role: MessageRole.user,
        content: 'Hi',
        timestamp: DateTime.now(),
      ),
    ];
    when(() => mockRepository.getChatHistory(limit: any(named: 'limit')))
        .thenAnswer((_) async => history);

    final result = await useCase(limit: 10);

    expect(result, history);
    verify(() => mockRepository.getChatHistory(limit: 10)).called(1);
  });
}
