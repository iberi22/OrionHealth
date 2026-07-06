import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/save_credentials_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class FakeAuthCredentials extends Fake implements AuthCredentials {}

void main() {
  late SaveCredentialsUseCase useCase;
  late MockAuthRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredentials());
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SaveCredentialsUseCase(mockRepository);
  });

  group('SaveCredentialsUseCase', () {
    test('should save credentials in repository', () async {
      final tCredentials = AuthCredentials();
      when(() => mockRepository.saveCredentials(any())).thenAnswer((_) async {});

      await useCase(tCredentials);

      verify(() => mockRepository.saveCredentials(tCredentials)).called(1);
    });
  });
}
