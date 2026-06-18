import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/onboarding/application/onboarding_cubit.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/basic_info_step.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_cubit.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';

class MockOnboardingCubit extends Mock implements OnboardingCubit {}
class MockEpsConnectionCubit extends Mock implements EpsConnectionCubit {}

void main() {
  late MockOnboardingCubit mockOnboardingCubit;
  late MockEpsConnectionCubit mockEpsConnectionCubit;

  setUpAll(() {
    getIt.allowReassignment = true;
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockOnboardingCubit = MockOnboardingCubit();
    mockEpsConnectionCubit = MockEpsConnectionCubit();

    if (getIt.isRegistered<EpsConnectionCubit>()) {
      getIt.unregister<EpsConnectionCubit>();
    }
    getIt.registerSingleton<EpsConnectionCubit>(mockEpsConnectionCubit);

    final now = DateTime.now();
    final profile = UserProfile(createdAt: now, updatedAt: now);

    when(() => mockOnboardingCubit.state).thenReturn(OnboardingInProgress(
      currentStep: 1,
      totalSteps: 7,
      profile: profile,
    ));
    when(() => mockOnboardingCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockOnboardingCubit.currentStep).thenReturn(1);

    when(() => mockEpsConnectionCubit.state).thenReturn(const EpsConnectionInitial());
    when(() => mockEpsConnectionCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockOnboardingCubit.updateName(any())).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<OnboardingCubit>.value(
        value: mockOnboardingCubit,
        child: const Scaffold(
          body: BasicInfoStep(),
        ),
      ),
    );
  }

  testWidgets('BasicInfoStep displays initial state', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    expect(find.text('Información Personal'), findsOneWidget);
  });
}
