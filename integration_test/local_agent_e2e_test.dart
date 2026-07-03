import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockLlmService extends Mock implements LlmService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockLlmService mockLlm;

  setUpAll(() async {
    await di.configureDependencies();
  });

  setUp(() {
    mockLlm = MockLlmService();
  });

  group('Local Agent Flow - E2E Tests', () {
    testWidgets('E2E: Chat with AI Assistant using real ChatPage', (WidgetTester tester) async {
      when(() => mockLlm.generate(any())).thenAnswer((_) => Stream.fromIterable(['La diabetes es una enfermedad crónica...']));

      await tester.pumpWidget(MaterialApp(
        home: ChatPage(llmService: mockLlm),
        theme: ThemeData.dark(),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'local_agent', '01_chat_start');

      expect(find.text('Orion AI Assistant'), findsOneWidget);
      expect(find.textContaining('Bienvenido'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '¿Qué es la diabetes?');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('¿Qué es la diabetes?'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.textContaining('La diabetes es una enfermedad crónica...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'local_agent', '02_response');
    });
  });
}
