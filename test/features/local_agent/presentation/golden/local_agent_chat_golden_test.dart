import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';
import '../../../../core/golden_test_utils.dart';

class MockLlmService extends Mock implements LlmService {}

void main() {
  late MockLlmService mockLlmService;

  setUp(() async {
    mockLlmService = MockLlmService();
    final getIt = GetIt.instance;
    await getIt.reset();
  });

  testWidgets('ChatPage - AI Interface Golden Test', (tester) async {
    setupGoldenTest(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: ChatPage(llmService: mockLlmService),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ChatPage),
      matchesGoldenFile('goldens/agent_chat_page.png'),
    );
    resetGoldenTest(tester);
  });
}
