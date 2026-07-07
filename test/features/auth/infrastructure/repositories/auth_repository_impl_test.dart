import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/services/secure_storage_service.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_session.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_user.dart';
import 'package:orionhealth_health/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:orionhealth_health/features/auth/data/datasources/auth_local_datasource.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockSecureStorageService extends Mock implements SecureStorageService {}

class FakeAuthCredentials extends Fake implements AuthCredentials {}

void main() {
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockSecureStorageService mockSecureStorage;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredentials());
  });

  setUp(() {
    mockLocalDataSource = MockAuthLocalDataSource();
    mockSecureStorage = MockSecureStorageService();
    repository = AuthRepositoryImpl(mockLocalDataSource, mockSecureStorage);
  });

  group('AuthRepositoryImpl', () {
    group('Credentials', () {
      test('saveCredentials saves secrets to secure storage and other data to local datasource', () async {
        final credentials = AuthCredentials()
          ..hashedPin = 'hashed_pin'
          ..salt = 'salt'
          ..biometricEnabled = true;

        when(() => mockSecureStorage.writeSecure(any(), any(), any())).thenAnswer((_) async {});
        when(() => mockLocalDataSource.saveCredentials(any())).thenAnswer((_) async {});

        await repository.saveCredentials(credentials);

        verify(() => mockSecureStorage.writeSecure('auth_credentials', 'hashedPin', 'hashed_pin')).called(1);
        verify(() => mockSecureStorage.writeSecure('auth_credentials', 'salt', 'salt')).called(1);
        verify(() => mockSecureStorage.writeSecure('auth_credentials', 'biometricEnabled', 'true')).called(1);
        verify(() => mockLocalDataSource.saveCredentials(any())).called(1);
      });

      test('getCredentials merges secrets from secure storage', () async {
        final baseCredentials = AuthCredentials()..failedAttempts = 3;
        when(() => mockLocalDataSource.getCredentials()).thenAnswer((_) async => baseCredentials);
        when(() => mockSecureStorage.readSecure('auth_credentials', 'hashedPin')).thenAnswer((_) async => 'hashed_pin');
        when(() => mockSecureStorage.readSecure('auth_credentials', 'salt')).thenAnswer((_) async => 'salt');
        when(() => mockSecureStorage.readSecure('auth_credentials', 'biometricEnabled')).thenAnswer((_) async => 'true');

        final result = await repository.getCredentials();

        expect(result?.hashedPin, 'hashed_pin');
        expect(result?.salt, 'salt');
        expect(result?.biometricEnabled, isTrue);
        expect(result?.failedAttempts, 3);
      });

      test('deleteCredentials clears both storages', () async {
        when(() => mockSecureStorage.deleteSecure(any(), any())).thenAnswer((_) async {});
        when(() => mockLocalDataSource.deleteCredentials()).thenAnswer((_) async {});

        await repository.deleteCredentials();

        verify(() => mockSecureStorage.deleteSecure('auth_credentials', 'hashedPin')).called(1);
        verify(() => mockSecureStorage.deleteSecure('auth_credentials', 'salt')).called(1);
        verify(() => mockSecureStorage.deleteSecure('auth_credentials', 'biometricEnabled')).called(1);
        verify(() => mockLocalDataSource.deleteCredentials()).called(1);
      });
    });

    group('Session', () {
      test('saveSession saves session to secure storage as JSON', () async {
        final expiry = DateTime.now().add(const Duration(hours: 1));
        final session = AuthSession(token: 'token123', expiresAt: expiry);

        when(() => mockSecureStorage.writeJson(any(), any())).thenAnswer((_) async {});

        await repository.saveSession(session);

        verify(() => mockSecureStorage.writeJson('auth_session', {
              'token': 'token123',
              'expiresAt': expiry.toIso8601String(),
            })).called(1);
      });

      test('getSession retrieves session from secure storage', () async {
        final expiry = DateTime.now().add(const Duration(hours: 1));
        when(() => mockSecureStorage.readJson('auth_session')).thenAnswer((_) async => {
              'token': 'token123',
              'expiresAt': expiry.toIso8601String(),
            });

        final result = await repository.getSession();

        expect(result?.token, 'token123');
        expect(result?.expiresAt.toIso8601String(), expiry.toIso8601String());
      });

      test('deleteSession removes session from secure storage', () async {
        when(() => mockSecureStorage.delete(any())).thenAnswer((_) async {});

        await repository.deleteSession();

        verify(() => mockSecureStorage.delete('auth_session')).called(1);
      });
    });

    group('User', () {
      test('getAuthenticatedUser retrieves user from secure storage', () async {
        when(() => mockSecureStorage.readJson('auth_user')).thenAnswer((_) async => {
              'id': 'user123',
              'email': 'test@example.com',
              'role': 'patient',
            });

        final result = await repository.getAuthenticatedUser();

        expect(result?.id, 'user123');
        expect(result?.email, 'test@example.com');
        expect(result?.role, 'patient');
      });

      test('setAuthenticatedUser saves user to secure storage', () async {
        const user = AuthUser(id: 'user123', email: 'test@example.com', role: 'patient');
        when(() => mockSecureStorage.writeJson(any(), any())).thenAnswer((_) async {});

        repository.setAuthenticatedUser(user);

        // It's async internally but called from sync method
        await Future.delayed(Duration.zero);

        verify(() => mockSecureStorage.writeJson('auth_user', {
              'id': 'user123',
              'email': 'test@example.com',
              'role': 'patient',
            })).called(1);
      });

      test('setAuthenticatedUser(null) deletes user from secure storage', () async {
        when(() => mockSecureStorage.delete(any())).thenAnswer((_) async {});

        repository.setAuthenticatedUser(null);

        verify(() => mockSecureStorage.delete('auth_user')).called(1);
      });
    });
  });
}
