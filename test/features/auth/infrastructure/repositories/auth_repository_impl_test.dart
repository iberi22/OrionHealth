import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';
import 'package:orionhealth_health/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late AuthRepositoryImpl repository;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_auth');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [AuthCredentialsSchema],
      directory: testDir,
    );
    repository = AuthRepositoryImpl(isar);
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    await isar.writeTxn(() => isar.authCredentials.clear());
  });

  group('AuthRepositoryImpl', () {
    test('should save and get credentials', () async {
      final credentials = AuthCredentials()
        ..hashedPin = 'hashed'
        ..salt = 'salt'
        ..biometricEnabled = true;

      await repository.saveCredentials(credentials);
      final result = await repository.getCredentials();

      expect(result, isNotNull);
      expect(result?.hashedPin, 'hashed');
      expect(result?.salt, 'salt');
      expect(result?.biometricEnabled, isTrue);
    });

    test('should return null when no credentials exist', () async {
      final result = await repository.getCredentials();
      expect(result, isNull);
    });

    test('hasPinSet should return true if hashedPin is present', () async {
      final credentials = AuthCredentials()..hashedPin = 'hashed';
      await repository.saveCredentials(credentials);

      expect(await repository.hasPinSet(), isTrue);
    });

    test('isBiometricsEnabled should return correct value', () async {
      final credentials = AuthCredentials()..biometricEnabled = true;
      await repository.saveCredentials(credentials);

      expect(await repository.isBiometricsEnabled(), isTrue);
    });

    test('deleteCredentials should clear all credentials', () async {
      final credentials = AuthCredentials()..hashedPin = 'hashed';
      await repository.saveCredentials(credentials);

      await repository.deleteCredentials();

      expect(await repository.getCredentials(), isNull);
    });
  });
}
