import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_complete_page.dart';

void main() {
  testWidgets('OnboardingCompletePage displays and calls onComplete', (tester) async {
    bool onCompleteCalled = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OnboardingCompletePage(onComplete: () => onCompleteCalled = true),
      ),
    ));

    expect(find.text('Setup Complete!'), findsOneWidget);
    expect(find.text('Go to Dashboard'), findsOneWidget);

    await tester.tap(find.text('Go to Dashboard'));
    await tester.pump();

    expect(onCompleteCalled, isTrue);
  });
}
