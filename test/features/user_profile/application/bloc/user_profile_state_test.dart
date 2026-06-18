import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/application/bloc/user_profile_cubit.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';

void main() {
  group('UserProfileState', () {
    group('UserProfileInitial', () {
      test('supports value equality', () {
        expect(const UserProfileInitial(), equals(const UserProfileInitial()));
      });
      test('props are empty', () {
        expect(const UserProfileInitial().props, []);
      });
    });

    group('UserProfileLoading', () {
      test('supports value equality', () {
        expect(const UserProfileLoading(), equals(const UserProfileLoading()));
      });
      test('props are empty', () {
        expect(const UserProfileLoading().props, []);
      });
    });

    group('UserProfileLoaded', () {
      final profile = UserProfile(
      );

      test('supports value equality', () {
        expect(UserProfileLoaded(profile), equals(UserProfileLoaded(profile)));
      });

      test('props are correct', () {
        expect(UserProfileLoaded(profile).props, [profile]);
      });
    });

    group('UserProfileError', () {
      test('supports value equality', () {
        expect(
          const UserProfileError('err'),
          equals(const UserProfileError('err')),
        );
      });
      test('different messages are not equal', () {
        expect(
          const UserProfileError('err1'),
          isNot(equals(const UserProfileError('err2'))),
        );
      });
      test('props contain message', () {
        expect(const UserProfileError('err').props, ['err']);
      });
    });
  });
}
