import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/application/onboarding_cubit.dart';

void main() {
  group('OnboardingStep', () {
    test('fromIndex returns correct step for valid indices', () {
      expect(OnboardingStep.fromIndex(0), OnboardingStep.welcome);
      expect(OnboardingStep.fromIndex(1), OnboardingStep.basicInfo);
      expect(OnboardingStep.fromIndex(2), OnboardingStep.conditions);
      expect(OnboardingStep.fromIndex(3), OnboardingStep.familyHistory);
      expect(OnboardingStep.fromIndex(4), OnboardingStep.medications);
      expect(OnboardingStep.fromIndex(5), OnboardingStep.privacy);
      expect(OnboardingStep.fromIndex(6), OnboardingStep.complete);
    });

    test('fromIndex returns welcome for invalid indices', () {
      expect(OnboardingStep.fromIndex(-1), OnboardingStep.welcome);
      expect(OnboardingStep.fromIndex(7), OnboardingStep.welcome);
      expect(OnboardingStep.fromIndex(100), OnboardingStep.welcome);
    });

    test('OnboardingStep values have correct titles and indices', () {
      expect(OnboardingStep.welcome.stepIndex, 0);
      expect(OnboardingStep.welcome.title, 'Bienvenida');

      expect(OnboardingStep.basicInfo.stepIndex, 1);
      expect(OnboardingStep.basicInfo.title, 'Datos Personales');

      expect(OnboardingStep.conditions.stepIndex, 2);
      expect(OnboardingStep.conditions.title, 'Condiciones');

      expect(OnboardingStep.complete.stepIndex, 6);
      expect(OnboardingStep.complete.title, 'Completado');
    });
  });
}
