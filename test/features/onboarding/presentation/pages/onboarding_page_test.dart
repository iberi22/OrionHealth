import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/onboarding/application/onboarding_cubit.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_cubit.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';
import 'package:orionhealth_health/features/home/presentation/pages/main_navigation_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'dart:async';

import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/features/user_profile/application/bloc/user_profile_cubit.dart';

class MockOnboardingCubit extends Mock implements OnboardingCubit {}
class MockEpsConnectionCubit extends Mock implements EpsConnectionCubit {}
class MockHomeCubit extends Mock implements HomeCubit {}
class MockUserProfileCubit extends Mock implements UserProfileCubit {}
class _MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockOnboardingCubit mockOnboardingCubit;
  late MockEpsConnectionCubit mockEpsConnectionCubit;
  late MockHomeCubit mockHomeCubit;
  late MockUserProfileCubit mockUserProfileCubit;
  late StreamController<OnboardingState> onboardingStreamController;

  setUpAll(() {
    getIt.allowReassignment = true;
    registerFallbackValue(MaterialPageRoute(builder: (_) => Container()));
  });

  setUp(() {
    mockOnboardingCubit = MockOnboardingCubit();
    mockEpsConnectionCubit = MockEpsConnectionCubit();
    mockHomeCubit = MockHomeCubit();
    mockUserProfileCubit = MockUserProfileCubit();
    onboardingStreamController = StreamController<OnboardingState>.broadcast();

    if (getIt.isRegistered<EpsConnectionCubit>()) {
      getIt.unregister<EpsConnectionCubit>();
    }
    getIt.registerSingleton<EpsConnectionCubit>(mockEpsConnectionCubit);

    if (getIt.isRegistered<HomeCubit>()) {
      getIt.unregister<HomeCubit>();
    }
    getIt.registerSingleton<HomeCubit>(mockHomeCubit);

    if (getIt.isRegistered<UserProfileCubit>()) {
      getIt.unregister<UserProfileCubit>();
    }
    getIt.registerSingleton<UserProfileCubit>(mockUserProfileCubit);

    final now = DateTime.now();
    final profile = UserProfile(createdAt: now, updatedAt: now);

    when(() => mockOnboardingCubit.state).thenReturn(OnboardingInProgress(
      currentStep: 0,
      totalSteps: 7,
      profile: profile,
    ));
    when(() => mockOnboardingCubit.stream).thenAnswer((_) => onboardingStreamController.stream);
    when(() => mockOnboardingCubit.currentStep).thenReturn(0);
    when(() => mockOnboardingCubit.startOnboarding()).thenAnswer((_) async {});

    when(() => mockEpsConnectionCubit.state).thenReturn(const EpsConnectionInitial());
    when(() => mockEpsConnectionCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockHomeCubit.state).thenReturn(const HomeState());
    when(() => mockHomeCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHomeCubit.loadDashboard()).thenAnswer((_) async {});

    when(() => mockUserProfileCubit.state).thenReturn(UserProfileInitial());
    when(() => mockUserProfileCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUserProfileCubit.loadUserProfile()).thenAnswer((_) async {});
  });

  tearDown(() {
    onboardingStreamController.close();
  });

  Widget createWidgetUnderTest({NavigatorObserver? observer}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      navigatorObservers: observer != null ? [observer] : [],
      home: BlocProvider<OnboardingCubit>.value(
        value: mockOnboardingCubit,
        child: const OnboardingPage(),
      ),
    );
  }

  testWidgets('OnboardingPage starts onboarding on init', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    verify(() => mockOnboardingCubit.startOnboarding()).called(1);
  });

  testWidgets('OnboardingPage displays correct step and progress', (tester) async {
    when(() => mockOnboardingCubit.currentStep).thenReturn(2);
    when(() => mockOnboardingCubit.state).thenReturn(OnboardingInProgress(
      currentStep: 2,
      totalSteps: 7,
      profile: UserProfile(createdAt: DateTime.now(), updatedAt: DateTime.now()),
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Paso 3 de 7'), findsOneWidget);
    // LinearProgressIndicator value should be (2+1)/7 = 3/7 ≈ 0.428
    final progressIndicator = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(progressIndicator.value, closeTo(3 / 7, 0.01));
  });

  testWidgets('OnboardingPage navigates when cubit state changes', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Paso 1 de 7'), findsOneWidget);

    final nextProfile = UserProfile(createdAt: DateTime.now(), updatedAt: DateTime.now());
    when(() => mockOnboardingCubit.currentStep).thenReturn(1);
    onboardingStreamController.add(OnboardingInProgress(
      currentStep: 1,
      totalSteps: 7,
      profile: nextProfile,
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Paso 2 de 7'), findsOneWidget);
  });

  testWidgets('OnboardingPage shows error snackbar on OnboardingError state', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    onboardingStreamController.add(const OnboardingError(message: 'Test Error'));
    await tester.pumpAndSettle();

    expect(find.text('Test Error'), findsOneWidget);
  });

  testWidgets('OnboardingPage navigates to MainNavigationPage on OnboardingCompleted', (tester) async {
    final mockObserver = _MockNavigatorObserver();
    await tester.pumpWidget(createWidgetUnderTest(observer: mockObserver));

    onboardingStreamController.add(OnboardingCompleted(
      profile: UserProfile(createdAt: DateTime.now(), updatedAt: DateTime.now()),
    ));
    await tester.pump();

    verify(() => mockObserver.didReplace(
      newRoute: any(named: 'newRoute'),
      oldRoute: any(named: 'oldRoute'),
    )).called(1);
  });

  testWidgets('Back button calls previousStep on cubit', (tester) async {
    when(() => mockOnboardingCubit.currentStep).thenReturn(1);
    when(() => mockOnboardingCubit.state).thenReturn(OnboardingInProgress(
      currentStep: 1,
      totalSteps: 7,
      profile: UserProfile(createdAt: DateTime.now(), updatedAt: DateTime.now()),
    ));
    when(() => mockOnboardingCubit.previousStep()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final backButton = find.byType(IconButton);
    expect(backButton, findsOneWidget);

    // We use a gesture to tap to avoid RawTooltip issue in some environments
    await tester.tap(backButton, warnIfMissed: false);
    await tester.pump(); // Added pump to let gesture settle
    verify(() => mockOnboardingCubit.previousStep()).called(1);
  });

  testWidgets('Back button is not shown on first step', (tester) async {
    when(() => mockOnboardingCubit.currentStep).thenReturn(0);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });
}
