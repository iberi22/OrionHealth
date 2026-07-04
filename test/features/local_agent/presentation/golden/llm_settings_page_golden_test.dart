import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orionhealth_health/features/local_agent/presentation/pages/llm_settings_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/model_download_service.dart';
import '../../../../core/golden_test_utils.dart';

class MockModelDownloadService extends Mock implements ModelDownloadService {}
class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockModelDownloadService mockDownloadService;
  late MockSecureStorage mockSecureStorage;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    mockDownloadService = MockModelDownloadService();
    mockSecureStorage = MockSecureStorage();

    final getIt = GetIt.instance;
    await getIt.reset();

    getIt.registerLazySingleton<ModelDownloadService>(() => mockDownloadService);
    getIt.registerLazySingleton<FlutterSecureStorage>(() => mockSecureStorage);
  });

  group('LlmSettingsPage Golden Tests', () {
    testWidgets('LlmSettingsPage - Gemini Configuration', (tester) async {
      setupGoldenTest(tester);

      when(() => mockSecureStorage.read(key: 'gemini_api_key')).thenAnswer((_) async => 'mock-api-key');
      when(() => mockSecureStorage.read(key: 'llm_provider')).thenAnswer((_) async => 'Gemini');
      when(() => mockDownloadService.listDownloadedModels()).thenAnswer((_) async => []);

      await tester.pumpWidget(wrapWithMaterial(const LlmSettingsPage()));
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(LlmSettingsPage),
        matchesGoldenFile("../../../../../golden/reference/llm_settings_page.png"),
      );

      resetGoldenTest(tester);
    });

    testWidgets('LlmSettingsPage - Local LLM Configuration', (tester) async {
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

      await tester.pumpWidget(wrapWithMaterial(const LlmSettingsPage()));
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(LlmSettingsPage),
        matchesGoldenFile("../../../../../golden/reference/local_agent_settings.png"),
      );

      resetGoldenTest(tester);
    });
  });
}
