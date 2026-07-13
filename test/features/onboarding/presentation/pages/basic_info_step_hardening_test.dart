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

    // Mocking a cubit for the 'close' call
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
    // Force getIt to throw an error when EpsConnectionCubit is requested
    if (getIt.isRegistered<EpsConnectionCubit>()) {
      getIt.unregister<EpsConnectionCubit>();
    }
    // We can't easily make getIt throw on a specific type without registering a factory that throws
    getIt.registerFactory<EpsConnectionCubit>(() => throw Exception('DI Error'));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Conexión EPS no disponible'), findsOneWidget);
    expect(find.text('No pudimos inicializar la conexión. Puedes continuar sin ella.'), findsOneWidget);
    expect(find.byIcon(Icons.link_off), findsOneWidget);
  });
}
