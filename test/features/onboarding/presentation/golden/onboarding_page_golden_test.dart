import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/onboarding/application/onboarding_cubit.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_page.dart';
import '../../../../core/golden_test_utils.dart';

class MockOnboardingCubit extends Mock implements OnboardingCubit {}

void main() {
  late MockOnboardingCubit mockOnboardingCubit;
  late UserProfile sampleProfile;

  setUp(() {
    mockOnboardingCubit = MockOnboardingCubit();
    final now = DateTime(2023, 1, 1);
    sampleProfile = UserProfile(
      name: 'Test User',
      onboardingCompleted: false,
      onboardingStep: 0,
      createdAt: now,
      updatedAt: now,
    );
    when(() => mockOnboardingCubit.startOnboarding()).thenAnswer((_) async {});
    when(() => mockOnboardingCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createOnboardingPage(int step) {
    when(() => mockOnboardingCubit.state).thenReturn(
      OnboardingInProgress(
        currentStep: step,
        totalSteps: 7,
        profile: sampleProfile.copyWith(onboardingStep: step),
      ),
    );
    when(() => mockOnboardingCubit.currentStep).thenReturn(step);

    return BlocProvider<OnboardingCubit>.value(
      value: mockOnboardingCubit,
      child: const OnboardingPage(),
    );
  }

  group('Onboarding Page Golden Tests', () {
    final steps = [
      'Welcome',
      'Basic Info',
      'Conditions',
      'Family History',
      'Medications',
      'Privacy',
      'Complete',
    ];

    for (int i = 0; i < steps.length; i++) {
      testWidgets('Onboarding Step $i - ${steps[i]}', (WidgetTester tester) async {
        setupGoldenTest(tester);

        await tester.pumpWidget(wrapWithMaterial(createOnboardingPage(i)));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(OnboardingPage),
          matchesGoldenFile("goldens/onboarding_step_$i.png"),
        );

        resetGoldenTest(tester);
      });
    }
  });
}
