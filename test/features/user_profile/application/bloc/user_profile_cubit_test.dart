import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/user_profile/application/bloc/user_profile_cubit.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

class FakeUserProfile extends Fake implements UserProfile {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUserProfile());
  });

  late UserProfileCubit cubit;
  late MockUserProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockUserProfileRepository();
    cubit = UserProfileCubit(mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('UserProfileState', () {
    test('supports value comparisons', () {
      final profile = UserProfile(name: 'Test');
      expect(UserProfileInitial(), equals(UserProfileInitial()));
      expect(UserProfileLoading(), equals(UserProfileLoading()));
      expect(UserProfileLoaded(profile), equals(UserProfileLoaded(profile)));
      expect(UserProfileError('error'), equals(UserProfileError('error')));
    });
  });

  group('UserProfileCubit', () {
    final tProfile = UserProfile(name: 'John Doe', age: 30);

    test('initial state is UserProfileInitial', () {
      expect(cubit.state, equals(UserProfileInitial()));
    });

    group('loadUserProfile', () {
      test('emits [UserProfileLoading, UserProfileLoaded] when repository returns a profile', () async {
        when(() => mockRepository.getUserProfile()).thenAnswer((_) async => tProfile);

        final expected = [
          UserProfileLoading(),
          UserProfileLoaded(tProfile),
        ];

        expectLater(cubit.stream, emitsInOrder(expected));

        await cubit.loadUserProfile();
      });

      test('emits [UserProfileLoading, UserProfileLoaded] with default profile when repository returns null', () async {
        when(() => mockRepository.getUserProfile()).thenAnswer((_) async => null);

        expectLater(
          cubit.stream,
          emitsInOrder([
            UserProfileLoading(),
            predicate<UserProfileLoaded>((state) => state.userProfile.name == null),
          ]),
        );

        await cubit.loadUserProfile();
      });

      test('emits [UserProfileLoading, UserProfileError] when repository throws error', () async {
        when(() => mockRepository.getUserProfile()).thenThrow(Exception('database error'));

        final expected = [
          UserProfileLoading(),
          UserProfileError('Exception: database error'),
        ];

        expectLater(cubit.stream, emitsInOrder(expected));

        await cubit.loadUserProfile();
      });
    });

    group('saveUserProfile', () {
      test('emits [UserProfileLoading, UserProfileLoaded] when save is successful', () async {
        when(() => mockRepository.saveUserProfile(any())).thenAnswer((_) async {});

        final expected = [
          UserProfileLoading(),
          UserProfileLoaded(tProfile),
        ];

        expectLater(cubit.stream, emitsInOrder(expected));

        await cubit.saveUserProfile(tProfile);

        verify(() => mockRepository.saveUserProfile(tProfile)).called(1);
      });

      test('emits [UserProfileLoading, UserProfileError] when save fails', () async {
        when(() => mockRepository.saveUserProfile(any())).thenThrow(Exception('save error'));

        final expected = [
          UserProfileLoading(),
          UserProfileError('Exception: save error'),
        ];

        expectLater(cubit.stream, emitsInOrder(expected));

        await cubit.saveUserProfile(tProfile);
      });
    });
  });
}
