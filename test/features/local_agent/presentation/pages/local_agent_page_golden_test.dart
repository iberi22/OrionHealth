import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/local_agent/presentation/pages/llm_settings_page.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/model_download_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/scraper_config_page.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/widgets/voice_input_button.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_cubit.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_state.dart';

class MockModelDownloadService extends Mock implements ModelDownloadService {}
class MockLlmService extends Mock implements LlmService {}
class MockSecureStorage extends Mock implements FlutterSecureStorage {}
class MockVoiceChatCubit extends Mock implements VoiceChatCubit {}

void main() {
  late MockModelDownloadService mockDownloadService;
  late MockLlmService mockLlmService;
  late MockSecureStorage mockSecureStorage;
  late MockVoiceChatCubit mockVoiceChatCubit;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    mockDownloadService = MockModelDownloadService();
    mockLlmService = MockLlmService();
    mockSecureStorage = MockSecureStorage();
    mockVoiceChatCubit = MockVoiceChatCubit();

    final getIt = GetIt.instance;
    await getIt.reset();

    getIt.registerLazySingleton<ModelDownloadService>(() => mockDownloadService);
    getIt.registerLazySingleton<LlmService>(() => mockLlmService);
    getIt.registerLazySingleton<FlutterSecureStorage>(() => mockSecureStorage);
  });

  group('Local Agent Golden Tests', () {
    testWidgets('LlmSettingsPage - Gemini Configuration', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      when(() => mockSecureStorage.read(key: 'gemini_api_key')).thenAnswer((_) async => 'mock-api-key');
      when(() => mockSecureStorage.read(key: 'llm_provider')).thenAnswer((_) async => 'Gemini');
      when(() => mockDownloadService.listDownloadedModels()).thenAnswer((_) async => []);

      await tester.pumpWidget(const MaterialApp(home: LlmSettingsPage()));
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(LlmSettingsPage),
        matchesGoldenFile("../../../../../golden/reference/llm_settings_page.png"),
      );
    });

    testWidgets('LlmSettingsPage - Local LLM Configuration', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      when(() => mockSecureStorage.read(key: 'gemini_api_key')).thenAnswer((_) async => null);
      when(() => mockSecureStorage.read(key: 'llm_provider')).thenAnswer((_) async => 'Local LLM');
      when(() => mockDownloadService.listDownloadedModels()).thenAnswer(
        (_) async => [
          ModelInfo(
            filename: 'gemma-2b-q4.gguf',
            size: 1600000000,
            lastModified: DateTime(2023, 1, 1),
            parameters: '2B',
          ),
        ],
      );

      await tester.pumpWidget(const MaterialApp(home: LlmSettingsPage()));
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(LlmSettingsPage),
        matchesGoldenFile("../../../../../golden/reference/local_agent_settings.png"),
      );
    });

    testWidgets('ChatPage - AI Interface', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(MaterialApp(home: ChatPage(llmService: mockLlmService)));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ChatPage),
        matchesGoldenFile("../../../../../golden/reference/agent_chat_page.png"),
      );
    });

    testWidgets('MessageBubble - User', (tester) async {
      tester.view.physicalSize = const Size(360, 400);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(MaterialApp(home: ChatPage(llmService: mockLlmService)));
      await tester.pumpAndSettle();

      // Type a message to get a user bubble
      await tester.enterText(find.byType(TextField), 'Test message');
      when(() => mockLlmService.generate(any())).thenAnswer((_) => Stream.fromIterable(['Response']));
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Find the last Align and check its alignment
      final userBubbleFinder = find.descendant(of: find.byType(ListView), matching: find.byType(Align)).last;

      await expectLater(
        userBubbleFinder,
        matchesGoldenFile("../../../../../golden/reference/message_bubble_user.png"),
      );
    });

    testWidgets('MessageBubble - AI', (tester) async {
      tester.view.physicalSize = const Size(360, 400);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(MaterialApp(home: ChatPage(llmService: mockLlmService)));
      await tester.pumpAndSettle();

      final aiBubbleFinder = find.descendant(of: find.byType(ListView), matching: find.byType(Align)).first;

      await expectLater(
        aiBubbleFinder,
        matchesGoldenFile("../../../../../golden/reference/message_bubble_ai.png"),
      );
    });

    testWidgets('VoiceInputButton', (tester) async {
      tester.view.physicalSize = const Size(200, 250);
      tester.view.devicePixelRatio = 1.0;

      when(() => mockVoiceChatCubit.state).thenReturn(const VoiceChatState(status: VoiceChatStatus.initial));
      when(() => mockVoiceChatCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
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
    });

    testWidgets('ScraperConfigPage', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const MaterialApp(home: ScraperConfigPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ScraperConfigPage),
        matchesGoldenFile("../../../../../golden/reference/scraper_config_page.png"),
      );
    });
  });
}
