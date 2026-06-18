import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:orionhealth_health/features/user_profile/data/repositories/user_profile_repository_impl.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';

class MockUserProfileLocalDataSource extends Mock implements UserProfileLocalDataSource {}

class UserProfileFake extends Fake implements UserProfile {}

void main() {
  late MockUserProfileLocalDataSource mockDataSource;
  late UserProfileRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(UserProfileFake());
  });

  setUp(() {
    mockDataSource = MockUserProfileLocalDataSource();
    repository = UserProfileRepositoryImpl(mockDataSource);
  });

  group('UserProfileRepositoryImpl (Data Layer)', () {
    final tProfile = UserProfile(name: 'Data Layer Test');

    test('getUserProfile should call local datasource', () async {
      when(() => mockDataSource.getUserProfile()).thenAnswer((_) async => tProfile);

      final result = await repository.getUserProfile();

      expect(result, equals(tProfile));
      verify(() => mockDataSource.getUserProfile()).called(1);
    });

    test('saveUserProfile should call local datasource', () async {
      when(() => mockDataSource.saveUserProfile(any())).thenAnswer((_) async {});

      await repository.saveUserProfile(tProfile);

      verify(() => mockDataSource.saveUserProfile(tProfile)).called(1);
    });

    test('deleteUserProfile should call local datasource', () async {
      when(() => mockDataSource.deleteUserProfile()).thenAnswer((_) async {});

      await repository.deleteUserProfile();

      verify(() => mockDataSource.deleteUserProfile()).called(1);
    });
  });
}
