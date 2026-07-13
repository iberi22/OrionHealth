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

class MockOnboardingCubit extends Mock implements OnboardingCubit {}
class MockEpsConnectionCubit extends Mock implements EpsConnectionCubit {}

void main() {
  late MockOnboardingCubit mockOnboardingCubit;

  setUpAll(() {
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockOnboardingCubit = MockOnboardingCubit();

    final mockEpsCubit = MockEpsConnectionCubit();
    when(() => mockEpsCubit.close()).thenAnswer((_) async {});

    final now = DateTime.now();
    final profile = UserProfile(createdAt: now, updatedAt: now);

    when(() => mockOnboardingCubit.state).thenReturn(OnboardingInProgress(
      currentStep: 1,
      totalSteps: 7,
      profile: profile,
    ));
    when(() => mockOnboardingCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockOnboardingCubit.currentStep).thenReturn(1);
  });

  tearDown(() {
    if (getIt.isRegistered<EpsConnectionCubit>()) {
      getIt.unregister<EpsConnectionCubit>();
    }
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

  testWidgets('BasicInfoStep displays fallback UI when EpsConnectionCubit initialization fails', (tester) async {
    // Force getIt to throw when EpsConnectionCubit is requested
    if (getIt.isRegistered<EpsConnectionCubit>()) {
      getIt.unregister<EpsConnectionCubit>();
    }
    getIt.registerFactory<EpsConnectionCubit>(() => throw Exception('DI Error'));

    // The exception in initState is caught by our try/catch.
    // Flutter framework may also log a ListTile+DecoratedBox warning
    // but that's a cosmetic issue, not a test failure.
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Verify the fallback UI rendered: EPS not available card
    expect(find.text('Conexión EPS no disponible'), findsOneWidget);
    expect(find.byIcon(Icons.link_off), findsOneWidget);
  });
}
