import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/set_pin_usecase.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import '../../../../helpers/mock_encryption_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class FakeAuthCredentials extends Fake implements AuthCredentials {}

void main() {
  late SetPinUseCase useCase;
  late MockAuthRepository mockRepository;
  late MockEncryptionService mockEncryptionService;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredentials());
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    mockEncryptionService = MockEncryptionService();
    useCase = SetPinUseCase(mockRepository, mockEncryptionService);
  });

  group('SetPinUseCase', () {
    const tPin = '1234';
    const tHashedPin = 'hashedPin';

    test('should save credentials when PIN is valid', () async {
      when(
        () => mockEncryptionService.hashPin(any(), any()),
      ).thenAnswer((_) async => tHashedPin);
      when(
        () => mockRepository.saveCredentials(any()),
      ).thenAnswer((_) async {});

      final result = await useCase(tPin);

      expect(result, isTrue);
      verify(() => mockEncryptionService.hashPin(tPin, any())).called(1);
      verify(
        () => mockRepository.saveCredentials(any(that: isA<AuthCredentials>())),
      ).called(1);
    });

    test('should return false when PIN is too short', () async {
      final result = await useCase('123');

      expect(result, isFalse);
      verifyNever(() => mockRepository.saveCredentials(any()));
    });

    test('should return false when PIN is too long', () async {
      final result = await useCase('1234567');

      expect(result, isFalse);
      verifyNever(() => mockRepository.saveCredentials(any()));
    });
  });
}
