import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credential.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_session.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/login_usecase.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/biometric_service.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import '../../../../helpers/mock_encryption_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockBiometricService extends Mock implements BiometricService {}

class FakeAuthCredentials extends Fake implements AuthCredentials {}

class FakeAuthSession extends Fake implements AuthSession {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;
  late MockEncryptionService mockEncryptionService;
  late MockBiometricService mockBiometricService;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredentials());
    registerFallbackValue(FakeAuthSession());
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    mockEncryptionService = MockEncryptionService();
    mockBiometricService = MockBiometricService();
    useCase = LoginUseCase(
      mockRepository,
      mockEncryptionService,
      mockBiometricService,
    );

    when(() => mockRepository.saveCredentials(any())).thenAnswer((_) async {});
    when(() => mockRepository.saveSession(any())).thenAnswer((_) async {});
  });

  group('LoginUseCase', () {
    const tPin = '1234';
    const tSalt = 'salt';
    const tHashedPin = 'hashedPin';

    test('should return session when PIN is correct', () async {
      final tCredentials = AuthCredentials()
        ..hashedPin = tHashedPin
        ..salt = tSalt
        ..failedAttempts = 0;

      when(
        () => mockRepository.getCredentials(),
      ).thenAnswer((_) async => tCredentials);
      when(
        () => mockEncryptionService.hashPin(tPin, tSalt),
      ).thenAnswer((_) async => tHashedPin);
      when(
        () => mockRepository.saveCredentials(any()),
      ).thenAnswer((_) async {});
      when(() => mockRepository.saveSession(any())).thenAnswer((_) async {});

      final result = await useCase(const PinCredential(tPin));

      expect(result, isA<AuthSession>());
      verify(() => mockRepository.saveCredentials(any())).called(1);
      verify(() => mockRepository.saveSession(any())).called(1);
    });

    test(
      'should return null and increment failed attempts when PIN is incorrect',
      () async {
        final tCredentials = AuthCredentials()
          ..hashedPin = tHashedPin
          ..salt = tSalt
          ..failedAttempts = 0;

        when(
          () => mockRepository.getCredentials(),
        ).thenAnswer((_) async => tCredentials);
        when(
          () => mockEncryptionService.hashPin(tPin, tSalt),
        ).thenAnswer((_) async => 'wrongHash');
        when(
          () => mockRepository.saveCredentials(any()),
        ).thenAnswer((_) async {});

        final result = await useCase(const PinCredential(tPin));

        expect(result, isNull);
        expect(tCredentials.failedAttempts, 1);
        verify(() => mockRepository.saveCredentials(tCredentials)).called(1);
      },
    );

    test('should lockout when failed attempts reach limit', () async {
      final tCredentials = AuthCredentials()
        ..hashedPin = tHashedPin
        ..salt = tSalt
        ..failedAttempts = 4;

      when(
        () => mockRepository.getCredentials(),
      ).thenAnswer((_) async => tCredentials);
      when(
        () => mockEncryptionService.hashPin(tPin, tSalt),
      ).thenAnswer((_) async => 'wrongHash');
      when(
        () => mockRepository.saveCredentials(any()),
      ).thenAnswer((_) async {});

      final result = await useCase(const PinCredential(tPin));

      expect(result, isNull);
      expect(tCredentials.failedAttempts, 5);
      expect(tCredentials.lastLockoutTime, isNotNull);
    });

    test('should return null when account is locked', () async {
      final tCredentials = AuthCredentials()
        ..hashedPin = tHashedPin
        ..salt = tSalt
        ..failedAttempts = 5
        ..lastLockoutTime = DateTime.now();

      when(
        () => mockRepository.getCredentials(),
      ).thenAnswer((_) async => tCredentials);
      when(
        () => mockEncryptionService.hashPin(any(), any()),
      ).thenAnswer((_) async => tHashedPin);

      final result = await useCase(const PinCredential(tPin));

      expect(result, isNull);
      verifyNever(() => mockEncryptionService.hashPin(any(), any()));
    });

    test(
      'should return session when biometrics authentication is successful',
      () async {
        final tCredentials = AuthCredentials()..biometricEnabled = true;

        when(
          () => mockRepository.getCredentials(),
        ).thenAnswer((_) async => tCredentials);
        when(
          () => mockBiometricService.authenticate(
            localizedReason: any(named: 'localizedReason'),
          ),
        ).thenAnswer((_) async => true);
        when(() => mockRepository.saveSession(any())).thenAnswer((_) async {});

        final result = await useCase(const BiometricCredential());

        expect(result, isA<AuthSession>());
        verify(() => mockRepository.saveSession(any())).called(1);
      },
    );

    test('should return null when biometrics authentication fails', () async {
      final tCredentials = AuthCredentials()..biometricEnabled = true;

      when(
        () => mockRepository.getCredentials(),
      ).thenAnswer((_) async => tCredentials);
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => false);

      final result = await useCase(const BiometricCredential());

      expect(result, isNull);
    });

    test('should return null when biometrics is not enabled', () async {
      final tCredentials = AuthCredentials()..biometricEnabled = false;

      when(
        () => mockRepository.getCredentials(),
      ).thenAnswer((_) async => tCredentials);

      final result = await useCase(const BiometricCredential());

      expect(result, isNull);
    });
  });
}
