import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/pages/voice_chat_page.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_cubit.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_state.dart';
import 'package:orionhealth_health/features/voice_chat/domain/entities/voice_chat_message.dart';
import 'package:orionhealth_health/core/services/aicore_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'utils/video_recorder.dart';

class MockVoiceChatCubit extends Mock implements VoiceChatCubit {
  @override
  Future<void> close() async {}
}

class MockAIService extends Mock implements AIService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockVoiceChatCubit mockCubit;
  late MockAIService mockAIService;

  setUp(() {
    mockCubit = MockVoiceChatCubit();
    mockAIService = MockAIService();

    GetIt.I.registerSingleton<VoiceChatCubit>(mockCubit);
    GetIt.I.registerSingleton<AIService>(mockAIService);

    when(() => mockCubit.init()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAIService.currentState).thenReturn(AIServiceState.ready);
  });

  tearDown(() {
    GetIt.I.unregister<VoiceChatCubit>();
    GetIt.I.unregister<AIService>();
  });

  group('Voice Chat - E2E Tests', () {
    testWidgets('E2E: Open Chat and Send Message', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const VoiceChatState(
        status: VoiceChatStatus.initial,
        messages: [],
      ));
      when(() => mockCubit.sendMessage(any())).thenAnswer((_) async {});

      await tester.pumpWidget(const MaterialApp(
        home: VoiceChatPage(),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'voice_chat', '01_empty_chat');

      expect(find.text('Orion — Chat de Voz'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Hello Orion');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      verify(() => mockCubit.sendMessage('Hello Orion')).called(1);
    });

    testWidgets('E2E: Voice Input Toggle and Clear History', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const VoiceChatState(
        status: VoiceChatStatus.initial,
      ));
      when(() => mockCubit.clearHistory()).thenAnswer((_) async {});

      await tester.pumpWidget(const MaterialApp(
        home: VoiceChatPage(),
      ));
      await tester.pumpAndSettle();

      // Voice Input Interaction
      expect(find.byIcon(Icons.mic), findsOneWidget);
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();
      await VideoRecorder.recordStep(tester, 'voice_chat', '02_voice_input_active');

      // Clear History Interaction
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();
      await VideoRecorder.recordStep(tester, 'voice_chat', '03_clear_history_triggered');

      verify(() => mockCubit.clearHistory()).called(1);
    });

    testWidgets('E2E: Display Messages', (WidgetTester tester) async {
      final messages = [
        VoiceChatMessage(
          id: '1',
          content: 'Hello User',
          role: MessageRole.ai,
          timestamp: DateTime.now(),
        ),
        VoiceChatMessage(
          id: '2',
          content: 'How can I help?',
          role: MessageRole.ai,
          timestamp: DateTime.now(),
        ),
      ];

      when(() => mockCubit.state).thenReturn(VoiceChatState(
        status: VoiceChatStatus.initial,
        messages: messages,
      ));

      await tester.pumpWidget(const MaterialApp(
        home: VoiceChatPage(),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'voice_chat', '04_messages_displayed');

      expect(find.text('Hello User'), findsOneWidget);
      expect(find.text('How can I help?'), findsOneWidget);
    });

   group('Edge Cases', () {
      testWidgets('Loading State Rendering', (WidgetTester tester) async {
        when(() => mockCubit.state).thenReturn(const VoiceChatState(
          status: VoiceChatStatus.loading,
        ));

        await tester.pumpWidget(const MaterialApp(
          home: VoiceChatPage(),
        ));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await VideoRecorder.recordStep(tester, 'voice_chat', '05_loading_state');
      });
    });
  });
}
