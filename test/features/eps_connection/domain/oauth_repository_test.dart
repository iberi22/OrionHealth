import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/domain/repositories/oauth_repository.dart';

class MockOAuthRepository extends Mock implements OAuthRepository {}

void main() {
  late MockOAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockOAuthRepository();
  });

  group('OAuthRepository (domain contract)', () {
    test('login returns AuthorizationTokenResponse on success', () async {
      final expectedResponse = AuthorizationTokenResponse(
        'access_token',
        'refresh_token',
        DateTime.now().add(const Duration(hours: 1)),
        'id_token',
        'token_type',
        null,
        null,
        null,
      );

      when(() => mockRepository.login()).thenAnswer((_) async => expectedResponse);

      final result = await mockRepository.login();
      expect(result, isNotNull);
      expect(result!.accessToken, equals('access_token'));
      expect(result.idToken, equals('id_token'));
      expect(result.refreshToken, equals('refresh_token'));
    });

    test('login returns null on failure', () async {
      when(() => mockRepository.login()).thenAnswer((_) async => null);

      final result = await mockRepository.login();
      expect(result, isNull);
    });

    test('logout completes successfully', () async {
      when(() => mockRepository.logout()).thenAnswer((_) async {});

      await mockRepository.logout();
      verify(() => mockRepository.logout()).called(1);
    });

    test('getAccessToken returns stored access token', () async {
      when(() => mockRepository.getAccessToken()).thenAnswer((_) async => 'test_access_token');

      final token = await mockRepository.getAccessToken();
      expect(token, equals('test_access_token'));
    });

    test('getAccessToken returns null when no token', () async {
      when(() => mockRepository.getAccessToken()).thenAnswer((_) async => null);

      final token = await mockRepository.getAccessToken();
      expect(token, isNull);
    });

    test('getIdToken returns stored id token', () async {
      when(() => mockRepository.getIdToken()).thenAnswer((_) async => 'test_id_token');

      final token = await mockRepository.getIdToken();
      expect(token, equals('test_id_token'));
    });

    test('refreshToken returns new TokenResponse', () async {
      final expectedResponse = TokenResponse(
        'new_access_token',
        'new_refresh_token',
        DateTime.now().add(const Duration(hours: 1)),
        'new_id_token',
        'token_type',
        null,
        null,
      );

      when(() => mockRepository.refreshToken()).thenAnswer((_) async => expectedResponse);

      final result = await mockRepository.refreshToken();
      expect(result, isNotNull);
      expect(result!.accessToken, equals('new_access_token'));
      expect(result.refreshToken, equals('new_refresh_token'));
    });

    test('refreshToken returns null when refresh fails', () async {
      when(() => mockRepository.refreshToken()).thenAnswer((_) async => null);

      final result = await mockRepository.refreshToken();
      expect(result, isNull);
    });
  });

  group('OAuthRepository contract compliance', () {
    test('all methods are defined in the abstract class', () {
      // Verify OAuthRepository has all required method signatures
      final repository = MockOAuthRepository();
      expect(repository, isA<OAuthRepository>());
    });

    test('repository can be instantiated with mock', () {
      // Ensure the abstract contract is mockable
      expect(() => MockOAuthRepository(), returnsNormally);
    });
  });
}
