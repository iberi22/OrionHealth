import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/services/user_profile_service.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

// Fallback for mocktail
class UserProfileFake extends Fake implements UserProfile {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserProfileFake());
  });

  late UserProfileService service;
  late MockUserProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockUserProfileRepository();
    service = UserProfileService(mockRepository);
  });

  group('UserProfileService', () {
    final tProfile = UserProfile(name: 'John Doe', age: 30);

    test('getProfile should return profile from repository', () async {
      when(() => mockRepository.getUserProfile()).thenAnswer((_) async => tProfile);

      final result = await service.getProfile();

      expect(result, equals(tProfile));
      verify(() => mockRepository.getUserProfile()).called(1);
    });

    test('updateProfile should save profile when valid', () async {
      when(() => mockRepository.saveUserProfile(any())).thenAnswer((_) async {});

      await service.updateProfile(tProfile);

      verify(() => mockRepository.saveUserProfile(tProfile)).called(1);
    });

    test('updateProfile should save empty profile (default is valid)', () async {
      final emptyProfile = UserProfile();
      when(() => mockRepository.saveUserProfile(any())).thenAnswer((_) async {});

      await service.updateProfile(emptyProfile);

      verify(() => mockRepository.saveUserProfile(emptyProfile)).called(1);
    });

    test('updateProfile should throw exception when profile is invalid', () async {
      final invalidProfile = UserProfile(age: -1);

      expect(() => service.updateProfile(invalidProfile), throwsException);
      verifyNever(() => mockRepository.saveUserProfile(any()));
    });

    test('deleteProfile should call repository delete', () async {
      when(() => mockRepository.deleteUserProfile()).thenAnswer((_) async {});

      await service.deleteProfile();

      verify(() => mockRepository.deleteUserProfile()).called(1);
    });
  });
}
