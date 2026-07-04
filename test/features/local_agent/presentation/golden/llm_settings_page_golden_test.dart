import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orionhealth_health/features/local_agent/presentation/pages/llm_settings_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/model_download_service.dart';
import '../../../../core/golden_test_utils.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}
class MockModelDownloadService extends Mock implements ModelDownloadService {}

void main() {
  late MockSecureStorage mockSecureStorage;
  late MockModelDownloadService mockDownloadService;

  setUp(() async {
    mockSecureStorage = MockSecureStorage();
    mockDownloadService = MockModelDownloadService();

    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerLazySingleton<FlutterSecureStorage>(() => mockSecureStorage);
    getIt.registerLazySingleton<ModelDownloadService>(() => mockDownloadService);
  });

  group('LlmSettingsPage Golden Tests', () {
    testWidgets('Mock Provider Configuration', (tester) async {
      setupGoldenTest(tester);

      when(() => mockSecureStorage.read(key: 'gemini_api_key')).thenAnswer((_) async => null);
      when(() => mockSecureStorage.read(key: 'llm_provider')).thenAnswer((_) async => 'Mock');
      when(() => mockDownloadService.listDownloadedModels()).thenAnswer((_) async => []);

      await tester.pumpWidget(wrapWithMaterial(const LlmSettingsPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LlmSettingsPage),
        matchesGoldenFile("../../../../../golden/reference/llm_settings_mock.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Gemini Provider Configuration', (tester) async {
      setupGoldenTest(tester);

      when(() => mockSecureStorage.read(key: 'gemini_api_key')).thenAnswer((_) async => 'sk-mock-key');
      when(() => mockSecureStorage.read(key: 'llm_provider')).thenAnswer((_) async => 'Gemini');
      when(() => mockDownloadService.listDownloadedModels()).thenAnswer((_) async => []);

      await tester.pumpWidget(wrapWithMaterial(const LlmSettingsPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LlmSettingsPage),
        matchesGoldenFile("../../../../../golden/reference/llm_settings_gemini.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Local LLM Provider Configuration', (tester) async {
      setupGoldenTest(tester);

      when(() => mockSecureStorage.read(key: 'gemini_api_key')).thenAnswer((_) async => null);
      when(() => mockSecureStorage.read(key: 'llm_provider')).thenAnswer((_) async => 'Local LLM');
      when(() => mockDownloadService.listDownloadedModels()).thenAnswer(
        (_) async => [
          ModelInfo(
            filename: 'gemma-2b-q4.gguf',
            size: 1600000000,
            lastModified: DateTime(2024, 1, 1),
            parameters: '2B',
          ),
        ],
      );

      await tester.pumpWidget(wrapWithMaterial(const LlmSettingsPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LlmSettingsPage),
        matchesGoldenFile("../../../../../golden/reference/llm_settings_local.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
