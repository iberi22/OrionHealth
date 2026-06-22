import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/data/datasources/oauth_local_datasource.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/repositories/oauth_repository.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/oauth_repository.dart';

class MockOAuthLocalDataSource extends Mock implements OAuthLocalDataSource {}
class MockFlutterAppAuth extends Mock implements FlutterAppAuth {}
class MockDio extends Mock implements Dio {}

class FakeAuthorizationTokenRequest extends Fake implements AuthorizationTokenRequest {}
class FakeTokenRequest extends Fake implements TokenRequest {}

void main() {
  late OAuthRepositoryImpl repository;
  late MockOAuthLocalDataSource mockLocalDataSource;
  late MockFlutterAppAuth mockAppAuth;
  late MockDio mockDio;

  final testProvider = const EPSProvider(
    id: 'test_id',
    name: 'Test EPS',
    discoveryUrl: 'D',
    clientId: 'C',
    redirectUrl: 'R',
    scopes: ['S'],
    type: EPSProviderType.ihce,
  );

  setUpAll(() {
    registerFallbackValue(FakeAuthorizationTokenRequest());
    registerFallbackValue(FakeTokenRequest());
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockLocalDataSource = MockOAuthLocalDataSource();
    mockAppAuth = MockFlutterAppAuth();
    mockDio = MockDio();
    repository = OAuthRepositoryImpl(mockLocalDataSource, mockDio, appAuth: mockAppAuth);
  });

  group('OAuthRepositoryImpl', () {
    test('logout with revocationUrl calls dio post for both tokens', () async {
      final providerData = {
        'id': 'test_id',
        'name': 'Test EPS',
        'discoveryUrl': 'D',
        'revocationUrl': 'https://example.com/revoke',
        'clientId': 'C',
        'redirectUrl': 'R',
        'scopes': ['S'],
        'type': 'ihce',
      };

      when(() => mockLocalDataSource.getProviderData('test_id')).thenAnswer((_) async => providerData);
      when(() => mockLocalDataSource.getAccessToken('test_id')).thenAnswer((_) async => 'access');
      when(() => mockLocalDataSource.getRefreshToken('test_id')).thenAnswer((_) async => 'refresh');
      when(() => mockLocalDataSource.clearTokensForProvider(any())).thenAnswer((_) async => {});

      when(() => mockDio.post(
            'https://example.com/revoke',
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ));

      await repository.logout('test_id');

      verify(() => mockDio.post(
            'https://example.com/revoke',
            data: {'token': 'access'},
            options: any(named: 'options'),
          )).called(1);
      verify(() => mockDio.post(
            'https://example.com/revoke',
            data: {'token': 'refresh'},
            options: any(named: 'options'),
          )).called(1);
      verify(() => mockLocalDataSource.clearTokensForProvider('test_id')).called(1);
    });

    test('login success', () async {
      final expiration = DateTime.now().add(const Duration(hours: 1));
      final authResponse = AuthorizationTokenResponse(
        'access',
        'refresh',
        expiration,
        'id',
        'token_type',
        ['S'],
        {'patient': 'PT-123'},
        {},
      );

      when(() => mockLocalDataSource.getRefreshToken(any())).thenAnswer((_) async => null);
      when(() => mockAppAuth.authorizeAndExchangeCode(any())).thenAnswer((_) async => authResponse);
      when(() => mockLocalDataSource.saveTokensForProvider(any(), any(), any(), any(), expiresAt: any(named: 'expiresAt'))).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.saveProviderData(any(), any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.savePatientId(any(), any())).thenAnswer((_) async => {});

      final result = await repository.login(testProvider);

      expect(result?.patientId, 'PT-123');
      expect(result?.token.accessToken, 'access');
      expect(result?.token.refreshToken, 'refresh');
      expect(result?.token.expiresAt, expiration);
      verify(() => mockLocalDataSource.saveTokensForProvider('test_id', 'access', 'id', 'refresh', expiresAt: expiration)).called(1);
      verify(() => mockLocalDataSource.saveProviderData('test_id', any())).called(1);
      verify(() => mockLocalDataSource.savePatientId('test_id', 'PT-123')).called(1);
    });

    test('login preserves refresh token if new one is null', () async {
      final expiration = DateTime.now().add(const Duration(hours: 1));
      final authResponse = AuthorizationTokenResponse(
        'access',
        null, // No new refresh token
        expiration,
        'id',
        'token_type',
        ['S'],
        {'patient': 'PT-123'},
        {},
      );

      when(() => mockLocalDataSource.getRefreshToken('test_id')).thenAnswer((_) async => 'old_refresh');
      when(() => mockAppAuth.authorizeAndExchangeCode(any())).thenAnswer((_) async => authResponse);
      when(() => mockLocalDataSource.saveTokensForProvider(any(), any(), any(), any(), expiresAt: any(named: 'expiresAt'))).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.saveProviderData(any(), any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.savePatientId(any(), any())).thenAnswer((_) async => {});

      final result = await repository.login(testProvider);

      expect(result?.token.refreshToken, 'old_refresh');
      verify(() => mockLocalDataSource.saveTokensForProvider('test_id', 'access', 'id', 'old_refresh', expiresAt: expiration)).called(1);
    });

    test('login throws OAuthException on exception', () async {
      when(() => mockLocalDataSource.getRefreshToken(any())).thenAnswer((_) async => null);
      when(() => mockAppAuth.authorizeAndExchangeCode(any())).thenThrow(Exception('AppAuth Fail'));

      expect(() => repository.login(testProvider), throwsA(isA<OAuthException>()));
    });

    test('logout clears local data even if revocation fails', () async {
      final providerData = {
        'id': 'test_id',
        'name': 'Test EPS',
        'discoveryUrl': 'D',
        'revocationUrl': 'https://example.com/revoke',
        'clientId': 'C',
        'redirectUrl': 'R',
        'scopes': ['S'],
        'type': 'ihce',
      };
      when(() => mockLocalDataSource.getProviderData(any())).thenAnswer((_) async => providerData);
      when(() => mockLocalDataSource.getAccessToken(any())).thenAnswer((_) async => 'access');
      when(() => mockLocalDataSource.getRefreshToken(any())).thenAnswer((_) async => 'refresh');
      when(() => mockDio.post(any(), data: any(named: 'data'), options: any(named: 'options'))).thenThrow(DioException(requestOptions: RequestOptions(path: '')));
      when(() => mockLocalDataSource.clearTokensForProvider(any())).thenAnswer((_) async => {});

      await repository.logout('test_id');

      verify(() => mockLocalDataSource.clearTokensForProvider('test_id')).called(1);
    });

    test('getToken performs automatic refresh if token is expired', () async {
      final expiredDate = DateTime.now().subtract(const Duration(hours: 1));
      final newExpiration = DateTime.now().add(const Duration(hours: 1));

      when(() => mockLocalDataSource.getAccessToken('test_id')).thenAnswer((_) async => 'expired_access');
      when(() => mockLocalDataSource.getIdToken('test_id')).thenAnswer((_) async => 'id');
      when(() => mockLocalDataSource.getRefreshToken('test_id')).thenAnswer((_) async => 'refresh');
      when(() => mockLocalDataSource.getExpiresAt('test_id')).thenAnswer((_) async => expiredDate);

      final providerData = {
        'id': 'test_id',
        'name': 'Test EPS',
        'discoveryUrl': 'D',
        'clientId': 'C',
        'redirectUrl': 'R',
        'scopes': ['S'],
        'type': 'ihce',
      };
      when(() => mockLocalDataSource.getProviderData('test_id')).thenAnswer((_) async => providerData);

      final tokenResponse = TokenResponse(
        'new_access',
        'new_refresh',
        newExpiration,
        'new_id',
        'token_type',
        ['S'],
        {},
      );
      when(() => mockAppAuth.token(any())).thenAnswer((_) async => tokenResponse);
      when(() => mockLocalDataSource.saveTokensForProvider(any(), any(), any(), any(), expiresAt: any(named: 'expiresAt'))).thenAnswer((_) async => {});

      final token = await repository.getToken('test_id');

      expect(token?.accessToken, 'new_access');
      expect(token?.expiresAt, newExpiration);
      verify(() => mockAppAuth.token(any())).called(1);
    });

    test('getToken returns expired token if refresh fails', () async {
      final expiredDate = DateTime.now().subtract(const Duration(hours: 1));

      when(() => mockLocalDataSource.getAccessToken('test_id')).thenAnswer((_) async => 'expired_access');
      when(() => mockLocalDataSource.getIdToken('test_id')).thenAnswer((_) async => 'id');
      when(() => mockLocalDataSource.getRefreshToken('test_id')).thenAnswer((_) async => 'refresh');
      when(() => mockLocalDataSource.getExpiresAt('test_id')).thenAnswer((_) async => expiredDate);

      final providerData = {
        'id': 'test_id',
        'name': 'Test EPS',
        'discoveryUrl': 'D',
        'clientId': 'C',
        'redirectUrl': 'R',
        'scopes': ['S'],
        'type': 'ihce',
      };
      when(() => mockLocalDataSource.getProviderData('test_id')).thenAnswer((_) async => providerData);
      when(() => mockAppAuth.token(any())).thenThrow(Exception('Refresh fail'));

      final token = await repository.getToken('test_id');

      expect(token?.accessToken, 'expired_access');
      expect(token?.isExpired, true);
    });

    test('getToken returns null if access token is missing and refresh fails', () async {
      when(() => mockLocalDataSource.getAccessToken('test_id')).thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getIdToken('test_id')).thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getRefreshToken('test_id')).thenAnswer((_) async => 'refresh');
      when(() => mockLocalDataSource.getExpiresAt('test_id')).thenAnswer((_) async => null);

      when(() => mockLocalDataSource.getProviderData('test_id')).thenAnswer((_) async => null);

      final token = await repository.getToken('test_id');

      expect(token, isNull);
    });

    test('getPatientId returns from local data source', () async {
      when(() => mockLocalDataSource.getPatientId('test_id')).thenAnswer((_) async => 'PT-123');

      final patientId = await repository.getPatientId('test_id');

      expect(patientId, 'PT-123');
    });

    test('getProviderDetails returns EPSProvider from local data source', () async {
      final providerData = {
        'id': 'test_id',
        'name': 'Test EPS',
        'discoveryUrl': 'D',
        'clientId': 'C',
        'redirectUrl': 'R',
        'scopes': ['S'],
        'type': 'ihce',
      };
      when(() => mockLocalDataSource.getProviderData('test_id')).thenAnswer((_) async => providerData);

      final provider = await repository.getProviderDetails('test_id');

      expect(provider, testProvider);
    });

    test('getProviderDetails returns null and logs error on exception', () async {
      when(() => mockLocalDataSource.getProviderData('test_id')).thenThrow(Exception('DB Error'));

      final provider = await repository.getProviderDetails('test_id');

      expect(provider, isNull);
    });

    test('refreshToken success preserves refresh token if new one is null', () async {
      final expiration = DateTime.now().add(const Duration(hours: 1));
      final tokenResponse = TokenResponse(
        'new_access',
        null, // No new refresh token
        expiration,
        'new_id',
        'token_type',
        ['S'],
        {},
      );
      when(() => mockLocalDataSource.getRefreshToken('test_id')).thenAnswer((_) async => 'old_refresh');
      when(() => mockAppAuth.token(any())).thenAnswer((_) async => tokenResponse);
      when(() => mockLocalDataSource.saveTokensForProvider(any(), any(), any(), any(), expiresAt: any(named: 'expiresAt'))).thenAnswer((_) async => {});

      final token = await repository.refreshToken(testProvider);

      expect(token?.accessToken, 'new_access');
      expect(token?.refreshToken, 'old_refresh');
      verify(() => mockLocalDataSource.saveTokensForProvider('test_id', 'new_access', 'new_id', 'old_refresh', expiresAt: expiration)).called(1);
    });

    test('refreshToken throws OAuthException if no old refresh token', () async {
      when(() => mockLocalDataSource.getRefreshToken('test_id')).thenAnswer((_) async => null);

      expect(() => repository.refreshToken(testProvider), throwsA(isA<OAuthException>()));
    });

    test('getConnectedProviders returns from local data source', () async {
      when(() => mockLocalDataSource.getConnectedProviderIds()).thenAnswer((_) async => ['test_id']);

      final providers = await repository.getConnectedProviders();

      expect(providers, ['test_id']);
    });
  });
}
