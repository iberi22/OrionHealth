import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_allergies_page.dart';

void main() {
  testWidgets('OnboardingAllergiesPage data entry', (tester) async {
    Map<String, dynamic>? result;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OnboardingAllergiesPage(
          initialData: const {},
          onNext: (data) => result = data,
        ),
      ),
    ));

    expect(find.text('Allergies'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Peanuts');

    await tester.tap(find.text('Severity').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Severe').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, 'Avoid all nuts');

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(result, isNotNull);
    expect(result!['allergyName'], 'Peanuts');
    expect(result!['allergySeverity'], 'Severe');
    expect(result!['allergyNotes'], 'Avoid all nuts');
  });
}
