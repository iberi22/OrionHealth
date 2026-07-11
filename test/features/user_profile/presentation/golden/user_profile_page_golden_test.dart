import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:orionhealth_health/features/user_profile/application/bloc/user_profile_cubit.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import '../../../../core/golden_test_utils.dart';

class MockUserProfileCubit extends Mock implements UserProfileCubit {}

void main() {
  late MockUserProfileCubit mockCubit;

  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  setUp(() async {
    mockCubit = MockUserProfileCubit();
    await GetIt.I.reset();
    GetIt.I.registerFactory<UserProfileCubit>(() => mockCubit);

    when(() => mockCubit.loadUserProfile()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('User Profile Page Golden Tests', () {
    testWidgets('User Profile Page - Loaded', (tester) async {
      setupGoldenTest(tester);

      final profile = UserProfile(
        name: 'Alex Damon',
        email: 'alex.damon@orion.health',
        phoneNumber: '+1 (555) 123-4567',
        birthDate: DateTime(1988, 8, 15),
        bloodType: 'O+',
        allowCloudApi: true,
      );

      when(() => mockCubit.state).thenReturn(UserProfileLoaded(profile));
      when(() => mockCubit.stream).thenAnswer((_) => Stream.fromIterable([UserProfileLoaded(profile)]));

      await tester.pumpWidget(wrapWithMaterial(const UserProfilePage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(UserProfilePage),
        matchesGoldenFile("goldens/user_profile_page_loaded.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('User Profile Page - Loading', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(UserProfileLoading());
      when(() => mockCubit.stream).thenAnswer((_) => Stream.fromIterable([UserProfileLoading()]));

      await tester.pumpWidget(wrapWithMaterial(const UserProfilePage()));
      // We don't pumpAndSettle here because it's an infinite animation
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(UserProfilePage),
        matchesGoldenFile("goldens/user_profile_page_loading.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('User Profile Page - Error', (tester) async {
      setupGoldenTest(tester);

      const state = UserProfileError('Error al conectar con el servidor de perfil');

      when(() => mockCubit.state).thenReturn(state);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));

      await tester.pumpWidget(wrapWithMaterial(const UserProfilePage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(UserProfilePage),
        matchesGoldenFile("goldens/user_profile_page_error.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
