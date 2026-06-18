import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/data/datasources/oauth_local_datasource.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late OAuthLocalDataSource dataSource;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    dataSource = OAuthLocalDataSource(storage: mockStorage);
  });

  group('OAuthLocalDataSource', () {
    test('getAccessToken reads from storage', () async {
      when(() => mockStorage.read(key: 'oauth_access_token'))
          .thenAnswer((_) async => 'token123');

      final result = await dataSource.getAccessToken();
      expect(result, equals('token123'));
      verify(() => mockStorage.read(key: 'oauth_access_token')).called(1);
    });

    test('getAccessToken returns null when no token stored', () async {
      when(() => mockStorage.read(key: 'oauth_access_token'))
          .thenAnswer((_) async => null);

      final result = await dataSource.getAccessToken();
      expect(result, isNull);
    });

    test('getIdToken reads from storage', () async {
      when(() => mockStorage.read(key: 'oauth_id_token'))
          .thenAnswer((_) async => 'id_token_value');

      final result = await dataSource.getIdToken();
      expect(result, equals('id_token_value'));
    });

    test('getRefreshToken reads from storage', () async {
      when(() => mockStorage.read(key: 'oauth_refresh_token'))
          .thenAnswer((_) async => 'refresh_value');

      final result = await dataSource.getRefreshToken();
      expect(result, equals('refresh_value'));
    });

    test('saveTokens writes all three tokens', () async {
      when(() => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async => {});

      await dataSource.saveTokens('access1', 'id1', 'refresh1');

      verify(() => mockStorage.write(key: 'oauth_access_token', value: 'access1')).called(1);
      verify(() => mockStorage.write(key: 'oauth_id_token', value: 'id1')).called(1);
      verify(() => mockStorage.write(key: 'oauth_refresh_token', value: 'refresh1')).called(1);
    });

    test('saveTokens with empty values', () async {
      when(() => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async => {});

      await dataSource.saveTokens('', '', '');

      verify(() => mockStorage.write(key: 'oauth_access_token', value: '')).called(1);
      verify(() => mockStorage.write(key: 'oauth_id_token', value: '')).called(1);
      verify(() => mockStorage.write(key: 'oauth_refresh_token', value: '')).called(1);
    });

    test('clearTokens deletes all three token keys', () async {
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async => {});

      await dataSource.clearTokens();

      verify(() => mockStorage.delete(key: 'oauth_access_token')).called(1);
      verify(() => mockStorage.delete(key: 'oauth_id_token')).called(1);
      verify(() => mockStorage.delete(key: 'oauth_refresh_token')).called(1);
    });

    test('clearTokens succeeds even when storage has no tokens', () async {
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async => {});

      await dataSource.clearTokens();

      verify(() => mockStorage.delete(key: 'oauth_access_token')).called(1);
      verify(() => mockStorage.delete(key: 'oauth_id_token')).called(1);
      verify(() => mockStorage.delete(key: 'oauth_refresh_token')).called(1);
    });

    test('round-trip: save then read back tokens', () async {
      final storage = <String, String>{};

      when(() => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((inv) async {
        storage[inv.namedArguments[#key] as String] = inv.namedArguments[#value] as String;
      });

      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((inv) async => storage[inv.namedArguments[#key] as String]);

      await dataSource.saveTokens('roundtrip_access', 'roundtrip_id', 'roundtrip_refresh');

      expect(await dataSource.getAccessToken(), equals('roundtrip_access'));
      expect(await dataSource.getIdToken(), equals('roundtrip_id'));
      expect(await dataSource.getRefreshToken(), equals('roundtrip_refresh'));
    });
  });
}
