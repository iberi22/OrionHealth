import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late UserProfileLocalDataSource dataSource;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.systemTemp.path, 'isar_test_user_profile_ds');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [UserProfileSchema],
      directory: testDir,
    );
    dataSource = UserProfileLocalDataSource(isar);
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

  group('UserProfileLocalDataSource', () {
    test('getUserProfile returns null when empty', () async {
      final result = await dataSource.getUserProfile();
      expect(result, isNull);
    });

    test('saveUserProfile and getUserProfile works', () async {
      final profile = UserProfile(name: 'Test User');
      await dataSource.saveUserProfile(profile);

      final result = await dataSource.getUserProfile();
      expect(result?.name, 'Test User');
    });

    test('deleteUserProfile clears data', () async {
      await dataSource.saveUserProfile(UserProfile(name: 'Test User'));
      expect(await dataSource.getUserProfile(), isNotNull);

      await dataSource.deleteUserProfile();
      expect(await dataSource.getUserProfile(), isNull);
    });
  });
}
