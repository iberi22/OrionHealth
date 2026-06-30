import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import '../../../../core/golden_test_utils.dart';

class MockLlmService extends Mock implements LlmService {}

void main() {
  late MockLlmService mockLlmService;

  setUp(() {
    mockLlmService = MockLlmService();
    final getIt = GetIt.instance;
    getIt.allowReassignment = true;
    getIt.registerSingleton<LlmService>(mockLlmService);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('AiAssistant Golden Tests', () {
    testWidgets('ChatPage - Initial View', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(ChatPage(llmService: mockLlmService)));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ChatPage),
        matchesGoldenFile("../../../../golden/reference/04_ai_assistant_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
