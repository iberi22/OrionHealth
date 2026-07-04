import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orionhealth_health/features/local_agent/presentation/pages/llm_settings_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/model_download_service.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';
import '../../../../core/golden_test_utils.dart';

class MockModelDownloadService extends Mock implements ModelDownloadService {}
class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockModelDownloadService mockDownloadService;
  late MockSecureStorage mockSecureStorage;

  setUp(() async {
    mockDownloadService = MockModelDownloadService();
    mockSecureStorage = MockSecureStorage();

    final getIt = GetIt.instance;
    await getIt.reset();

    getIt.registerLazySingleton<ModelDownloadService>(() => mockDownloadService);
    getIt.registerLazySingleton<FlutterSecureStorage>(() => mockSecureStorage);
  });

  testWidgets('LlmSettingsPage - Local LLM Configuration Golden Test', (tester) async {
    setupGoldenTest(tester);

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

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const LlmSettingsPage(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await expectLater(
      find.byType(LlmSettingsPage),
      matchesGoldenFile('goldens/local_agent_settings.png'),
    );
    resetGoldenTest(tester);
  });
}
