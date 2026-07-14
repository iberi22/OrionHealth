import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_welcome_page.dart';

void main() {
  testWidgets('OnboardingWelcomePage slides through content', (tester) async {
    bool onNextCalled = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OnboardingWelcomePage(
          onNext: () => onNextCalled = true,
          onEpsDataReceived: (_) {},
        ),
      ),
    ));

    expect(find.text('Privacy First'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Local AI'), findsOneWidget);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Own Your Data'), findsOneWidget);
    expect(find.text('Continuar sin EPS'), findsOneWidget);

    await tester.tap(find.text('Continuar sin EPS'));
    await tester.pump();

    expect(onNextCalled, isTrue);
  });
}
