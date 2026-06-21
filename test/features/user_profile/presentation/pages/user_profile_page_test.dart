import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/user_profile/application/bloc/user_profile_cubit.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockUserProfileCubit extends Mock implements UserProfileCubit {}

class FakeUserProfile extends Fake implements UserProfile {}

void main() {
  late MockUserProfileCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(FakeUserProfile());
  });

  setUp(() {
    mockCubit = MockUserProfileCubit();

    // Setup getIt
    getIt.allowReassignment = true;
    getIt.registerSingleton<UserProfileCubit>(mockCubit);

    when(() => mockCubit.loadUserProfile()).thenAnswer((_) async {});
    when(() => mockCubit.state).thenReturn(UserProfileInitial());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const UserProfilePage(),
    );
  }

  group('UserProfilePage', () {
    testWidgets('shows loading indicator when state is UserProfileLoading', (tester) async {
      when(() => mockCubit.state).thenReturn(UserProfileLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows profile data when state is UserProfileLoaded', (tester) async {
      final profile = UserProfile(name: 'Test User');
      when(() => mockCubit.state).thenReturn(UserProfileLoaded(profile));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Test User'), findsWidgets);
    });

    testWidgets('shows error message when state is UserProfileError', (tester) async {
      when(() => mockCubit.state).thenReturn(const UserProfileError('Something went wrong'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.textContaining('Something went wrong'), findsOneWidget);
    });

    testWidgets('calls saveUserProfile when Save Changes button is pressed', (tester) async {
      final profile = UserProfile(name: 'Test User');
      when(() => mockCubit.state).thenReturn(UserProfileLoaded(profile));
      when(() => mockCubit.saveUserProfile(any())).thenAnswer((_) async {});

      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final saveButton = find.byType(ElevatedButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      verify(() => mockCubit.saveUserProfile(any())).called(1);
    });

    testWidgets('toggles allowCloudApi when Switch is changed', (tester) async {
      final profile = UserProfile(name: 'Test User', allowCloudApi: true);
      when(() => mockCubit.state).thenReturn(UserProfileLoaded(profile));
      when(() => mockCubit.saveUserProfile(any())).thenAnswer((_) async {});

      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final switchFinder = find.byType(Switch);
      await tester.tap(switchFinder.last);
      await tester.pumpAndSettle();

      verify(() => mockCubit.saveUserProfile(any())).called(1);
    });
  });
}
