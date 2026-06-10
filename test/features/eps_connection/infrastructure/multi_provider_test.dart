import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/repositories/oauth_repository_impl.dart';

class MockFlutterAppAuth extends Mock implements FlutterAppAuth {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterAppAuth mockAppAuth;
  late MockFlutterSecureStorage mockSecureStorage;
  final Map<String, String> storage = {};

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
    storage.clear();

    when(() => mockSecureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((inv) async {
      storage[inv.namedArguments[#key] as String] = inv.namedArguments[#value] as String;
    });

    when(() => mockSecureStorage.read(key: any(named: 'key')))
        .thenAnswer((inv) async => storage[inv.namedArguments[#key] as String]);
  });

  group('OAuthRepositoryImpl Multi-Provider', () {
    test('two instances with different keys do not conflict', () async {
      final repo1 = OAuthRepositoryImpl(
        appAuth: mockAppAuth,
        secureStorage: mockSecureStorage,
        clientId: 'provider-1',
        accessTokenKey: 'p1_access',
        idTokenKey: 'p1_id',
        refreshTokenKey: 'p1_refresh',
      );

      final repo2 = OAuthRepositoryImpl(
        appAuth: mockAppAuth,
        secureStorage: mockSecureStorage,
        clientId: 'provider-2',
        accessTokenKey: 'p2_access',
        idTokenKey: 'p2_id',
        refreshTokenKey: 'p2_refresh',
      );

      final response1 = AuthorizationTokenResponse(
        'token-1',
        'refresh-1',
        DateTime.now(),
        'id-1',
        'type',
        null,
        null,
        null,
      );

      final response2 = AuthorizationTokenResponse(
        'token-2',
        'refresh-2',
        DateTime.now(),
        'id-2',
        'type',
        null,
        null,
        null,
      );

      when(() => mockAppAuth.authorizeAndExchangeCode(any()))
          .thenAnswer((inv) async {
            final req = inv.positionalArguments[0] as AuthorizationTokenRequest;
            return req.clientId == 'provider-1' ? response1 : response2;
          });

      await repo1.login();
      await repo2.login();

      expect(await repo1.getAccessToken(), 'token-1');
      expect(await repo2.getAccessToken(), 'token-2');
      expect(storage['p1_access'], 'token-1');
      expect(storage['p2_access'], 'token-2');
    });
  });
}
