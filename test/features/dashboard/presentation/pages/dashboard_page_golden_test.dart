import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import '../../../../core/golden_test_utils.dart';

class MockLlmService extends Mock implements LlmService {}

class FakePathProviderPlatform extends Fake with PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '/tmp/test_docs';
  
  @override
  Future<String?> getTemporaryPath() async => '/tmp/test_temp';
}

void main() {
  late MockLlmService mockLlmService;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    PathProviderPlatform.instance = FakePathProviderPlatform();
    mockLlmService = MockLlmService();
    await GetIt.I.reset();
    if (!GetIt.I.isRegistered<LlmService>()) {
      GetIt.I.registerSingleton<LlmService>(mockLlmService);
    }
  });

  tearDown(() {
    if (GetIt.I.isRegistered<LlmService>()) {
      GetIt.I.unregister<LlmService>();
    }
  });

  group('Dashboard Golden Tests', () {
    testWidgets('Home Dashboard Page', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(const HomeDashboardPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile("../../../../golden/reference/home_dashboard_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
