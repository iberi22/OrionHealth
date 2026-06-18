import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/data/datasources/oauth_local_datasource.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/oauth_repository.dart';

class MockOAuthLocalDataSource extends Mock implements OAuthLocalDataSource {}
class MockFlutterAppAuth extends Mock implements FlutterAppAuth {}

class FakeAuthorizationTokenRequest extends Fake implements AuthorizationTokenRequest {}
class FakeTokenRequest extends Fake implements TokenRequest {}

void main() {
  late OAuthRepositoryImpl repository;
  late MockOAuthLocalDataSource mockLocalDataSource;
  late MockFlutterAppAuth mockAppAuth;

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
  });

  setUp(() {
    mockLocalDataSource = MockOAuthLocalDataSource();
    mockAppAuth = MockFlutterAppAuth();
    repository = OAuthRepositoryImpl(mockLocalDataSource, appAuth: mockAppAuth);
  });

  group('OAuthRepositoryImpl', () {
    test('login success', () async {
      final authResponse = AuthorizationTokenResponse(
        'access',
        'refresh',
        DateTime.now().add(const Duration(hours: 1)),
        'id',
        'token_type',
        ['S'],
        {'patient': 'PT-123'},
        {},
      );

      when(() => mockAppAuth.authorizeAndExchangeCode(any())).thenAnswer((_) async => authResponse);
      when(() => mockLocalDataSource.saveTokensForProvider(any(), any(), any(), any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.saveProviderData(any(), any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.savePatientId(any(), any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.getConnectedProviderIds()).thenAnswer((_) async => []);

      final result = await repository.login(testProvider);

      expect(result?.patientId, 'PT-123');
      expect(result?.token.accessToken, 'access');
      verify(() => mockLocalDataSource.saveTokensForProvider('test_id', 'access', 'id', 'refresh')).called(1);
      verify(() => mockLocalDataSource.saveProviderData('test_id', any())).called(1);
      verify(() => mockLocalDataSource.savePatientId('test_id', 'PT-123')).called(1);
    });

    test('login returns null on exception', () async {
      when(() => mockAppAuth.authorizeAndExchangeCode(any())).thenThrow(Exception('AppAuth Fail'));

      final result = await repository.login(testProvider);

      expect(result, isNull);
    });

    test('logout clears local data', () async {
      when(() => mockLocalDataSource.clearTokensForProvider(any())).thenAnswer((_) async => {});

      await repository.logout('test_id');

      verify(() => mockLocalDataSource.clearTokensForProvider('test_id')).called(1);
    });

    test('getToken returns OAuthToken if access token exists', () async {
      when(() => mockLocalDataSource.getAccessToken('test_id')).thenAnswer((_) async => 'access');
      when(() => mockLocalDataSource.getIdToken('test_id')).thenAnswer((_) async => 'id');
      when(() => mockLocalDataSource.getRefreshToken('test_id')).thenAnswer((_) async => 'refresh');

      final token = await repository.getToken('test_id');

      expect(token?.accessToken, 'access');
      expect(token?.idToken, 'id');
      expect(token?.refreshToken, 'refresh');
    });

    test('getToken returns null if access token is missing', () async {
      when(() => mockLocalDataSource.getAccessToken('test_id')).thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getIdToken('test_id')).thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getRefreshToken('test_id')).thenAnswer((_) async => null);

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

    test('getProviderDetails returns null if no data', () async {
      when(() => mockLocalDataSource.getProviderData('test_id')).thenAnswer((_) async => null);

      final provider = await repository.getProviderDetails('test_id');

      expect(provider, isNull);
    });

    test('refreshToken success', () async {
      final tokenResponse = TokenResponse(
        'new_access',
        'new_refresh',
        DateTime.now().add(const Duration(hours: 1)),
        'new_id',
        'token_type',
        ['S'],
        {},
      );
      when(() => mockLocalDataSource.getRefreshToken('test_id')).thenAnswer((_) async => 'old_refresh');
      when(() => mockAppAuth.token(any())).thenAnswer((_) async => tokenResponse);
      when(() => mockLocalDataSource.saveTokensForProvider(any(), any(), any(), any())).thenAnswer((_) async => {});

      final token = await repository.refreshToken(testProvider);

      expect(token?.accessToken, 'new_access');
      verify(() => mockLocalDataSource.saveTokensForProvider('test_id', 'new_access', 'new_id', 'new_refresh')).called(1);
    });

    test('refreshToken returns null if no old refresh token', () async {
      when(() => mockLocalDataSource.getRefreshToken('test_id')).thenAnswer((_) async => null);

      final token = await repository.refreshToken(testProvider);

      expect(token, isNull);
    });

    test('refreshToken returns null on exception', () async {
      when(() => mockLocalDataSource.getRefreshToken('test_id')).thenAnswer((_) async => 'old_refresh');
      when(() => mockAppAuth.token(any())).thenThrow(Exception('Fail'));

      final token = await repository.refreshToken(testProvider);

      expect(token, isNull);
    });

    test('getConnectedProviders returns from local data source', () async {
      when(() => mockLocalDataSource.getConnectedProviderIds()).thenAnswer((_) async => ['test_id']);

      final providers = await repository.getConnectedProviders();

      expect(providers, ['test_id']);
    });
  });
}
