import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockLlmService extends Mock implements LlmService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockLlmService mockLlm;

  setUp(() {
    mockLlm = MockLlmService();
  });

  group('Local Agent Flow - E2E Tests', () {
    testWidgets('E2E: Chat with AI Assistant', (WidgetTester tester) async {
      when(() => mockLlm.generate(any())).thenAnswer((_) => Stream.fromIterable(['La diabetes es...']));

      await tester.pumpWidget(MaterialApp(home: ChatPage(llmService: mockLlm)));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'local_agent', '01_chat_start');

      await tester.enterText(find.byType(TextField), '¿Qué es la diabetes?');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(find.text('¿Qué es la diabetes?'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.textContaining('La diabetes es...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'local_agent', '02_response');
    });
  });
}
