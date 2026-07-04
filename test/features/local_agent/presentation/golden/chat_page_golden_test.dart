import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import '../../../../core/golden_test_utils.dart';

class MockLlmService extends Mock implements LlmService {}

void main() {
  late MockLlmService mockLlmService;

  setUp(() {
    mockLlmService = MockLlmService();
  });

  group('ChatPage Golden Tests', () {
    testWidgets('Initial State', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        ChatPage(llmService: mockLlmService),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ChatPage),
        matchesGoldenFile("../../../../../golden/reference/agent_chat_page_initial.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('With Conversation', (tester) async {
      setupGoldenTest(tester);

      when(() => mockLlmService.generate(any())).thenAnswer(
        (_) => Stream.fromIterable(['¡Claro! El paracetamol es un analgésico común.']),
      );

      await tester.pumpWidget(wrapWithMaterial(
        ChatPage(llmService: mockLlmService),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '¿Qué es el paracetamol?');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ChatPage),
        matchesGoldenFile("../../../../../golden/reference/agent_chat_page_conversation.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
