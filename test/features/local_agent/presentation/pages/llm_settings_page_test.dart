import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/model_download_service.dart';
import 'package:orionhealth_health/features/local_agent/presentation/pages/llm_settings_page.dart';

// LlmProvider is re-exported via llm_settings_page.dart

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockModelDownloadService extends Mock implements ModelDownloadService {}

void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late MockModelDownloadService mockModelDownloadService;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    mockModelDownloadService = MockModelDownloadService();

    // Register in GetIt
    GetIt.I.registerSingleton<FlutterSecureStorage>(mockSecureStorage);
    GetIt.I.registerSingleton<ModelDownloadService>(mockModelDownloadService);

    // Default mocks
    when(() => mockSecureStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => mockSecureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((_) async => {});
    when(() => mockModelDownloadService.listDownloadedModels())
        .thenAnswer((_) async => []);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  Widget createTestWidget() {
    return const MaterialApp(
      home: LlmSettingsPage(),
    );
  }

  group('LlmSettingsPage', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('LLM Settings'), findsOneWidget);
    });

    testWidgets('shows provider selection', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('LLM Provider'), findsOneWidget);
    });

    testWidgets('shows all provider options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('MOCK'), findsWidgets);
      expect(find.text('GEMINI'), findsWidgets);
      expect(find.text('LOCAL LLM'), findsWidgets);
    });

    testWidgets('shows mock settings by default', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Mock Provider'), findsOneWidget);
      expect(
        find.textContaining('simulated response'),
        findsOneWidget,
      );
    });

    testWidgets('switching to Gemini shows API key field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Gemini radio tile
      final geminiTile = find.widgetWithText(RadioListTile<LlmProvider>, 'GEMINI');
      expect(geminiTile, findsOneWidget);
      await tester.tap(geminiTile);
      await tester.pumpAndSettle();

      expect(find.text('Gemini API Configuration'), findsOneWidget);
      expect(find.text('Gemini API Key'), findsOneWidget);
    });

    testWidgets('switching to Local shows downloaded models', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Local LLM radio tile
      final localTile = find.widgetWithText(RadioListTile<LlmProvider>, 'LOCAL LLM');
      expect(localTile, findsOneWidget);
      await tester.tap(localTile);
      await tester.pumpAndSettle();

      expect(find.text('Local LLM (Ollama/GGUF)'), findsOneWidget);
      expect(find.text('Downloaded Models:'), findsOneWidget);
      expect(find.text('Download Gemma 4 E2B'), findsOneWidget);
    });

    testWidgets('shows no models downloaded message in local section', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Local LLM radio
      await tester.tap(find.text('LOCAL LLM').last);
      await tester.pumpAndSettle();

      expect(
        find.text('No models downloaded yet.'),
        findsOneWidget,
      );
    });

    testWidgets('saves API key when save button is tapped', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to Gemini first
      final geminiTile = find.widgetWithText(RadioListTile<LlmProvider>, 'GEMINI');
      await tester.tap(geminiTile);
      await tester.pumpAndSettle();

      // Enter API key
      await tester.enterText(
        find.widgetWithText(TextField, 'Gemini API Key'),
        'test-api-key-123',
      );

      // Tap save icon
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      verify(() => mockSecureStorage.write(
            key: 'gemini_api_key',
            value: 'test-api-key-123',
          )).called(1);
    });

    testWidgets('switching provider saves to secure storage', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to Gemini
      final geminiTile = find.widgetWithText(RadioListTile<LlmProvider>, 'GEMINI');
      await tester.tap(geminiTile);
      await tester.pumpAndSettle();

      verify(() => mockSecureStorage.write(
            key: 'llm_provider',
            value: 'Gemini',
          )).called(1);
    });
  });
}
