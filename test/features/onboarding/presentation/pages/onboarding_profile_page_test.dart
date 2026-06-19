import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_profile_page.dart';

void main() {
  testWidgets('OnboardingProfilePage form validation', (tester) async {
    Map<String, dynamic>? result;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OnboardingProfilePage(
          initialData: const {},
          onNext: (data) => result = data,
        ),
      ),
    ));

    expect(find.text('Profile Information'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please select'), findsNWidgets(2)); // Sex and Blood Type

    await tester.enterText(find.byType(TextFormField).first, 'John Doe');

    // Select Sex
    await tester.tap(find.text('Sex').last); // Tapping the decoration/field
    await tester.pumpAndSettle();
    await tester.tap(find.text('M').last);
    await tester.pumpAndSettle();

    // Select Blood Type
    await tester.tap(find.text('Blood Type').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('O+').last);
    await tester.pumpAndSettle();

    // Birth date (hard to test exact date picker interaction in unit test without mocks)
    // But we can check that it's required if we added a validator for it (wait, it doesn't have one in the code!)

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(result, isNotNull);
    expect(result!['name'], 'John Doe');
    expect(result!['sex'], 'M');
    expect(result!['bloodType'], 'O+');
  });
}
