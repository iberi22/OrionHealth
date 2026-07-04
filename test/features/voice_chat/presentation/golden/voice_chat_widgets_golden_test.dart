import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/widgets/message_bubble.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/widgets/voice_input_button.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_cubit.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_state.dart';
import 'package:orionhealth_health/core/services/aicore_service.dart';
import 'package:orionhealth_health/features/voice_chat/domain/entities/voice_chat_message.dart';
import '../../../../core/golden_test_utils.dart';

class MockVoiceChatCubit extends Mock implements VoiceChatCubit {}
class MockAIService extends Mock implements AIService {}

void main() {
  late MockVoiceChatCubit mockCubit;
  late MockAIService mockAIService;

  setUpAll(() {
    registerFallbackValue(const VoiceChatState());
  });

  setUp(() async {
    mockCubit = MockVoiceChatCubit();
    mockAIService = MockAIService();
    final getIt = GetIt.I;
    if (getIt.isRegistered<VoiceChatCubit>()) {
      await getIt.unregister<VoiceChatCubit>();
    }
    if (getIt.isRegistered<AIService>()) {
      await getIt.unregister<AIService>();
    }
    getIt.registerSingleton<VoiceChatCubit>(mockCubit);
    getIt.registerSingleton<AIService>(mockAIService);

    when(() => mockCubit.state).thenReturn(const VoiceChatState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.init()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockAIService.currentState).thenReturn(AIServiceState.ready);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Voice Chat Widgets Golden Tests', () {
    testWidgets('MessageBubble - User', (tester) async {
      setupGoldenTest(tester);
      final message = VoiceChatMessage(
        id: '1',
        content: 'Hola Orion',
        role: MessageRole.user,
        timestamp: DateTime(2025, 1, 1),
      );

      await tester.pumpWidget(wrapWithMaterial(Scaffold(body: Center(child: MessageBubble(message: message)))));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MessageBubble),
        matchesGoldenFile("goldens/message_bubble_user.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('MessageBubble - AI', (tester) async {
      setupGoldenTest(tester);
      final message = VoiceChatMessage(
        id: '2',
        content: 'Hola, ¿en qué puedo ayudarte hoy?',
        role: MessageRole.ai,
        timestamp: DateTime(2025, 1, 1),
      );

      await tester.pumpWidget(wrapWithMaterial(Scaffold(body: Center(child: MessageBubble(message: message)))));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MessageBubble),
        matchesGoldenFile("goldens/message_bubble_ai.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('VoiceInputButton', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const VoiceChatState(status: VoiceChatStatus.initial));

      await tester.pumpWidget(wrapWithMaterial(Scaffold(
        body: Center(
          child: BlocProvider<VoiceChatCubit>.value(
            value: mockCubit,
            child: const VoiceInputButton(),
          ),
        ),
      )));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(VoiceInputButton),
        matchesGoldenFile("goldens/voice_input_button.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
