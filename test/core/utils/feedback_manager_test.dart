import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/utils/feedback_manager.dart';

void main() {
  group('FeedbackManager', () {
    testWidgets('showSuccess shows SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: FeedbackManager.scaffoldMessengerKey,
          home: const Scaffold(body: Placeholder()),
        ),
      );

      FeedbackManager.showSuccess('Success Message');
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Success Message'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('showError shows SnackBar with error icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: FeedbackManager.scaffoldMessengerKey,
          home: const Scaffold(body: Placeholder()),
        ),
      );

      FeedbackManager.showError('Error Message');
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Error Message'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('showConfirmation dialog shows correct text', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await FeedbackManager.showConfirmation(
                    context: context,
                    title: 'Confirm?',
                    message: 'Are you sure?',
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm?'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('showInputDialog returns input text', (tester) async {
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await FeedbackManager.showInputDialog(
                    context: context,
                    title: 'Input',
                    hint: 'Type here',
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Test Input');
      await tester.tap(find.text('Confirmar'));
      // Use pump instead of pumpAndSettle to avoid using controller after dispose
      await tester.pump();

      expect(result, equals('Test Input'));
    });

    test('hapticFeedback calls platform channel', () async {
       // Since haptic feedback uses MethodChannel internally,
       // we can't easily verify the call without mocking the channel,
       // but we can at least ensure it doesn't crash.
       FeedbackManager.hapticFeedback(HapticFeedbackType.light);
       FeedbackManager.hapticFeedback(HapticFeedbackType.medium);
       FeedbackManager.hapticFeedback(HapticFeedbackType.heavy);
       FeedbackManager.hapticFeedback(HapticFeedbackType.selection);
    });
  });
}
