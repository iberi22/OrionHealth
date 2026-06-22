import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/services/secure_storage_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageServiceImpl service;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageServiceImpl(storage: mockStorage);
  });

  group('SecureStorageServiceImpl', () {
    test('write calls storage.write', () async {
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      await service.write('testKey', 'testValue');

      verify(() => mockStorage.write(key: 'testKey', value: 'testValue')).called(1);
    });

    test('read calls storage.read', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'testValue');

      final result = await service.read('testKey');

      expect(result, 'testValue');
      verify(() => mockStorage.read(key: 'testKey')).called(1);
    });

    test('delete calls storage.delete', () async {
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      await service.delete('testKey');

      verify(() => mockStorage.delete(key: 'testKey')).called(1);
    });

    test('deleteAll calls storage.deleteAll', () async {
      when(() => mockStorage.deleteAll())
          .thenAnswer((_) async {});

      await service.deleteAll();

      verify(() => mockStorage.deleteAll()).called(1);
    });

    test('containsKey calls storage.containsKey', () async {
      when(() => mockStorage.containsKey(key: any(named: 'key')))
          .thenAnswer((_) async => true);

      final result = await service.containsKey('testKey');

      expect(result, true);
      verify(() => mockStorage.containsKey(key: 'testKey')).called(1);
    });

    test('writeSecure calls storage.write with hashed key', () async {
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      await service.writeSecure('auth', 'token', 'secret');

      verify(() => mockStorage.write(
            key: any(named: 'key', that: startsWith('auth:')),
            value: 'secret',
          )).called(1);
    });

    test('readSecure calls storage.read with hashed key', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'secret');

      final result = await service.readSecure('auth', 'token');

      expect(result, 'secret');
      verify(() => mockStorage.read(
            key: any(named: 'key', that: startsWith('auth:')),
          )).called(1);
    });

    test('writeJson serializes and calls write', () async {
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});
      final data = {'id': 1, 'name': 'test'};

      await service.writeJson('config', data);

      verify(() => mockStorage.write(
            key: 'config',
            value: jsonEncode(data),
          )).called(1);
    });

    test('readJson deserializes and returns map', () async {
      final data = {'id': 1, 'name': 'test'};
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => jsonEncode(data));

      final result = await service.readJson('config');

      expect(result, data);
      verify(() => mockStorage.read(key: 'config')).called(1);
    });

    test('readJson returns null if value is null', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final result = await service.readJson('config');

      expect(result, null);
    });
  });
}
