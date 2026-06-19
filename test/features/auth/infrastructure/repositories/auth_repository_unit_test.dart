import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';
import 'package:orionhealth_health/features/auth/infrastructure/repositories/auth_repository_impl.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

class MockIsarCollection extends Mock implements IsarCollection<AuthCredentials> {}

class FakeAuthCredentials extends Fake implements AuthCredentials {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredentials());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = AuthRepositoryImpl(mockIsar);

    when(() => mockIsar.authCredentials).thenReturn(mockCollection);
  });

  group('AuthRepositoryImpl (Mocked)', () {
    test('saveCredentials puts credentials in collection', () async {
      final credentials = AuthCredentials()
        ..hashedPin = 'hashed'
        ..salt = 'salt'
        ..biometricEnabled = true;

      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.saveCredentials(credentials);

      verify(() => mockCollection.put(credentials)).called(1);
    });
  });
}
