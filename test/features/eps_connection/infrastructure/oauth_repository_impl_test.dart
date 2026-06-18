import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/data/datasources/oauth_local_datasource.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/repositories/oauth_repository.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/oauth_repository.dart';

class MockOAuthLocalDataSource extends Mock implements OAuthLocalDataSource {}
class MockFlutterAppAuth extends Mock implements FlutterAppAuth {}

// Fallback values for mocktail
class FakeAuthorizationTokenRequest extends Fake implements AuthorizationTokenRequest {}
class FakeTokenRequest extends Fake implements TokenRequest {}

void main() {
  late OAuthRepositoryImpl repository;
  late MockOAuthLocalDataSource mockLocalDataSource;
  late MockFlutterAppAuth mockAppAuth;

  final testProvider = EPSProvider(
    id: 'test_id',
    name: 'Test EPS',
    discoveryUrl: 'https://test.com',
    clientId: 'client',
    redirectUrl: 'url',
    scopes: const ['scope'],
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
    test('login saves tokens and metadata on success', () async {
      final response = AuthorizationTokenResponse(
        'access',
        'refresh',
        DateTime.now().add(const Duration(hours: 1)),
        'id',
        'type',
        <String, dynamic>{'patient': 'PT-123'},
        null,
      );

      when(() => mockAppAuth.authorizeAndExchangeCode(any())).thenAnswer((_) async => response);
      when(() => mockLocalDataSource.saveTokensForProvider(any(), any(), any(), any()))
          .thenAnswer((_) async => {});
      when(() => mockLocalDataSource.saveProviderData(any(), any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.savePatientId(any(), any())).thenAnswer((_) async => {});

      final result = await repository.login(testProvider);

      expect(result?.token.accessToken, 'access');
      expect(result?.patientId, 'PT-123');
      verify(() => mockLocalDataSource.saveTokensForProvider('test_id', 'access', 'id', 'refresh')).called(1);
      verify(() => mockLocalDataSource.saveProviderData('test_id', any())).called(1);
      verify(() => mockLocalDataSource.savePatientId('test_id', 'PT-123')).called(1);
    });

    test('getProviderDetails returns provider from data source', () async {
      final providerMap = {
        'id': 'test_id',
        'name': 'Test EPS',
        'discoveryUrl': 'https://test.com',
        'clientId': 'client',
        'redirectUrl': 'url',
        'scopes': ['scope'],
        'type': 'fhir',
      };
      when(() => mockLocalDataSource.getProviderData('test_id')).thenAnswer((_) async => providerMap);

      final result = await repository.getProviderDetails('test_id');

      expect(result?.name, 'Test EPS');
      expect(result?.type, EPSProviderType.fhir);
    });
  });
}
