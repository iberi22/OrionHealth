import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/oauth_repository.dart';

class MockFlutterAppAuth extends Mock implements FlutterAppAuth {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockAuthorizationTokenRequest extends Mock implements AuthorizationTokenRequest {}

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

    test('login exception returns null and does not store tokens', () async {
      when(() => mockAppAuth.authorizeAndExchangeCode(any()))
          .thenThrow(Exception('Auth error'));

      final result = await repository.login();

      expect(result, isNull);
      verifyNever(() => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ));
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

    test('getAccessToken returns null if not stored', () async {
      when(() => mockSecureStorage.read(key: 'oauth_access_token'))
          .thenAnswer((_) async => null);

      final result = await repository.getAccessToken();

      expect(result, isNull);
    });

    test('getIdToken returns null if not stored', () async {
      when(() => mockSecureStorage.read(key: 'oauth_id_token'))
          .thenAnswer((_) async => null);

      final result = await repository.getIdToken();

      expect(result, isNull);
    });
  });
}
