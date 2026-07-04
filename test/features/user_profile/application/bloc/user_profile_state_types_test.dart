import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/application/bloc/user_profile_cubit.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';

void main() {
  group('UserProfileState Types', () {
    test('UserProfileInitial is a UserProfileState', () {
      expect(const UserProfileInitial(), isA<UserProfileState>());
    });

    test('UserProfileLoading is a UserProfileState', () {
      expect(const UserProfileLoading(), isA<UserProfileState>());
    });

    test('UserProfileLoaded is a UserProfileState', () {
      final profile = UserProfile(
        name: 'N',
        email: 'E',
        birthDate: DateTime(2000),
        sex: 'M',
      );
      expect(UserProfileLoaded(profile), isA<UserProfileState>());
    });

    test('UserProfileError is a UserProfileState', () {
      expect(const UserProfileError('error'), isA<UserProfileState>());
    });
  });
}
