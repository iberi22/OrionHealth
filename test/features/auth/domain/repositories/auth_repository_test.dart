import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class FakeAuthCredentials extends Fake implements AuthCredentials {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthCredentials());
  });

  group('AuthRepository Interface', () {
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
    });

    test('can be mocked and called for all methods', () async {
      final tCredentials = AuthCredentials()
        ..hashedPin = 'hashed'
        ..salt = 'salt';

      when(() => mockRepository.getCredentials()).thenAnswer((_) async => tCredentials);
      when(() => mockRepository.saveCredentials(any())).thenAnswer((_) async {});
      when(() => mockRepository.deleteCredentials()).thenAnswer((_) async {});
      when(() => mockRepository.hasPinSet()).thenAnswer((_) async => true);
      when(() => mockRepository.isBiometricsEnabled()).thenAnswer((_) async => true);

      final credentials = await mockRepository.getCredentials();
      await mockRepository.saveCredentials(tCredentials);
      await mockRepository.deleteCredentials();
      final hasPin = await mockRepository.hasPinSet();
      final isBioEnabled = await mockRepository.isBiometricsEnabled();

      expect(credentials, tCredentials);
      expect(hasPin, isTrue);
      expect(isBioEnabled, isTrue);

      verify(() => mockRepository.getCredentials()).called(1);
      verify(() => mockRepository.saveCredentials(tCredentials)).called(1);
      verify(() => mockRepository.deleteCredentials()).called(1);
      verify(() => mockRepository.hasPinSet()).called(1);
      verify(() => mockRepository.isBiometricsEnabled()).called(1);
    });
  });
}
