import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/model_download_service.dart';
import 'package:orionhealth_health/features/local_agent/presentation/pages/llm_settings_page.dart';
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

    // Default mock behaviors
    when(() => mockStorage.read(key: any(named: 'key'))).thenAnswer((_) async => null);
    when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    when(() => mockDownload.listDownloadedModels()).thenAnswer((_) async => []);

    di.getIt.registerSingleton<LlmService>(mockLlm);
    di.getIt.registerSingleton<ModelDownloadService>(mockDownload);
    di.getIt.registerSingleton<FlutterSecureStorage>(mockStorage);
  });

  group('Local Agent Flow - E2E Tests', () {
    testWidgets('E2E: Chat and Settings interaction', (WidgetTester tester) async {
      // 1. Chat Interaction
      when(() => mockLlm.generate(any()))
          .thenAnswer((_) => Stream.fromIterable(['La diabetes es una enfermedad crónica...']));

      await tester.pumpWidget(MaterialApp(
        home: ChatPage(llmService: mockLlm),
        theme: ThemeData.dark(),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'local_agent', '01_chat_start');

      expect(find.text('Orion AI Assistant'), findsOneWidget);
      expect(find.textContaining('Bienvenido a OrionHealth'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '¿Qué es la diabetes?');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('¿Qué es la diabetes?'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.textContaining('La diabetes es una enfermedad crónica...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'local_agent', '02_response');

      // 2. Navigation to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.byType(LlmSettingsPage), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'local_agent', '03_settings_page');

      // 3. Provider selection
      await tester.tap(find.text('GEMINI'));
      await tester.pumpAndSettle();
      verify(() => mockStorage.write(key: 'llm_provider', value: 'Gemini')).called(1);

      await tester.tap(find.text('LOCAL LLM'));
      await tester.pumpAndSettle();
      verify(() => mockStorage.write(key: 'llm_provider', value: 'Local LLM')).called(1);

      // 4. Gemini API Key (switch back to Gemini first to see the field)
      await tester.tap(find.text('GEMINI'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Gemini API Key'), 'test-api-key');
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();
      verify(() => mockStorage.write(key: 'gemini_api_key', value: 'test-api-key')).called(1);
      expect(find.text('Gemini API Key saved'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'local_agent', '04_gemini_config');

      // 5. Model Download Simulation
      await tester.tap(find.text('LOCAL LLM'));
      await tester.pumpAndSettle();

      when(() => mockDownload.downloadModel(any(), any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[1] as void Function(double, String, int, int);
        callback(0.5, "10 MB/s", 50, 100);
      });

      await tester.tap(find.text('Download Gemma 4 E2B'));
      await tester.pump(); // Start download dialog
      expect(find.text('Downloading Gemma 4 E2B'), findsOneWidget);
      expect(find.text('50 MB / 100 MB'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'local_agent', '05_download_dialog');

      // Close dialog (the mock doesn't finish the future unless we tell it to, but it's enough for E2E)
    });
  });
}
