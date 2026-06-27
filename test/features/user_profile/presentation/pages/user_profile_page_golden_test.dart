import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/user_profile/application/bloc/user_profile_cubit.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';

class MockUserProfileCubit extends Mock implements UserProfileCubit {}

void main() {
  late MockUserProfileCubit mockUserProfileCubit;

  setUpAll(() {
    final getIt = GetIt.instance;
    mockUserProfileCubit = MockUserProfileCubit();
    getIt.registerFactory<UserProfileCubit>(() => mockUserProfileCubit);
  });

  setUp(() {
    final sampleProfile = UserProfile(
      name: 'Alex Damon',
      email: 'alex.damon@orion.health',
      age: 35,
      bloodType: 'O+',
      medicalConditions: ['E11', 'I10'],
      onboardingCompleted: true,
      allowCloudApi: false,
    );

    when(() => mockUserProfileCubit.state).thenReturn(UserProfileLoaded(sampleProfile));
    when(() => mockUserProfileCubit.loadUserProfile()).thenAnswer((_) async {});
    when(() => mockUserProfileCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('User Profile Page Golden Screenshot', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const UserProfilePage(),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(UserProfilePage),
      matchesGoldenFile("../../../../golden/reference/user_profile_page.png"),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
