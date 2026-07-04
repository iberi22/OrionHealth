import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:orionhealth_health/features/user_profile/application/bloc/user_profile_cubit.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
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

  group('UserProfilePage Responsive Golden Tests', () {
    testWidgets('Tablet View', (tester) async {
      // Set tablet-like resolution
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;

      final profile = UserProfile(
        name: 'Jane Doe',
        email: 'jane.doe@example.com',
        allowCloudApi: true,
      );

      when(() => mockUserProfileCubit.state).thenReturn(UserProfileLoaded(profile));

      await tester.pumpWidget(wrapWithMaterial(const UserProfilePage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(UserProfilePage),
        matchesGoldenFile("../../../../../golden/reference/user_profile_page_tablet.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
