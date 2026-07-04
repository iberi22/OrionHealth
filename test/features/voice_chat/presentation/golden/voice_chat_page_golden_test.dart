import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/pages/voice_chat_page.dart';
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
    when(() => mockCubit.clearHistory()).thenAnswer((_) async {});
    when(() => mockAIService.currentState).thenReturn(AIServiceState.ready);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('VoiceChatPage Golden Tests', () {
    testWidgets('VoiceChatPage - Initial State with Messages', (tester) async {
      setupGoldenTest(tester);

      final messages = [
        VoiceChatMessage(
          id: '1',
          content: 'Hola Orion, ¿cómo estás?',
          role: MessageRole.user,
          timestamp: DateTime(2025, 1, 1, 10, 0),
        ),
        VoiceChatMessage(
          id: '2',
          content: 'Hola, estoy listo para ayudarte con tu salud.',
          role: MessageRole.ai,
          timestamp: DateTime(2025, 1, 1, 10, 1),
        ),
      ];

      when(() => mockCubit.state).thenReturn(VoiceChatState(
        status: VoiceChatStatus.initial,
        messages: messages,
      ));

      await tester.pumpWidget(wrapWithMaterial(const VoiceChatPage()));
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(VoiceChatPage),
        matchesGoldenFile("goldens/voice_chat_page_initial.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('VoiceChatPage - Loading State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(const VoiceChatState(
        status: VoiceChatStatus.loading,
      ));

      await tester.pumpWidget(wrapWithMaterial(const VoiceChatPage()));
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(VoiceChatPage),
        matchesGoldenFile("goldens/voice_chat_page_loading.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('VoiceChatPage - Recording State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(const VoiceChatState(
        status: VoiceChatStatus.recording,
        statusMessage: 'Escuchando...',
      ));

      await tester.pumpWidget(wrapWithMaterial(const VoiceChatPage()));
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(VoiceChatPage),
        matchesGoldenFile("goldens/voice_chat_page_recording.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('VoiceChatPage - Processing State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(const VoiceChatState(
        status: VoiceChatStatus.processing,
        statusMessage: 'Pensando...',
      ));

      await tester.pumpWidget(wrapWithMaterial(const VoiceChatPage()));
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(VoiceChatPage),
        matchesGoldenFile("goldens/voice_chat_page_processing.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('VoiceChatPage - Speaking State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(const VoiceChatState(
        status: VoiceChatStatus.speaking,
        statusMessage: 'Orion está hablando...',
      ));

      await tester.pumpWidget(wrapWithMaterial(const VoiceChatPage()));
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(VoiceChatPage),
        matchesGoldenFile("goldens/voice_chat_page_speaking.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('VoiceChatPage - Error State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(const VoiceChatState(
        status: VoiceChatStatus.error,
        errorMessage: 'Error de conexión con el servidor de voz',
        statusMessage: 'Error',
      ));

      await tester.pumpWidget(wrapWithMaterial(const VoiceChatPage()));
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(VoiceChatPage),
        matchesGoldenFile("goldens/voice_chat_page_error.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
