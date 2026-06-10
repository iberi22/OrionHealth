import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/repositories/oauth_repository_impl.dart';

import 'oauth_repository_test.mocks.dart';

@GenerateMocks([FlutterAppAuth, FlutterSecureStorage])
void main() {
  late OAuthRepositoryImpl repository;
  late MockFlutterAppAuth mockAppAuth;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockAppAuth = MockFlutterAppAuth();
    mockSecureStorage = MockFlutterSecureStorage();
    repository = OAuthRepositoryImpl(
      appAuth: mockAppAuth,
      secureStorage: mockSecureStorage,
    );
  });

  group('OAuthRepositoryImpl', () {
    test('login should use discoveryUrl and save tokens', () async {
      final response = AuthorizationTokenResponse(
        'access_token',
        'refresh_token',
        DateTime.now(),
        'id_token',
        'token_type',
        [],
        {},
        {},
      );

      when(mockAppAuth.authorizeAndExchangeCode(any)).thenAnswer((_) async => response);

      final result = await repository.login();

      expect(result, equals(response));
      final captured = verify(mockAppAuth.authorizeAndExchangeCode(captureAny)).captured.single as AuthorizationTokenRequest;
      expect(captured.discoveryUrl, 'https://ihce.example.com/.well-known/openid-configuration');

      verify(mockSecureStorage.write(key: 'oauth_access_token', value: 'access_token')).called(1);
      verify(mockSecureStorage.write(key: 'oauth_id_token', value: 'id_token')).called(1);
      verify(mockSecureStorage.write(key: 'oauth_refresh_token', value: 'refresh_token')).called(1);
    });

    test('refreshToken should use discoveryUrl and update tokens', () async {
      when(mockSecureStorage.read(key: 'oauth_refresh_token')).thenAnswer((_) async => 'old_refresh_token');

      final response = TokenResponse(
        'new_access_token',
        'new_refresh_token',
        DateTime.now(),
        'new_id_token',
        'token_type',
        [],
        {},
      );

      when(mockAppAuth.token(any)).thenAnswer((_) async => response);

      final result = await repository.refreshToken();

      expect(result, equals(response));
      final captured = verify(mockAppAuth.token(captureAny)).captured.single as TokenRequest;
      expect(captured.discoveryUrl, 'https://ihce.example.com/.well-known/openid-configuration');
      expect(captured.refreshToken, 'old_refresh_token');

      verify(mockSecureStorage.write(key: 'oauth_access_token', value: 'new_access_token')).called(1);
      verify(mockSecureStorage.write(key: 'oauth_id_token', value: 'new_id_token')).called(1);
      verify(mockSecureStorage.write(key: 'oauth_refresh_token', value: 'new_refresh_token')).called(1);
    });

    test('refreshToken should return null if no refresh token stored', () async {
      when(mockSecureStorage.read(key: 'oauth_refresh_token')).thenAnswer((_) async => null);

      final result = await repository.refreshToken();

      expect(result, isNull);
      verifyNever(mockAppAuth.token(any));
    });
  });
}
