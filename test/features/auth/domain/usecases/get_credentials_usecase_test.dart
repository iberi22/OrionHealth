import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/get_credentials_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetCredentialsUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetCredentialsUseCase(mockRepository);
  });

  group('GetCredentialsUseCase', () {
    test('should return credentials from repository', () async {
      final tCredentials = AuthCredentials();
      when(() => mockRepository.getCredentials()).thenAnswer((_) async => tCredentials);

      final result = await useCase();

      expect(result, tCredentials);
      verify(() => mockRepository.getCredentials()).called(1);
    });
  });
}
