import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockEncryptionService extends Mock implements EncryptionService {}

void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepository;
  late MockEncryptionService mockEncryptionService;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockEncryptionService = MockEncryptionService();
    useCase = LogoutUseCase(mockRepository, mockEncryptionService);
  });

  group('LogoutUseCase', () {
    test(
      'should call clearHealthKeyCache on EncryptionService and deleteSession on the repository',
      () async {
        when(
          () => mockEncryptionService.clearHealthKeyCache(),
        ).thenReturn(null);
        when(() => mockRepository.deleteSession()).thenAnswer((_) async {});

        await useCase();

        verify(() => mockEncryptionService.clearHealthKeyCache()).called(1);
        verify(() => mockRepository.deleteSession()).called(1);
      },
    );
  });
}
