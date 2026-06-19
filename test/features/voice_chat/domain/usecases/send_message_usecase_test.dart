// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/voice_chat/domain/entities/voice_chat_message.dart';
import 'package:orionhealth_health/features/voice_chat/domain/repositories/voice_chat_repository.dart';
import 'package:orionhealth_health/features/voice_chat/domain/usecases/send_message_usecase.dart';

class MockVoiceChatRepository extends Mock implements VoiceChatRepository {}

void main() {
  late SendMessageUseCase useCase;
  late MockVoiceChatRepository mockRepository;

  setUp(() {
    mockRepository = MockVoiceChatRepository();
    useCase = SendMessageUseCase(mockRepository);
  });

  test('should send message via repository', () async {
    const text = 'Hello';
    final response = VoiceChatMessage(
      id: '2',
      role: MessageRole.ai,
      content: 'Hi',
      timestamp: DateTime.now(),
    );
    when(() => mockRepository.sendMessage(text, history: any(named: 'history')))
        .thenAnswer((_) async => response);

    final result = await useCase(text);

    expect(result, response);
    verify(() => mockRepository.sendMessage(text)).called(1);
  });
}
