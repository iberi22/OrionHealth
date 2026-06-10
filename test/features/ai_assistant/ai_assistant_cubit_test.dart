import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/ai_assistant/application/ai_assistant_cubit.dart';
import 'package:orionhealth_health/features/ai_assistant/application/ai_assistant_state.dart';
import 'package:orionhealth_health/features/ai_assistant/domain/entities/ai_query.dart';
import 'package:orionhealth_health/features/ai_assistant/domain/repositories/ai_repository.dart';
import 'package:orionhealth_health/features/local_agent/domain/chat_message.dart';

class MockAiRepository extends Mock implements AiRepository {}

void main() {
  late AiAssistantCubit cubit;
  late MockAiRepository mockRepository;

  setUp(() {
    registerFallbackValue(const AiQuery(text: ''));
    mockRepository = MockAiRepository();
    cubit = AiAssistantCubit(mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('AiAssistantCubit', () {
    test('initial state is correct', () {
      expect(cubit.state.status, AiAssistantStatus.initial);
      expect(cubit.state.messages.length, 1);
      expect(cubit.state.messages.first.role, ChatRole.assistant);
    });

    test('sendMessage updates state with user message and placeholder', () async {
      when(() => mockRepository.askQuestion(any()))
          .thenAnswer((_) => Stream.fromIterable(['Hello', ' world']));

      await cubit.sendMessage('Hi');

      expect(cubit.state.messages.length, 3);
      expect(cubit.state.messages[1].role, ChatRole.user);
      expect(cubit.state.messages[1].content, 'Hi');
      expect(cubit.state.messages[2].role, ChatRole.assistant);
    });

    test('emits thinking and then responding status', () async {
      final controller = StreamController<String>();
      when(() => mockRepository.askQuestion(any()))
          .thenAnswer((_) => controller.stream);

      final states = <AiAssistantStatus>[];
      final subscription = cubit.stream.listen((state) => states.add(state.status));

      await cubit.sendMessage('Hi');
      expect(states.last, AiAssistantStatus.thinking);

      controller.add('Chunk');
      await Future.delayed(Duration.zero);
      expect(states.last, AiAssistantStatus.responding);

      controller.close();
      await Future.delayed(Duration.zero);
      expect(states.last, AiAssistantStatus.initial);

      subscription.cancel();
    });

    test('handles error from repository', () async {
      when(() => mockRepository.askQuestion(any()))
          .thenAnswer((_) => Stream.error('Something went wrong'));

      await cubit.sendMessage('Hi');
      await Future.delayed(Duration.zero);

      expect(cubit.state.status, AiAssistantStatus.error);
      expect(cubit.state.error, 'Something went wrong');
      expect(cubit.state.messages.last.content, 'Error: Something went wrong');
    });
  });
}
