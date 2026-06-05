import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/application/onboarding_cubit.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';

void main() {
  late OnboardingCubit cubit;

  setUp(() {
    cubit = OnboardingCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('OnboardingCubit', () {
    test('initial state is OnboardingInitial', () {
      expect(cubit.state, isA<OnboardingInitial>());
    });

    test('startOnboarding emits Loading then InProgress at step 0', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<OnboardingLoading>(),
          isA<OnboardingInProgress>().having((s) => s.currentStep, 'currentStep', 0),
        ]),
      );

      await cubit.startOnboarding();
      await expectation;
    });

    test('resumeOnboarding emits Loading then InProgress at saved step', () async {
      final savedProfile = UserProfile(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        onboardingStep: 2,
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<OnboardingLoading>(),
          isA<OnboardingInProgress>().having((s) => s.currentStep, 'currentStep', 2),
        ]),
      );

      await cubit.resumeOnboarding(savedProfile);
      await expectation;
    });

    test('nextStep from welcome (step 0) to basicInfo (step 1) works without validation', () async {
      await cubit.startOnboarding();

      final expectation = expectLater(
        cubit.stream,
        emits(isA<OnboardingInProgress>().having((s) => s.currentStep, 'currentStep', 1)),
      );

      await cubit.nextStep();
      await expectation;
    });

    group('Validation Logic', () {
      test('nextStep from basicInfo fails if required fields are missing', () async {
        await cubit.startOnboarding();
        await cubit.nextStep(); // Move to basicInfo
        expect((cubit.state as OnboardingInProgress).currentStep, 1);

        // Name is missing
        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<OnboardingError>().having((e) => e.message, 'message', contains('nombre')),
            isA<OnboardingInProgress>(), // Emitted back to restore state
          ]),
        );

        await cubit.nextStep();
        await expectation;
        expect((cubit.state as OnboardingInProgress).currentStep, 1); // Still at step 1
      });

      test('nextStep from basicInfo succeeds if required fields are present', () async {
        await cubit.startOnboarding();
        await cubit.nextStep(); // Move to basicInfo

        await cubit.updateName('John Doe');
        await cubit.updateBirthDate(DateTime(1990, 1, 1));
        await cubit.updateSex('M');

        final expectation = expectLater(
          cubit.stream,
          emits(isA<OnboardingInProgress>().having((s) => s.currentStep, 'currentStep', 2)),
        );

        await cubit.nextStep();
        await expectation;
      });

      test('nextStep from privacy fails if consent is not given', () async {
        await cubit.startOnboarding();
        // Skip to privacy step (5) for testing
        final savedProfile = (cubit.state as OnboardingInProgress).profile.copyWith(
          onboardingStep: 5,
          name: 'John',
          birthDate: DateTime.now(),
          sex: 'M',
        );
        await cubit.resumeOnboarding(savedProfile);

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<OnboardingError>().having((e) => e.message, 'message', contains('privacidad')),
            isA<OnboardingInProgress>(),
          ]),
        );

        await cubit.nextStep();
        await expectation;
        expect((cubit.state as OnboardingInProgress).currentStep, 5);
      });

      test('nextStep from privacy succeeds if consent is given', () async {
        await cubit.startOnboarding();
        final savedProfile = (cubit.state as OnboardingInProgress).profile.copyWith(
          onboardingStep: 5,
          name: 'John',
          birthDate: DateTime.now(),
          sex: 'M',
        );
        await cubit.resumeOnboarding(savedProfile);

        await cubit.acceptPrivacyConsent(consent: true);

        final expectation = expectLater(
          cubit.stream,
          emits(isA<OnboardingInProgress>().having((s) => s.currentStep, 'currentStep', 6)),
        );

        await cubit.nextStep();
        await expectation;
      });
    });

    group('Navigation logic', () {
      test('previousStep decrements step in OnboardingInProgress', () async {
        await cubit.startOnboarding();
        await cubit.nextStep(); // welcome -> basicInfo (step 1)

        final expectation = expectLater(
          cubit.stream,
          emits(isA<OnboardingInProgress>().having((s) => s.currentStep, 'currentStep', 0)),
        );

        await cubit.previousStep();
        await expectation;
      });

      test('skipOnboarding emits OnboardingCompleted', () async {
        await cubit.startOnboarding();

        final expectation = expectLater(
          cubit.stream,
          emits(isA<OnboardingCompleted>().having((s) => s.profile.onboardingCompleted, 'completed', true)),
        );

        await cubit.skipOnboarding();
        await expectation;
      });
    });

    test('updateBasicInfo updates profile and sets step to basicInfo', () async {
      await cubit.startOnboarding();

      final birthDate = DateTime(1990, 1, 1);
      await cubit.updateBasicInfo(
        name: 'John Doe',
        birthDate: birthDate,
        sex: 'M',
        weightKg: 80,
        heightCm: 180,
      );

      final state = cubit.state as OnboardingInProgress;
      expect(state.profile.name, 'John Doe');
      expect(state.profile.sex, 'M');
      expect(state.profile.weightKg, 80);
      expect(state.profile.heightCm, 180);
      expect(state.currentStep, OnboardingStep.basicInfo.index);
    });

    test('completeOnboarding emits syncing states then Completed', () async {
      await cubit.startOnboarding();

      final expectation = expectLater(
        cubit.stream,
        emitsThrough(isA<OnboardingCompleted>()),
      );

      await cubit.completeOnboarding();
      await expectation;

      expect(cubit.state, isA<OnboardingCompleted>());
      expect((cubit.state as OnboardingCompleted).profile.onboardingCompleted, true);
    });
  });
}
