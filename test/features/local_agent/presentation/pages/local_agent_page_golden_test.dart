import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orionhealth_health/features/local_agent/presentation/pages/llm_settings_page.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/model_download_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';

class MockModelDownloadService extends Mock implements ModelDownloadService {}

class MockLlmService extends Mock implements LlmService {}

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockModelDownloadService mockDownloadService;
  late MockLlmService mockLlmService;
  late MockSecureStorage mockSecureStorage;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    mockDownloadService = MockModelDownloadService();
    mockLlmService = MockLlmService();
    mockSecureStorage = MockSecureStorage();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<ModelDownloadService>()) {
      getIt.unregister<ModelDownloadService>();
    }
    if (getIt.isRegistered<LlmService>()) {
      getIt.unregister<LlmService>();
    }
    if (getIt.isRegistered<FlutterSecureStorage>()) {
      getIt.unregister<FlutterSecureStorage>();
    }
    getIt.registerLazySingleton<ModelDownloadService>(
      () => mockDownloadService,
    );
    getIt.registerLazySingleton<LlmService>(() => mockLlmService);
    getIt.registerLazySingleton<FlutterSecureStorage>(() => mockSecureStorage);
  });

  tearDown(() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<ModelDownloadService>()) {
      getIt.unregister<ModelDownloadService>();
    }
    if (getIt.isRegistered<LlmService>()) {
      getIt.unregister<LlmService>();
    }
    if (getIt.isRegistered<FlutterSecureStorage>()) {
      getIt.unregister<FlutterSecureStorage>();
    }
  });

  group('Local Agent Golden Tests', () {
    testWidgets('LlmSettingsPage - Configuration', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      when(
        () => mockSecureStorage.read(key: 'gemini_api_key'),
      ).thenAnswer((_) async => 'mock-api-key');
      when(
        () => mockSecureStorage.read(key: 'llm_provider'),
      ).thenAnswer((_) async => 'Local LLM');
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
      await tester.pump(); // Use pump instead of pumpAndSettle if it times out
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(LlmSettingsPage),
        matchesGoldenFile(
          "../../../../../golden/reference/llm_settings_page.png",
        ),
      );
    });

    testWidgets('ChatPage - AI Interface', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(home: ChatPage(llmService: mockLlmService)),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ChatPage),
        matchesGoldenFile("../../../../../golden/reference/chat_page.png"),
      );
    });
  });
}
