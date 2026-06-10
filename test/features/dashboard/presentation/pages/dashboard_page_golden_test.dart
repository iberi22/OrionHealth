import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import '../../../../core/golden_test_utils.dart';

class MockLlmService extends Mock implements LlmService {}

void main() {
  late MockLlmService mockLlmService;

  setUpAll(() {
    mockLlmService = MockLlmService();
    GetIt.I.registerSingleton<LlmService>(mockLlmService);
  });

  tearDownAll(() {
    GetIt.I.reset();
  });

  group('Dashboard Golden Tests', () {
    testWidgets('Home Dashboard Page', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(const HomeDashboardPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile('goldens/home_dashboard_page.png'),
      );
      resetGoldenTest(tester);
    });
  });
}
