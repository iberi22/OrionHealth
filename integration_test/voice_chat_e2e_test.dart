import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/home/presentation/pages/home_page.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/pages/voice_chat_page.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart' as agent;
import 'package:orionhealth_health/core/services/audio/audio_player_service.dart';
import 'package:orionhealth_health/core/services/aicore_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/video_recorder.dart';

import 'package:orionhealth_health/core/services/asr/asr_service.dart';
import 'package:orionhealth_health/core/services/asr/asr_types.dart';

class MockAudioService extends Mock implements AudioService {}
class MockAIService extends Mock implements AIService {}
class MockAsrService extends Mock implements AsrService {}
class MockAgentMemoryService extends Mock implements AgentMemoryService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAudioService mockAudioService;
  late MockAIService mockAIService;
  late MockAsrService mockAsrService;
  late MockAgentMemoryService mockAgentMemoryService;

  late StreamController<AudioState> audioStateController;
  late StreamController<double> volumeController;

  setUpAll(() async {
    await di.configureDependencies();
  });

  setUp(() async {
    di.getIt.allowReassignment = true;

    mockAudioService = MockAudioService();
    mockAIService = MockAIService();
    mockAsrService = MockAsrService();
    mockAgentMemoryService = MockAgentMemoryService();

    audioStateController = StreamController<AudioState>.broadcast();
    volumeController = StreamController<double>.broadcast();

    // Override services that require hardware/native features
    di.getIt.registerSingleton<AudioService>(mockAudioService);
    di.getIt.registerSingleton<AIService>(mockAIService);
    di.getIt.registerSingleton<AsrService>(mockAsrService);
    di.getIt.registerSingleton<AgentMemoryService>(mockAgentMemoryService);

    // Default mock behaviors
    when(() => mockAudioService.currentVolumeStream).thenAnswer((_) => volumeController.stream);
    when(() => mockAudioService.stateStream).thenAnswer((_) => audioStateController.stream);
    when(() => mockAudioService.initialize()).thenAnswer((_) async {});
    when(() => mockAudioService.stopAll()).thenAnswer((_) async {});
    when(() => mockAudioService.speakText(any())).thenAnswer((_) async {
      audioStateController.add(AudioState.speaking);
    });

    when(() => mockAIService.currentState).thenReturn(AIServiceState.ready);
    when(() => mockAIService.stateStream).thenAnswer((_) => const Stream.empty());
    when(() => mockAIService.initialize()).thenAnswer((_) async {});

    when(() => mockAsrService.currentState).thenReturn(AsrState.ready);
    when(() => mockAsrService.initialize()).thenAnswer((_) async {});
    when(() => mockAsrService.stateStream).thenAnswer((_) => const Stream.empty());

    when(() => mockAgentMemoryService.initialize()).thenAnswer((_) async {});
    when(() => mockAgentMemoryService.getContextForQuery(any())).thenAnswer((_) async => '');
    when(() => mockAgentMemoryService.getRecentHistory(limit: any(named: 'limit'))).thenAnswer((_) async => []);
    when(() => mockAgentMemoryService.addMemory(input: any(named: 'input'), output: any(named: 'output'))).thenAnswer((_) async {});
  });

  tearDown(() {
    audioStateController.close();
    volumeController.close();
  });

  Widget createVoiceChatTestWidget(Widget home) {
    return MaterialApp(
      home: home,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
    );
  }

  group('Voice Chat - True E2E Tests', () {
    testWidgets('E2E: Navigation to Voice Chat and Basic Interaction', (WidgetTester tester) async {
       // Mock AI response
      when(() => mockAIService.getResponse(any(), context: any(named: 'context')))
          .thenAnswer((_) async => 'Hola, ¿en qué puedo ayudarte?');

      // Start from Home Page
      await tester.pumpWidget(createVoiceChatTestWidget(const HomePage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'voice_chat', '01_home_page');

      // Find AI Assistant module
      final aiAssistantCard = find.text('AI Assistant');
      expect(aiAssistantCard, findsOneWidget);
      await tester.tap(aiAssistantCard);
      await tester.pumpAndSettle();

      // We should be in agent.ChatPage now
      expect(find.byType(agent.ChatPage), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'voice_chat', '02_chat_page');

      // Navigate to Voice Chat via the Mic icon in AppBar
      final voiceChatBtn = find.byIcon(Icons.mic);
      expect(voiceChatBtn, findsOneWidget);
      await tester.tap(voiceChatBtn);
      await tester.pumpAndSettle();

      // Verify Voice Chat Page
      expect(find.byType(VoiceChatPage), findsOneWidget);
      expect(find.text('Orion — Chat de Voz'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'voice_chat', '03_voice_chat_loaded');

      // Text Message Flow
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Hola Orion');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Hola Orion'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Hola, ¿en qué puedo ayudarte?'), findsOneWidget);
      verify(() => mockAudioService.speakText('Hola, ¿en qué puedo ayudarte?')).called(1);
      await VideoRecorder.recordStep(tester, 'voice_chat', '04_message_exchanged');

      // Voice recording interaction
      when(() => mockAudioService.startRecording()).thenAnswer((_) async {});
      when(() => mockAudioService.stopRecording()).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
      when(() => mockAIService.transcribeAudio(any())).thenAnswer((_) async => 'Consulta por voz');

      final micButton = find.byIcon(Icons.mic_none);
      final gesture = await tester.startGesture(tester.getCenter(micButton));
      await tester.pump(const Duration(milliseconds: 600));
      verify(() => mockAudioService.startRecording()).called(1);
      expect(find.text('Grabando...'), findsOneWidget);

      await gesture.up();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Consulta por voz'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'voice_chat', '05_voice_recorded');

      // Clear history
      final deleteIcon = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();
      expect(find.text('Hola Orion'), findsNothing);
      expect(find.text('Conversación limpiada'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'voice_chat', '06_history_cleared');
    });

    testWidgets('E2E: Handles Error State', (WidgetTester tester) async {
      when(() => mockAIService.getResponse(any(), context: any(named: 'context')))
          .thenThrow(Exception('AI Error'));

      await tester.pumpWidget(createVoiceChatTestWidget(const VoiceChatPage()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Test error');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception: AI Error'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'voice_chat', '07_error_state');
    });
  });
}
