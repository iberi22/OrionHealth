import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:orionhealth_health/features/user_profile/application/bloc/user_profile_cubit.dart';
import '../../../../core/golden_test_utils.dart';

class MockUserProfileCubit extends Mock implements UserProfileCubit {}

void main() {
  late MockUserProfileCubit mockUserProfileCubit;

  setUp(() {
    mockUserProfileCubit = MockUserProfileCubit();
    GetIt.I.registerFactory<UserProfileCubit>(() => mockUserProfileCubit);

    when(() => mockUserProfileCubit.loadUserProfile()).thenAnswer((_) async => {});
    when(() => mockUserProfileCubit.close()).thenAnswer((_) async => {});
    when(() => mockUserProfileCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('UserProfilePage States Golden Tests', () {
    testWidgets('Loading State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockUserProfileCubit.state).thenReturn(const UserProfileLoading());

      await tester.pumpWidget(wrapWithMaterial(const UserProfilePage()));
      // Pump once for the loading indicator
      await tester.pump();

      await expectLater(
        find.byType(UserProfilePage),
        matchesGoldenFile("../../../../../golden/reference/user_profile_page_loading.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Error State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockUserProfileCubit.state).thenReturn(const UserProfileError('Failed to load profile'));

      await tester.pumpWidget(wrapWithMaterial(const UserProfilePage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(UserProfilePage),
        matchesGoldenFile("../../../../../golden/reference/user_profile_page_error.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
