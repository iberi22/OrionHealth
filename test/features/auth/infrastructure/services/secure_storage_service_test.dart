import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orionhealth_health/features/auth/infrastructure/secure_storage_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late SecureStorageServiceImpl secureStorage;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureStorage = SecureStorageServiceImpl(storage: mockStorage);
  });

  group('SecureStorageService', () {
    test('write should call storage.write', () async {
      when(() => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).thenAnswer((_) async {});

      await secureStorage.write('test_key', 'test_value');

      verify(() => mockStorage.write(
            key: 'test_key',
            value: 'test_value',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).called(1);
    });

    test('read should call storage.read', () async {
      when(() => mockStorage.read(
            key: any(named: 'key'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).thenAnswer((_) async => 'stored_value');

      final result = await secureStorage.read('test_key');

      expect(result, equals('stored_value'));
      verify(() => mockStorage.read(
            key: 'test_key',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).called(1);
    });

    test('delete should call storage.delete', () async {
      when(() => mockStorage.delete(
            key: any(named: 'key'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).thenAnswer((_) async {});

      await secureStorage.delete('test_key');

      verify(() => mockStorage.delete(
            key: 'test_key',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).called(1);
    });

    test('deleteAll should call storage.deleteAll', () async {
      when(() => mockStorage.deleteAll(
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).thenAnswer((_) async {});

      await secureStorage.deleteAll();

      verify(() => mockStorage.deleteAll(
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).called(1);
    });

    test('containsKey should call storage.containsKey', () async {
      when(() => mockStorage.containsKey(
            key: any(named: 'key'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).thenAnswer((_) async => true);

      final result = await secureStorage.containsKey('test_key');

      expect(result, isTrue);
      verify(() => mockStorage.containsKey(
            key: 'test_key',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).called(1);
    });
  });
}
