import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_main_page.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  late MockUserProfileRepository mockRepo;

  setUpAll(() {
    mockRepo = MockUserProfileRepository();
    getIt.registerSingleton<UserProfileRepository>(mockRepo);
  });

  tearDownAll(() {
    getIt.unregister<UserProfileRepository>();
  });

  testWidgets('OnboardingMainPage navigates through steps', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OnboardingMainPage(onFinish: () {}),
    ));

    // Step 0: Welcome
    expect(find.text('Privacy First'), findsOneWidget);
    await tester.tap(find.text('Next')); await tester.pumpAndSettle();
    await tester.tap(find.text('Next')); await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started')); await tester.pumpAndSettle();

    // Step 1: Profile
    expect(find.text('Step 2 of 5'), findsOneWidget);

    // Test back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Privacy First'), findsOneWidget); // It should go back to first slide of welcome or first page?
    // OnboardingWelcomePage is step 0.
  });
}
