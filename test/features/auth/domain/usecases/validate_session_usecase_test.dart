import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_session.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/validate_session_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late ValidateSessionUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ValidateSessionUseCase(mockRepository);
  });

  group('ValidateSessionUseCase', () {
    test('should return session when it exists and is not expired', () async {
      final tSession = AuthSession(
        token: 'token',
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );

      when(() => mockRepository.getSession()).thenAnswer((_) async => tSession);

      final result = await useCase();

      expect(result, tSession);
    });

    test('should return null and delete session when it is expired', () async {
      final tSession = AuthSession(
        token: 'token',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      when(() => mockRepository.getSession()).thenAnswer((_) async => tSession);
      when(() => mockRepository.deleteSession()).thenAnswer((_) async {});

      final result = await useCase();

      expect(result, isNull);
      verify(() => mockRepository.deleteSession()).called(1);
    });

    test('should return null when session does not exist', () async {
      when(() => mockRepository.getSession()).thenAnswer((_) async => null);

      final result = await useCase();

      expect(result, isNull);
    });
  });
}
