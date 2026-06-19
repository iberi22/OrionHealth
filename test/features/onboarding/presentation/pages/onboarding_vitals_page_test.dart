import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_vitals_page.dart';

void main() {
  testWidgets('OnboardingVitalsPage validation and data entry', (tester) async {
    Map<String, dynamic>? result;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OnboardingVitalsPage(
          initialData: const {},
          onNext: (data) => result = data,
        ),
      ),
    ));

    expect(find.text('Baseline Vitals'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Required'), findsNWidgets(5));

    await tester.enterText(find.byType(TextFormField).at(0), '70'); // Weight
    await tester.enterText(find.byType(TextFormField).at(1), '175'); // Height
    await tester.enterText(find.byType(TextFormField).at(2), '120'); // Systolic
    await tester.enterText(find.byType(TextFormField).at(3), '80'); // Diastolic
    await tester.enterText(find.byType(TextFormField).at(4), '60'); // Heart rate

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(result, isNotNull);
    expect(result!['weight'], 70.0);
    expect(result!['systolicBP'], 120);
  });
}
