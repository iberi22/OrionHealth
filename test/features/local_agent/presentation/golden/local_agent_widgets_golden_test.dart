import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/widgets/voice_input_button.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_cubit.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_state.dart';
import '../../../../core/golden_test_utils.dart';

class MockLlmService extends Mock implements LlmService {}
class MockVoiceChatCubit extends Mock implements VoiceChatCubit {}

void main() {
  late MockLlmService mockLlmService;
  late MockVoiceChatCubit mockVoiceChatCubit;

  setUp(() async {
    mockLlmService = MockLlmService();
    mockVoiceChatCubit = MockVoiceChatCubit();

    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerLazySingleton<LlmService>(() => mockLlmService);
  });

  group('Local Agent Widget Golden Tests', () {
    testWidgets('MessageBubble - User', (tester) async {
      setupGoldenTest(tester);
      tester.view.physicalSize = const Size(360, 400);

      await tester.pumpWidget(wrapWithMaterial(ChatPage(llmService: mockLlmService)));
      await tester.pumpAndSettle();

      // Type a message to get a user bubble
      await tester.enterText(find.byType(TextField), 'Test message');
      when(() => mockLlmService.generate(any())).thenAnswer((_) => Stream.fromIterable(['Response']));
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      final userBubbleFinder = find.byWidgetPredicate((widget) {
        if (widget is Align && widget.alignment == Alignment.centerRight) {
          return true;
        }
        return false;
      }).last;

      await expectLater(
        userBubbleFinder,
        matchesGoldenFile("../../../../../golden/reference/message_bubble_user.png"),
      );

      resetGoldenTest(tester);
    });

    testWidgets('MessageBubble - AI', (tester) async {
      setupGoldenTest(tester);
      tester.view.physicalSize = const Size(360, 400);

      await tester.pumpWidget(wrapWithMaterial(ChatPage(llmService: mockLlmService)));
      await tester.pumpAndSettle();

      final aiBubbleFinder = find.byWidgetPredicate((widget) {
        if (widget is Align && widget.alignment == Alignment.centerLeft) {
          return true;
        }
        return false;
      }).first;

      await expectLater(
        aiBubbleFinder,
        matchesGoldenFile("../../../../../golden/reference/message_bubble_ai.png"),
      );

      resetGoldenTest(tester);
    });

    testWidgets('VoiceInputButton', (tester) async {
      setupGoldenTest(tester);
      tester.view.physicalSize = const Size(200, 250);

      when(() => mockVoiceChatCubit.state).thenReturn(const VoiceChatState(status: VoiceChatStatus.initial));
      when(() => mockVoiceChatCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Center(
              child: BlocProvider<VoiceChatCubit>.value(
                value: mockVoiceChatCubit,
                child: const VoiceInputButton(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(VoiceInputButton),
        matchesGoldenFile("../../../../../golden/reference/voice_input_button.png"),
      );

      resetGoldenTest(tester);
    });
  });
}
