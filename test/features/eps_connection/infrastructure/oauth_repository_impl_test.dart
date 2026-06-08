import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/oauth_repository.dart';

class MockFlutterAppAuth extends Mock implements FlutterAppAuth {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late OAuthRepositoryImpl repository;
  late MockFlutterAppAuth mockAppAuth;
  late MockFlutterSecureStorage mockSecureStorage;

  setUpAll(() {
    registerFallbackValue(AuthorizationTokenRequest(
      'clientId',
      'redirectUrl',
      discoveryUrl: 'discoveryUrl',
    ));
    registerFallbackValue(TokenRequest(
      'clientId',
      'redirectUrl',
      discoveryUrl: 'discoveryUrl',
      refreshToken: 'refreshToken',
    ));
  });

  setUp(() {
    mockAppAuth = MockFlutterAppAuth();
    mockSecureStorage = MockFlutterSecureStorage();
    repository = OAuthRepositoryImpl(
      appAuth: mockAppAuth,
      secureStorage: mockSecureStorage,
    );
  });

  group('OAuthRepositoryImpl', () {
    const accessToken = 'test_access_token';
    const idToken = 'test_id_token';
    const refreshToken = 'test_refresh_token';

    test('login success stores tokens and returns response', () async {
      final response = AuthorizationTokenResponse(
        accessToken,
        refreshToken,
        DateTime.now().add(const Duration(hours: 1)),
        idToken,
        'tokenType',
        null,
        null,
        null,
      );

      when(() => mockAppAuth.authorizeAndExchangeCode(any()))
          .thenAnswer((_) async => response);
      when(() => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async => {});

      final result = await repository.login();

      expect(result, equals(response));
      verify(() => mockSecureStorage.write(key: 'oauth_access_token', value: accessToken)).called(1);
      verify(() => mockSecureStorage.write(key: 'oauth_id_token', value: idToken)).called(1);
      verify(() => mockSecureStorage.write(key: 'oauth_refresh_token', value: refreshToken)).called(1);
    });

    test('login exception (e.g. 404, timeout) returns null', () async {
      when(() => mockAppAuth.authorizeAndExchangeCode(any()))
          .thenThrow(PlatformException(code: 'network_error', message: '404 Not Found'));

      final result = await repository.login();

      expect(result, isNull);
    });

    test('login returns null when authorization is cancelled', () async {
      when(() => mockAppAuth.authorizeAndExchangeCode(any()))
          .thenAnswer((_) async => null as dynamic);

      final result = await repository.login();

      expect(result, isNull);
      verifyNever(() => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ));
    });

    test('refreshToken success updates tokens', () async {
      when(() => mockSecureStorage.read(key: 'oauth_refresh_token'))
          .thenAnswer((_) async => 'old_refresh_token');

      final response = TokenResponse(
        'new_access_token',
        'new_refresh_token',
        DateTime.now().add(const Duration(hours: 1)),
        'new_id_token',
        'tokenType',
        null,
        null,
      );

      when(() => mockAppAuth.token(any()))
          .thenAnswer((_) async => response);
      when(() => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async => {});

      final result = await repository.refreshToken();

      expect(result, equals(response));
      verify(() => mockSecureStorage.write(key: 'oauth_access_token', value: 'new_access_token')).called(1);
    });

    test('refreshToken returns null if refresh token expired or invalid', () async {
      when(() => mockSecureStorage.read(key: 'oauth_refresh_token'))
          .thenAnswer((_) async => 'expired_token');

      when(() => mockAppAuth.token(any()))
          .thenThrow(PlatformException(code: 'invalid_grant', message: 'Token expired'));

      final result = await repository.refreshToken();

      expect(result, isNull);
    });

    test('logout deletes tokens', () async {
      when(() => mockSecureStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async => {});

      await repository.logout();

      verify(() => mockSecureStorage.delete(key: 'oauth_access_token')).called(1);
      verify(() => mockSecureStorage.delete(key: 'oauth_id_token')).called(1);
      verify(() => mockSecureStorage.delete(key: 'oauth_refresh_token')).called(1);
    });

    test('getAccessToken returns stored token', () async {
      when(() => mockSecureStorage.read(key: 'oauth_access_token'))
          .thenAnswer((_) async => accessToken);

      final result = await repository.getAccessToken();

      expect(result, equals(accessToken));
    });

    test('getIdToken returns stored token', () async {
      when(() => mockSecureStorage.read(key: 'oauth_id_token'))
          .thenAnswer((_) async => idToken);

      final result = await repository.getIdToken();

      expect(result, equals(idToken));
    });
  });
}
