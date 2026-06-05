import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late UserProfileRepositoryImpl repository;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_user_profile');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [UserProfileSchema],
      directory: testDir,
    );
    repository = UserProfileRepositoryImpl(isar);
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    await isar.writeTxn(() => isar.userProfiles.clear());
  });

  group('UserProfileRepositoryImpl', () {
    test('should save and get user profile', () async {
      final profile = UserProfile(name: 'John Doe', age: 30);

      await repository.saveUserProfile(profile);
      final result = await repository.getUserProfile();

      expect(result, isNotNull);
      expect(result?.name, 'John Doe');
      expect(result?.age, 30);
    });

    test('should return null when no profile exists', () async {
      final result = await repository.getUserProfile();
      expect(result, isNull);
    });

    test('should update existing profile', () async {
      final profile = UserProfile(name: 'John Doe', age: 30);
      await repository.saveUserProfile(profile);

      final existingProfile = await repository.getUserProfile();
      final updatedProfile = existingProfile!.copyWith(name: 'Jane Doe');

      await repository.saveUserProfile(updatedProfile);
      final result = await repository.getUserProfile();

      expect(result?.name, 'Jane Doe');
      expect(result?.id, existingProfile.id);
    });

    test('should delete user profile', () async {
      final profile = UserProfile(name: 'John Doe', age: 30);
      await repository.saveUserProfile(profile);

      expect(await repository.getUserProfile(), isNotNull);

      await repository.deleteUserProfile();

      expect(await repository.getUserProfile(), isNull);
    });
  });
}
