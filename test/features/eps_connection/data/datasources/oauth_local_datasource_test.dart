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
    test('saveTokensForProvider writes to storage and updates connected list', () async {
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => {});
      when(() => mockStorage.read(key: 'connected_providers')).thenAnswer((_) async => null);

      await dataSource.saveTokensForProvider('id1', 'acc', 'id', 'ref');

      verify(() => mockStorage.write(key: 'oauth_access_token_id1', value: 'acc')).called(1);
      verify(() => mockStorage.write(key: 'connected_providers', value: 'id1')).called(1);
    });

    test('getConnectedProviderIds returns list from storage', () async {
      when(() => mockStorage.read(key: 'connected_providers')).thenAnswer((_) async => 'id1,id2');

      final result = await dataSource.getConnectedProviderIds();

      expect(result, ['id1', 'id2']);
    });

    test('clearTokensForProvider removes from storage and list', () async {
      when(() => mockStorage.delete(key: any(named: 'key'))).thenAnswer((_) async => {});
      when(() => mockStorage.read(key: 'connected_providers')).thenAnswer((_) async => 'id1,id2');
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => {});

      await dataSource.clearTokensForProvider('id1');

      verify(() => mockStorage.delete(key: 'oauth_access_token_id1')).called(1);
      verify(() => mockStorage.write(key: 'connected_providers', value: 'id2')).called(1);
    });
  });
}
