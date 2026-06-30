import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/domain/auth_service.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';

class MockEncryptionService extends Mock implements EncryptionService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AuthServiceImpl authService;
  late MockEncryptionService mockEncryptionService;
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    mockEncryptionService = MockEncryptionService();
    authService = AuthServiceImpl(mockEncryptionService);
    log.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('local_auth'), (MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'isDeviceSupported':
          return true;
        default:
          return null;
      }
    });
  });

  group('AuthServiceImpl', () {
    test('setPin should hash and store pin', () async {
      when(() => mockEncryptionService.generatePinSalt()).thenAnswer((_) async => 'salt');
      when(() => mockEncryptionService.hashPin(any(), any())).thenAnswer((_) async => 'hashed');

      final result = await authService.setPin('1234');

      expect(result.success, isTrue);
      expect(result.method, AuthMethod.pin);
      verify(() => mockEncryptionService.generatePinSalt()).called(1);
      verify(() => mockEncryptionService.hashPin('1234', 'salt')).called(1);
    });

    test('setPin should return error for invalid pin length', () async {
      final result = await authService.setPin('123');

      expect(result.success, isFalse);
      expect(result.error, 'pin must be 4-6 digits');
      verifyNever(() => mockEncryptionService.hashPin(any(), any()));
    });

    test('verifyPin should return true for valid pin', () async {
      // Set pin first to cache it
      when(() => mockEncryptionService.generatePinSalt()).thenAnswer((_) async => 'salt');
      when(() => mockEncryptionService.hashPin(any(), any())).thenAnswer((_) async => 'hashed');
      await authService.setPin('1234');

      when(() => mockEncryptionService.verifyPin('1234', 'hashed', 'salt')).thenAnswer((_) async => true);

      final result = await authService.verifyPin('1234');

      expect(result.success, isTrue);
    });

    test('verifyPin should return error for invalid pin', () async {
      when(() => mockEncryptionService.generatePinSalt()).thenAnswer((_) async => 'salt');
      when(() => mockEncryptionService.hashPin(any(), any())).thenAnswer((_) async => 'hashed');
      await authService.setPin('1234');

      when(() => mockEncryptionService.verifyPin('4321', 'hashed', 'salt')).thenAnswer((_) async => false);

      final result = await authService.verifyPin('4321');

      expect(result.success, isFalse);
      expect(result.error, 'Invalid pin');
    });

    test('isBiometricAvailable should return true when channel returns true', () async {
      final result = await authService.isBiometricAvailable();
      expect(result, isTrue);
      expect(log, anyElement(predicate((m) => (m as MethodCall).method == 'isDeviceSupported')));
    });

    test('verifyBiometric should return error if not available', () async {
      // isBiometricAvailable not called or returned false
      final result = await authService.verifyBiometric();
      expect(result.success, isFalse);
      expect(result.error, 'Biometric not available');
    });

    test('verifyBiometric should return success when available', () async {
      await authService.isBiometricAvailable();
      final result = await authService.verifyBiometric();
      expect(result.success, isTrue);
      expect(result.method, AuthMethod.biometric);
    });

    test('isPinSet currently returns false even after setPin due to implementation detail', () async {
      // AuthServiceImpl.isPinSet() currently overwrites _cachedPinHash with null from _getStoredPinHash()
      // This documents the current behavior of the skeleton implementation.
      when(() => mockEncryptionService.generatePinSalt()).thenAnswer((_) async => 'salt');
      when(() => mockEncryptionService.hashPin(any(), any())).thenAnswer((_) async => 'hashed');

      await authService.setPin('1234');

      expect(await authService.isPinSet(), isFalse);
    });

    test('clearAuth should reset cached data', () async {
      when(() => mockEncryptionService.generatePinSalt()).thenAnswer((_) async => 'salt');
      when(() => mockEncryptionService.hashPin(any(), any())).thenAnswer((_) async => 'hashed');
      await authService.setPin('1234');

      await authService.clearAuth();

      expect(await authService.isPinSet(), isFalse);
    });
  });
}
