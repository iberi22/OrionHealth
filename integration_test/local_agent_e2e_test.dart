import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';
import 'package:orionhealth_health/features/local_agent/presentation/pages/llm_settings_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/model_download_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockLlmService extends Mock implements LlmService {}
class MockModelDownloadService extends Mock implements ModelDownloadService {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockLlmService mockLlm;
  late MockModelDownloadService mockDownload;
  late MockFlutterSecureStorage mockStorage;

  setUpAll(() async {
    await di.configureDependencies();
    di.getIt.allowReassignment = true;
  });

  setUp(() {
    mockLlm = MockLlmService();
    mockDownload = MockModelDownloadService();
    mockStorage = MockFlutterSecureStorage();

    // Register/Override mocks
    di.getIt.registerSingleton<LlmService>(mockLlm);
    di.getIt.registerSingleton<ModelDownloadService>(mockDownload);
    di.getIt.registerSingleton<FlutterSecureStorage>(mockStorage);

    // Default mock behaviors
    when(() => mockStorage.read(key: any(named: 'key'))).thenAnswer((_) async => null);
    when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value'))).thenAnswer((_) async {});
    when(() => mockDownload.listDownloadedModels()).thenAnswer((_) async => []);
  });

  group('Local Agent Flow - Comprehensive E2E Tests', () {
    testWidgets('E2E: Chat with AI Assistant and navigate to Settings', (WidgetTester tester) async {
      when(() => mockLlm.generate(any())).thenAnswer((_) => Stream.fromIterable(['La diabetes es una enfermedad crónica...']));

      await tester.pumpWidget(MaterialApp(
        home: ChatPage(llmService: mockLlm),
        theme: ThemeData.dark(),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'local_agent', '01_chat_initial');

      // Verify Initial Message
      expect(find.textContaining('Bienvenido a OrionHealth'), findsOneWidget);

      // Send a message
      await tester.enterText(find.byType(TextField), '¿Qué es la diabetes?');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(find.text('¿Qué es la diabetes?'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.textContaining('La diabetes es una enfermedad crónica...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'local_agent', '02_chat_response');

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('LLM Settings'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'local_agent', '03_settings_page');
    });

    testWidgets('E2E: Configure LLM Provider and API Key', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const LlmSettingsPage(),
        theme: ThemeData.dark(),
      ));
      await tester.pumpAndSettle();

      // Switch to Gemini Provider
      await tester.tap(find.text('GEMINI'));
      await tester.pumpAndSettle();

      expect(find.text('Gemini API Key'), findsOneWidget);

      // Enter API Key
      await tester.enterText(find.byType(TextField), 'test-api-key');
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      verify(() => mockStorage.write(key: 'gemini_api_key', value: 'test-api-key')).called(1);
      expect(find.text('Gemini API Key saved'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'local_agent', '04_settings_gemini_config');
    });

    testWidgets('E2E: Simulate Local Model Download', (WidgetTester tester) async {
      when(() => mockDownload.downloadModel(any(), any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[1] as Function(double, String, int, int);
        callback(0.5, "10 MB/s", 500, 1000);
        await Future.delayed(const Duration(milliseconds: 100));
        callback(1.0, "Done", 1000, 1000);
      });

      await tester.pumpWidget(MaterialApp(
        home: const LlmSettingsPage(),
        theme: ThemeData.dark(),
      ));
      await tester.pumpAndSettle();

      // Switch to Local LLM Provider
      await tester.tap(find.text('LOCAL LLM'));
      await tester.pumpAndSettle();

      // Trigger Download
      await tester.tap(find.text('Download Gemma 4 E2B'));
      await tester.pump(); // Show dialog

      expect(find.text('Downloading Gemma 4 E2B'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200)); // Process mock progress

      await VideoRecorder.recordStep(tester, 'local_agent', '05_model_downloading');

      await tester.pumpAndSettle(); // Finish download and close dialog
      expect(find.text('Downloading Gemma 4 E2B'), findsNothing);
    });
  });
}
