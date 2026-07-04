import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/onboarding/application/onboarding_cubit.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/welcome_step.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/basic_info_step.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/conditions_step.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/family_history_step.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/medications_step.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/privacy_step.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/complete_step.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_cubit.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';
import '../../../../core/golden_test_utils.dart';

class MockOnboardingCubit extends Mock implements OnboardingCubit {}
class MockEpsConnectionCubit extends Mock implements EpsConnectionCubit {}

void main() {
  late MockOnboardingCubit mockCubit;
  late MockEpsConnectionCubit mockEpsCubit;
  late UserProfile sampleProfile;

  setUpAll(() {
    registerFallbackValue(const EpsConnectionInitial());
    mockEpsCubit = MockEpsConnectionCubit();
    when(() => mockEpsCubit.state).thenReturn(const EpsConnectionInitial());
    when(() => mockEpsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockEpsCubit.close()).thenAnswer((_) async {});

    GetIt.I.allowReassignment = true;
    GetIt.I.registerSingleton<EpsConnectionCubit>(mockEpsCubit);
  });

  setUp(() {
    mockCubit = MockOnboardingCubit();
    sampleProfile = UserProfile(
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
      onboardingStep: 0,
    );
    when(() => mockCubit.state).thenReturn(OnboardingInProgress(
      currentStep: 0,
      totalSteps: 7,
      profile: sampleProfile,
    ));
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget wrapWithCubit(Widget child) {
    return BlocProvider<OnboardingCubit>.value(
      value: mockCubit,
      child: wrapWithMaterial(child),
    );
  }

  group('Onboarding Steps Golden Tests', () {
    testWidgets('WelcomeStep', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithCubit(const WelcomeStep()));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(WelcomeStep),
        matchesGoldenFile("../../../../../golden/reference/step_welcome.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('BasicInfoStep', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithCubit(const BasicInfoStep()));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BasicInfoStep),
        matchesGoldenFile("../../../../../golden/reference/step_basic_info.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ConditionsStep', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithCubit(const ConditionsStep()));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ConditionsStep),
        matchesGoldenFile("../../../../../golden/reference/step_conditions.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('FamilyHistoryStep', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithCubit(const FamilyHistoryStep()));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(FamilyHistoryStep),
        matchesGoldenFile("../../../../../golden/reference/step_family_history.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('MedicationsStep', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithCubit(const MedicationsStep()));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MedicationsStep),
        matchesGoldenFile("../../../../../golden/reference/step_medications.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('PrivacyStep', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithCubit(const PrivacyStep()));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(PrivacyStep),
        matchesGoldenFile("../../../../../golden/reference/step_privacy.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('CompleteStep', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithCubit(const CompleteStep()));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(CompleteStep),
        matchesGoldenFile("../../../../../golden/reference/step_complete.png"),
      );
      resetGoldenTest(tester);
    });
  });

  group('Onboarding Steps (Advanced States) Golden Tests', () {
    testWidgets('BasicInfoStep with Data', (tester) async {
      when(() => mockCubit.state).thenReturn(OnboardingInProgress(
        currentStep: 1,
        totalSteps: 7,
        profile: sampleProfile.copyWith(
          name: 'Jane Doe',
          sex: 'F',
          weightKg: 65,
          heightCm: 170,
        ),
      ));
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithCubit(const BasicInfoStep()));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(BasicInfoStep),
        matchesGoldenFile("../../../../../golden/reference/step_basic_info_filled.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
