import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/onboarding/application/onboarding_cubit.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class MockOnboardingCubit extends Mock implements OnboardingCubit {}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  late MockOnboardingCubit mockOnboardingCubit;
  late UserProfile sampleProfile;

  setUp(() {
    mockOnboardingCubit = MockOnboardingCubit();
    final now = DateTime.now();
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

    return MaterialApp(
      theme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: BlocProvider<OnboardingCubit>.value(
        value: mockOnboardingCubit,
        child: const OnboardingPage(),
      ),
    );
  }

  group('Onboarding Page Golden Screenshots', () {
    for (int i = 0; i < 7; i++) {
      testWidgets('Onboarding Step $i', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createOnboardingPage(i));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(OnboardingPage),
          matchesGoldenFile('../../../../goldens/onboarding_step_$i.png'),
        );

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
      });
    }
  });
}
