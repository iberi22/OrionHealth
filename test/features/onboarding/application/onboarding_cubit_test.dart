import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/onboarding/application/onboarding_cubit.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/onboarding/domain/repositories/onboarding_repository.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late OnboardingCubit cubit;
  late MockOnboardingRepository mockRepository;

  setUp(() {
    mockRepository = MockOnboardingRepository();
    registerFallbackValue(UserProfile(createdAt: DateTime.now(), updatedAt: DateTime.now()));

    when(() => mockRepository.getOnboardingProfile()).thenAnswer((_) async => null);
    when(() => mockRepository.saveOnboardingProfile(any())).thenAnswer((_) async {});
    when(() => mockRepository.completeOnboarding(any())).thenAnswer((_) async {});
    when(() => mockRepository.resetOnboarding()).thenAnswer((_) async {});

    cubit = OnboardingCubit(mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('OnboardingCubit', () {
    test('initial state is OnboardingInitial', () {
      expect(cubit.state, isA<OnboardingInitial>());
    });

    test('startOnboarding emits Loading then InProgress at step 0 when no saved profile', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<OnboardingLoading>(),
          isA<OnboardingInProgress>().having((s) => s.currentStep, 'currentStep', 0),
        ]),
      );

      await cubit.startOnboarding();
      await expectation;
      verify(() => mockRepository.saveOnboardingProfile(any())).called(1);
    });

    test('startOnboarding resumes from saved profile if exists', () async {
      final savedProfile = UserProfile(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        onboardingStep: 2,
      );
      when(() => mockRepository.getOnboardingProfile()).thenAnswer((_) async => savedProfile);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<OnboardingLoading>(),
          isA<OnboardingInProgress>().having((s) => s.currentStep, 'currentStep', 2),
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
      verify(() => mockRepository.saveOnboardingProfile(any())).called(greaterThan(0));
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
    });

    test('completeOnboarding emits syncing states then Completed and calls repository', () async {
      await cubit.startOnboarding();

      final expectation = expectLater(
        cubit.stream,
        emitsThrough(isA<OnboardingCompleted>()),
      );

      await cubit.completeOnboarding();
      await expectation;

      expect(cubit.state, isA<OnboardingCompleted>());
      expect((cubit.state as OnboardingCompleted).profile.onboardingCompleted, true);
      verify(() => mockRepository.completeOnboarding(any())).called(1);
    });

    test('reset calls repository reset and emits OnboardingInitial', () async {
      await cubit.startOnboarding();
      cubit.reset();
      expect(cubit.state, isA<OnboardingInitial>());
      verify(() => mockRepository.resetOnboarding()).called(1);
    });
  });
}
