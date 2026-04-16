import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';
import 'package:orionhealth_health/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/biometric_service.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mocktail/mocktail.dart';

class MockEncryptionService extends Mock implements EncryptionService {}
class MockBiometricService extends Mock implements BiometricService {}

void main() {
  late Isar isar;
  late AuthRepositoryImpl repository;
  late String testDir;
  late MockEncryptionService mockEncryptionService;
  late MockBiometricService mockBiometricService;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_auth');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [AuthCredentialsSchema],
      directory: testDir,
    );

    mockEncryptionService = MockEncryptionService();
    mockBiometricService = MockBiometricService();
    repository = AuthRepositoryImpl(isar, mockEncryptionService, mockBiometricService);
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

  group('AuthRepository PIN Setup', () {
    test('should setup PIN correctly', () async {
      const pin = '1234';
      const salt = 'some-salt';
      const hashedPin = 'some-hash';

      when(() => mockEncryptionService.generatePinSalt()).thenAnswer((_) async => salt);
      when(() => mockEncryptionService.hashPin(pin, salt)).thenAnswer((_) async => hashedPin);

      await repository.setupPin(pin);

      final credentials = await repository.getCredentials();
      expect(credentials, isNotNull);
      expect(credentials!.hashedPin, hashedPin);
      expect(credentials.salt, salt);
    });
  });

  group('AuthRepository Lockout', () {
    test('should progressive lockout after 3 failed attempts', () async {
      const pin = 'wrong-pin';
      const salt = 'salt';
      const hashedPin = 'hash';

      // Setup credentials
      await isar.writeTxn(() => isar.authCredentials.put(AuthCredentials(
        hashedPin: hashedPin,
        salt: salt,
      )));

      when(() => mockEncryptionService.verifyPin(any(), any(), any()))
          .thenAnswer((_) async => false);

      // Attempt 1
      await repository.verifyPin(pin);
      var creds = await repository.getCredentials();
      expect(creds!.failedAttempts, 1);
      expect(creds.lockoutUntil, isNull);

      // Attempt 2
      await repository.verifyPin(pin);
      creds = await repository.getCredentials();
      expect(creds!.failedAttempts, 2);
      expect(creds.lockoutUntil, isNull);

      // Attempt 3 -> 1 min lockout
      await repository.verifyPin(pin);
      creds = await repository.getCredentials();
      expect(creds!.failedAttempts, 3);
      expect(creds.lockoutUntil, isNotNull);

      final isLocked = await repository.isLockedOut();
      expect(isLocked, isTrue);
    });
  });
}
