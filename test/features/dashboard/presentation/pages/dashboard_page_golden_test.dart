import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:flutter/services.dart';
import '../../../../core/golden_test_utils.dart';

class MockLlmService extends Mock implements LlmService {}

void main() {
  late MockLlmService mockLlmService;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    mockLlmService = MockLlmService();
    GetIt.I.reset();
    GetIt.I.registerSingleton<LlmService>(mockLlmService);
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
