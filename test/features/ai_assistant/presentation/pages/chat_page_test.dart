import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/ai_assistant/presentation/pages/chat_page.dart';
import 'package:orionhealth_health/features/ai_assistant/presentation/widgets/message_composer.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/mock_llm_service.dart';

void main() {
  testWidgets('ChatPage renders initial message and composer', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChatPage(llmService: MockLlmService()),
      ),
    );

    // Verify initial message
    expect(find.textContaining('Welcome to OrionHealth'), findsOneWidget);

    // Verify composer is present
    expect(find.byType(MessageComposer), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
  });

  testWidgets('Sending a message updates the UI', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChatPage(llmService: MockLlmService()),
      ),
    );

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Hello Assistant');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    // Verify user message appears
    expect(find.text('Hello Assistant'), findsOneWidget);

    // Verify typing indicator appears (it should be in 'thinking' state initially)
    expect(find.text('Orion is thinking...'), findsOneWidget);

    // Pump to allow stream to start
    await tester.pump(const Duration(milliseconds: 100));
    // Now it should be 'responding'
    expect(find.text('Orion is responding...'), findsOneWidget);

    // Wait for mock service to complete (it usually sends a few chunks)
    await tester.pumpAndSettle();

    // Verify typing indicator is gone
    expect(find.text('Orion is responding...'), findsNothing);
  });

  testWidgets('Quick prompt sends a message', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChatPage(llmService: MockLlmService()),
      ),
    );

    // Find a quick prompt chip
    final chip = find.text('Analyze my last labs');
    await tester.tap(chip);
    await tester.pump();

    // Verify message was sent
    expect(find.text('Analyze my last labs'), findsOneWidget);
    expect(find.text('Orion is thinking...'), findsOneWidget);

    await tester.pumpAndSettle();
  });
}
