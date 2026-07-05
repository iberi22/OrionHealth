import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/pages/voice_chat_page.dart';
import 'package:orionhealth_health/core/services/audio/audio_player_service.dart';
import 'package:orionhealth_health/core/services/aicore_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
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
    // Basic setup before all tests
  });

  setUp(() async {
    await di.getIt.reset();
    di.getIt.allowReassignment = true;

    mockAudioService = MockAudioService();
    mockAIService = MockAIService();
    mockAsrService = MockAsrService();
    mockAgentMemoryService = MockAgentMemoryService();

    audioStateController = StreamController<AudioState>.broadcast();
    volumeController = StreamController<double>.broadcast();

    await di.configureDependencies();

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

  group('Voice Chat - Integrated E2E Tests', () {
    testWidgets('E2E: Page Rendering and Initial State', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: VoiceChatPage(),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'voice_chat', '01_initial_state');

      expect(find.text('Orion — Chat de Voz'), findsOneWidget);
      // Wait for cubit initialization
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Listo para conversar'), findsOneWidget);
    });

    testWidgets('E2E: Text Message Flow', (WidgetTester tester) async {
      // Mock AI response
      when(() => mockAIService.getResponse(any(), context: any(named: 'context')))
          .thenAnswer((_) async => 'Hola, ¿en qué puedo ayudarte?');

      await tester.pumpWidget(const MaterialApp(
        home: VoiceChatPage(),
      ));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter text
      await tester.enterText(textField, 'Hola Orion');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // We use pump() instead of pumpAndSettle because of the infinite animation in VoiceChatPage
      await tester.pump(const Duration(milliseconds: 500));
      await VideoRecorder.recordStep(tester, 'voice_chat', '02_message_sent');

      // Verify message appears in UI
      expect(find.text('Hola Orion'), findsOneWidget);

      // Wait for AI response processing
      await tester.pump(const Duration(seconds: 1));

      // Verify AI response appears
      expect(find.text('Hola, ¿en qué puedo ayudarte?'), findsOneWidget);

      // Verify TTS was called
      verify(() => mockAudioService.speakText('Hola, ¿en qué puedo ayudarte?')).called(1);

      await VideoRecorder.recordStep(tester, 'voice_chat', '03_ai_responded');
    });

    testWidgets('E2E: Voice Recording and Transcription', (WidgetTester tester) async {
      // Mock behaviors
      when(() => mockAudioService.startRecording()).thenAnswer((_) async {});
      when(() => mockAudioService.stopRecording()).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
      when(() => mockAIService.transcribeAudio(any())).thenAnswer((_) async => 'Consulta por voz');
      when(() => mockAIService.getResponse(any(), context: any(named: 'context')))
          .thenAnswer((_) async => 'Recibido por voz');

      await tester.pumpWidget(const MaterialApp(
        home: VoiceChatPage(),
      ));
      await tester.pumpAndSettle();

      // Find mic button (VoiceInputButton uses GestureDetector for long press)
      final micIcon = find.byIcon(Icons.mic_none);
      expect(micIcon, findsOneWidget);

      // Start recording with Long Press
      final gesture = await tester.startGesture(tester.getCenter(micIcon));
      // Long press detection usually takes ~500ms
      await tester.pump(const Duration(milliseconds: 600));

      verify(() => mockAudioService.startRecording()).called(1);
      expect(find.text('Grabando...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'voice_chat', '04_recording');

      // Stop recording (release)
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 500));

      verify(() => mockAudioService.stopRecording()).called(1);

      // Wait for transcription and response
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Consulta por voz'), findsOneWidget);
      expect(find.text('Recibido por voz'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'voice_chat', '05_voice_transcribed');
    });

    testWidgets('E2E: Clear Chat History', (WidgetTester tester) async {
       // Mock AI response to have some messages
      when(() => mockAIService.getResponse(any(), context: any(named: 'context')))
          .thenAnswer((_) async => 'Respuesta');

      await tester.pumpWidget(const MaterialApp(
        home: VoiceChatPage(),
      ));
      await tester.pumpAndSettle();

      // Send a message to populate history
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Test'), findsOneWidget);

      // Tap clear history button (AppBar action)
      final deleteIcon = find.byIcon(Icons.delete_outline);
      expect(deleteIcon, findsOneWidget);

      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      // Verify history is cleared
      expect(find.text('Test'), findsNothing);
      expect(find.text('Conversación limpiada'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'voice_chat', '06_history_cleared');
    });
  });
}
