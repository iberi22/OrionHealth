import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/domain/chat_message.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';

class MockLlmService extends Mock implements LlmService {}

void main() {
  late MockLlmService mockLlmService;

  setUp(() {
    mockLlmService = MockLlmService();
  });

  Widget createTestWidget(LlmService service) {
    return MaterialApp(
      home: ChatPage(llmService: service),
    );
  }

  group('ChatPage', () {
    testWidgets('renders without error', (tester) async {
      when(() => mockLlmService.generate(any())).thenAnswer(
        (_) => Stream.value('Test response'),
      );

      await tester.pumpWidget(createTestWidget(mockLlmService));

      expect(find.text('Orion AI Assistant'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('shows welcome message on load', (tester) async {
      when(() => mockLlmService.generate(any())).thenAnswer(
        (_) => Stream.value('Test response'),
      );

      await tester.pumpWidget(createTestWidget(mockLlmService));

      expect(
        find.textContaining('Bienvenido a OrionHealth'),
        findsOneWidget,
      );
    });

    testWidgets('shows chat input field', (tester) async {
      when(() => mockLlmService.generate(any())).thenAnswer(
        (_) => Stream.value('Test response'),
      );

      await tester.pumpWidget(createTestWidget(mockLlmService));

      expect(
        find.widgetWithText(TextField, 'Escribe un mensaje...'),
        findsOneWidget,
      );
    });

    testWidgets('sends message and displays user message', (tester) async {
      final streamCtrl = StreamController<String>();
      when(() => mockLlmService.generate(any())).thenAnswer(
        (_) => streamCtrl.stream,
      );

      await tester.pumpWidget(createTestWidget(mockLlmService));

      // Type in the text field
      await tester.enterText(
        find.widgetWithText(TextField, 'Escribe un mensaje...'),
        'What is diabetes?',
      );

      // Tap send button
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // User message should appear
      expect(find.text('What is diabetes?'), findsWidgets);

      streamCtrl.close();
    });

    testWidgets('send button is functional', (tester) async {
      final streamCtrl = StreamController<String>();
      when(() => mockLlmService.generate(any())).thenAnswer(
        (_) => streamCtrl.stream,
      );

      await tester.pumpWidget(createTestWidget(mockLlmService));

      // Initially no send button visible - actually it is
      expect(find.byIcon(Icons.send), findsOneWidget);

      // Enter text and send
      await tester.enterText(
        find.widgetWithText(TextField, 'Escribe un mensaje...'),
        'How are you?',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Verify user message added
      expect(find.text('How are you?'), findsWidgets);

      streamCtrl.close();
    });

    testWidgets('settings button navigates to LlmSettingsPage', (tester) async {
      when(() => mockLlmService.generate(any())).thenAnswer(
        (_) => Stream.value('Test response'),
      );

      await tester.pumpWidget(createTestWidget(mockLlmService));

      // Tap settings icon
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should navigate to settings page with LLM Settings title
      expect(find.text('LLM Settings'), findsOneWidget);
    });

    testWidgets('typing indicator shown during generation', (tester) async {
      final streamCtrl = StreamController<String>();
      when(() => mockLlmService.generate(any())).thenAnswer(
        (_) => streamCtrl.stream,
      );

      await tester.pumpWidget(createTestWidget(mockLlmService));

      // Enter text and send
      await tester.enterText(
        find.widgetWithText(TextField, 'Escribe un mensaje...'),
        'test',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Typing indicator should appear
      expect(find.text('Orion AI está pensando...'), findsOneWidget);

      // Complete the stream
      streamCtrl.add('Response text');
      await streamCtrl.close();
      await tester.pump();

      // Typing indicator should disappear
      expect(find.text('Orion AI está pensando...'), findsNothing);
    });

    testWidgets('handles error during generation', (tester) async {
      when(() => mockLlmService.generate(any())).thenAnswer(
        (_) => Stream.error(Exception('API Error')),
      );

      await tester.pumpWidget(createTestWidget(mockLlmService));

      // Enter text and send
      await tester.enterText(
        find.widgetWithText(TextField, 'Escribe un mensaje...'),
        'test',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Error message should appear in Spanish
      expect(
        find.textContaining('hubo un problema'),
        findsOneWidget,
      );
    });
  });
}
