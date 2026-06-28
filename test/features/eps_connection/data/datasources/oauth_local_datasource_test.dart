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
    dataSource = OAuthLocalDataSource(mockStorage);
  });

  group('OAuthLocalDataSource', () {
    test('saveTokensForProvider writes to storage and updates connected list', () async {
      final expiration = DateTime(2025, 1, 1);
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => {});
      when(() => mockStorage.read(key: 'connected_providers')).thenAnswer((_) async => null);
      when(() => mockStorage.delete(key: any(named: 'key'))).thenAnswer((_) async => {});

      await dataSource.saveTokensForProvider('id1', 'acc', 'id', 'ref', expiresAt: expiration);

      verify(() => mockStorage.write(key: 'oauth_access_token_id1', value: 'acc')).called(1);
      verify(() => mockStorage.write(key: 'oauth_id_token_id1', value: 'id')).called(1);
      verify(() => mockStorage.write(key: 'oauth_refresh_token_id1', value: 'ref')).called(1);
      verify(() => mockStorage.write(key: 'oauth_expires_at_id1', value: expiration.toIso8601String())).called(1);
      verify(() => mockStorage.write(key: 'connected_providers', value: 'id1')).called(1);
    });

    test('getConnectedProviderIds returns list from storage', () async {
      when(() => mockStorage.read(key: 'connected_providers')).thenAnswer((_) async => 'id1,id2');

      final result = await dataSource.getConnectedProviderIds();

      expect(result, ['id1', 'id2']);
    });

    test('getConnectedProviderIds returns empty list if null or empty', () async {
      when(() => mockStorage.read(key: 'connected_providers')).thenAnswer((_) async => null);
      expect(await dataSource.getConnectedProviderIds(), isEmpty);

      when(() => mockStorage.read(key: 'connected_providers')).thenAnswer((_) async => '');
      expect(await dataSource.getConnectedProviderIds(), isEmpty);
    });

    test('clearTokensForProvider removes from storage and list', () async {
      when(() => mockStorage.delete(key: any(named: 'key'))).thenAnswer((_) async => {});
      when(() => mockStorage.read(key: 'connected_providers')).thenAnswer((_) async => 'id1,id2');
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => {});

      await dataSource.clearTokensForProvider('id1');

      verify(() => mockStorage.delete(key: 'oauth_access_token_id1')).called(1);
      verify(() => mockStorage.delete(key: 'oauth_id_token_id1')).called(1);
      verify(() => mockStorage.delete(key: 'oauth_refresh_token_id1')).called(1);
      verify(() => mockStorage.delete(key: 'oauth_expires_at_id1')).called(1);
      verify(() => mockStorage.delete(key: 'oauth_provider_data_id1')).called(1);
      verify(() => mockStorage.delete(key: 'oauth_patient_id_id1')).called(1);
      verify(() => mockStorage.write(key: 'connected_providers', value: 'id2')).called(1);
    });

    test('getters return values from storage', () async {
      final expiration = DateTime(2025, 1, 1);
      when(() => mockStorage.read(key: 'oauth_access_token_id1')).thenAnswer((_) async => 'acc');
      when(() => mockStorage.read(key: 'oauth_id_token_id1')).thenAnswer((_) async => 'id');
      when(() => mockStorage.read(key: 'oauth_refresh_token_id1')).thenAnswer((_) async => 'ref');
      when(() => mockStorage.read(key: 'oauth_expires_at_id1')).thenAnswer((_) async => expiration.toIso8601String());
      when(() => mockStorage.read(key: 'oauth_patient_id_id1')).thenAnswer((_) async => 'pt');

      expect(await dataSource.getAccessToken('id1'), 'acc');
      expect(await dataSource.getIdToken('id1'), 'id');
      expect(await dataSource.getRefreshToken('id1'), 'ref');
      expect(await dataSource.getExpiresAt('id1'), expiration);
      expect(await dataSource.getPatientId('id1'), 'pt');
    });

    test('savePatientId writes to storage', () async {
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value'))).thenAnswer((_) async => {});
      await dataSource.savePatientId('id1', 'pt');
      verify(() => mockStorage.write(key: 'oauth_patient_id_id1', value: 'pt')).called(1);
    });

    test('saveProviderData and getProviderData works with JSON', () async {
      final data = {'name': 'test'};
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value'))).thenAnswer((_) async => {});
      when(() => mockStorage.read(key: 'oauth_provider_data_id1')).thenAnswer((_) async => '{"name":"test"}');

      await dataSource.saveProviderData('id1', data);
      verify(() => mockStorage.write(key: 'oauth_provider_data_id1', value: '{"name":"test"}')).called(1);

      final result = await dataSource.getProviderData('id1');
      expect(result, data);
    });

    test('getProviderData returns null if missing', () async {
      when(() => mockStorage.read(key: 'oauth_provider_data_id1')).thenAnswer((_) async => null);
      expect(await dataSource.getProviderData('id1'), isNull);
    });
  });
}
