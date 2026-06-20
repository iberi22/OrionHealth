import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/datasources/license_registry_local.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/license_registry.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

abstract class IsarCollectionLicense extends IsarCollection<LicenseRegistryLocal> {}
class MockIsarCollection extends Mock implements IsarCollectionLicense {}

class FakeLicenseRegistryLocal extends Fake implements LicenseRegistryLocal {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late LicenseRegistryLocalDataSource dataSource;

  setUpAll(() {
    registerFallbackValue(FakeLicenseRegistryLocal());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    dataSource = LicenseRegistryLocalDataSource(mockIsar);

    // Mock the collection() method which is called by the extension getter
    when(() => mockIsar.collection<LicenseRegistryLocal>()).thenReturn(mockCollection);
  });

  group('LicenseRegistryLocalDataSource (Mocked)', () {
    test('load() should not load assets if database already has data', () async {
      when(() => mockCollection.count()).thenAnswer((_) async => 5);

      await dataSource.load();

      verify(() => mockCollection.count()).called(1);
      verifyNever(() => mockCollection.put(any()));
    });

    test('load() should load assets and put in database if empty', () async {
      when(() => mockCollection.count()).thenAnswer((_) async => 0);
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      final testData = {
        'US': ['hash1', 'hash2'],
        'CO': ['hash3']
      };

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (ByteData? message) async {
           final String key = utf8.decode(message!.buffer.asUint8List());
           if (key == 'assets/data/license_registry.json') {
              return ByteData.view(
                Uint8List.fromList(utf8.encode(json.encode(testData))).buffer
              );
           }
           return null;
        },
      );

      await dataSource.load();

      verify(() => mockCollection.count()).called(1);
      verify(() => mockCollection.put(any())).called(2);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        null,
      );
    });

    test('load() should handle errors gracefully', () async {
      when(() => mockCollection.count()).thenThrow(Exception('Isar error'));

      // Should not throw
      await dataSource.load();

      verify(() => mockCollection.count()).called(1);
    });
  });
}
