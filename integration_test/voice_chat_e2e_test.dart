// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/pages/voice_chat_page.dart';
import 'package:orionhealth_health/core/services/audio/audio_player_service.dart';
import 'package:orionhealth_health/core/services/aicore_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'utils/video_recorder.dart';

class MockAudioService extends Mock implements AudioService {}
class MockAIService extends Mock implements AIService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAudioService mockAudioService;
  late MockAIService mockAIService;

  setUpAll(() async {
    di.getIt.allowReassignment = true;
  });

  setUp(() async {
    await di.getIt.reset();
    await di.configureDependencies();

    mockAudioService = MockAudioService();
    mockAIService = MockAIService();

    // Register mocks as overrides
    di.getIt.registerSingleton<AudioService>(mockAudioService);
    di.getIt.registerSingleton<AIService>(mockAIService);

    // Default mock behaviors
    when(() => mockAudioService.currentVolumeStream).thenAnswer((_) => const Stream.empty());
    when(() => mockAudioService.stateStream).thenAnswer((_) => const Stream.empty());
    when(() => mockAudioService.initialize()).thenAnswer((_) async {});
    when(() => mockAudioService.stopAll()).thenAnswer((_) async {});
    when(() => mockAudioService.speakText(any())).thenAnswer((_) async {});
    when(() => mockAudioService.startRecording()).thenAnswer((_) async {});
    when(() => mockAudioService.stopRecording()).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));

    when(() => mockAIService.currentState).thenReturn(AIServiceState.ready);
    when(() => mockAIService.stateStream).thenAnswer((_) => const Stream.empty());
    when(() => mockAIService.initialize()).thenAnswer((_) async {});
    when(() => mockAIService.transcribeAudio(any())).thenAnswer((_) async => 'Consulta por voz');
    when(() => mockAIService.getResponse(any(), context: any(named: 'context')))
        .thenAnswer((_) async => 'Respuesta simulada');
  });

  group('Voice Chat - Integrated E2E Tests', () {
    testWidgets('E2E: Page Rendering and Initial State', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: VoiceChatPage(),
      ));

      // Use pump() instead of pumpAndSettle() due to infinite pulse animation
      await tester.pump(const Duration(milliseconds: 500));
      await VideoRecorder.recordStep(tester, 'voice_chat', '01_initial_state');

      expect(find.text('Orion — Chat de Voz'), findsOneWidget);
      expect(find.text('Listo para conversar'), findsOneWidget);
    });

    testWidgets('E2E: Text Message Flow', (WidgetTester tester) async {
      when(() => mockAIService.getResponse(any(), context: any(named: 'context')))
          .thenAnswer((_) async => 'Hola, ¿en qué puedo ayudarte?');

      await tester.pumpWidget(const MaterialApp(
        home: VoiceChatPage(),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter text
      await tester.enterText(textField, 'Hola Orion');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // Processing state
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Generando respuesta...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'voice_chat', '02_message_sent');

      // Verify message appears in UI
      expect(find.text('Hola Orion'), findsOneWidget);

      // Wait for AI response processing and speaking state
      await tester.pump(const Duration(seconds: 1));

      // Verify AI response appears
      expect(find.text('Hola, ¿en qué puedo ayudarte?'), findsOneWidget);
      expect(find.text('Respondiendo...'), findsOneWidget);

      // Verify TTS was called
      verify(() => mockAudioService.speakText('Hola, ¿en qué puedo ayudarte?')).called(1);

      await VideoRecorder.recordStep(tester, 'voice_chat', '03_ai_responded');
    });

    testWidgets('E2E: Voice Recording and Transcription', (WidgetTester tester) async {
      when(() => mockAIService.transcribeAudio(any())).thenAnswer((_) async => 'Consulta por voz');
      when(() => mockAIService.getResponse(any(), context: any(named: 'context')))
          .thenAnswer((_) async => 'Recibido por voz');

      await tester.pumpWidget(const MaterialApp(
        home: VoiceChatPage(),
      ));
      await tester.pump(const Duration(milliseconds: 500));

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
      expect(find.text('Transcribiendo audio...'), findsOneWidget);

      // Wait for transcription and response
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Consulta por voz'), findsOneWidget);
      expect(find.text('Recibido por voz'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'voice_chat', '05_voice_transcribed');
    });

    testWidgets('E2E: Clear Chat History', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: VoiceChatPage(),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      // Send a message to populate history
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Test'), findsOneWidget);

      // Tap clear history button (AppBar action)
      final deleteIcon = find.byIcon(Icons.delete_outline);
      expect(deleteIcon, findsOneWidget);

      await tester.tap(deleteIcon);
      await tester.pump(const Duration(milliseconds: 500));

      // Verify history is cleared (message should be gone)
      expect(find.text('Test'), findsNothing);
      expect(find.text('Conversación limpiada'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'voice_chat', '06_history_cleared');
    });
  });
}
