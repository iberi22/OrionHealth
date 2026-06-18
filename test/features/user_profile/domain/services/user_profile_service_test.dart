import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/services/user_profile_service.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  late MockUserProfileRepository mockRepository;
  late UserProfileService service;

  setUpAll(() {
    registerFallbackValue(UserProfile());
  });

  setUp(() {
    mockRepository = MockUserProfileRepository();
    service = UserProfileService(mockRepository);
  });

  group('UserProfileService', () {
    final profile = UserProfile(
      name: 'Juan Perez',
      birthDate: DateTime(1990, 5, 15),
    );

    test('getProfile returns profile from repository', () async {
      when(
        () => mockRepository.getUserProfile(),
      ).thenAnswer((_) async => profile);
      final result = await service.getProfile();
      expect(result, equals(profile));
      verify(() => mockRepository.getUserProfile()).called(1);
    });

    test('getProfile returns null when no profile', () async {
      when(() => mockRepository.getUserProfile()).thenAnswer((_) async => null);
      final result = await service.getProfile();
      expect(result, isNull);
    });

    test('updateProfile calls repository with validated profile', () async {
      when(
        () => mockRepository.saveUserProfile(any()),
      ).thenAnswer((_) async {});
      await service.updateProfile(profile);
      verify(() => mockRepository.saveUserProfile(profile)).called(1);
    });

    test('updateProfile throws on invalid profile', () async {
      final invalid = UserProfile(age: -1);
      expect(() => service.updateProfile(invalid), throwsA(isA<Exception>()));
      verifyNever(() => mockRepository.saveUserProfile(any()));
    });

    test('deleteProfile calls repository', () async {
      when(() => mockRepository.deleteUserProfile()).thenAnswer((_) async {});
      await service.deleteProfile();
      verify(() => mockRepository.deleteUserProfile()).called(1);
    });

    test('repository failure propagates', () async {
      when(
        () => mockRepository.getUserProfile(),
      ).thenAnswer((_) async => throw Exception('DB error'));
      expect(() => service.getProfile(), throwsA(isA<Exception>()));
    });
  });
}
