import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import 'package:orionhealth_health/core/services/secure_storage_service.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

abstract class IsarCollectionVitalSign extends IsarCollection<VitalSign> {}

class MockIsarCollection extends Mock implements IsarCollectionVitalSign {}

class FakeVitalSign extends Fake implements VitalSign {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  group('VitalSignRepositoryImpl (Mocked)', () {
    late MockIsar mockIsar;
    late MockIsarCollection mockCollection;
    late VitalSignRepositoryImpl repository;
    late EncryptionService encryptionService;
    late MockSecureStorageService mockSecureStorageService;

    setUpAll(() {
      registerFallbackValue(FakeVitalSign());
      registerFallbackValue(const <VitalSign>[]);
    });

    setUp(() {
      mockIsar = MockIsar();
      mockCollection = MockIsarCollection();

      mockSecureStorageService = MockSecureStorageService();
      when(
        () => mockSecureStorageService.containsKey(any()),
      ).thenAnswer((_) async => true);
      when(() => mockSecureStorageService.readSecure(any(), any())).thenAnswer(
        (_) async =>
            '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );

      encryptionService = EncryptionService(mockSecureStorageService);

      repository = VitalSignRepositoryImpl(mockIsar, encryptionService);

      when(() => mockIsar.vitalSigns).thenReturn(mockCollection);
    });

    test('saveVitalSign puts vital sign in collection', () async {
      final vital = VitalSign(
        type: VitalSignType.heartRate,
        value: 75.0,
        dateTime: DateTime.now(),
      );
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.saveVitalSign(vital);

      verify(() => mockCollection.put(any())).called(1);
    });

    test('saveVitalSigns puts all vital signs', () async {
      final vitals = [
        VitalSign(
          type: VitalSignType.heartRate,
          value: 70,
          dateTime: DateTime.now(),
        ),
        VitalSign(
          type: VitalSignType.temperature,
          value: 36.6,
          dateTime: DateTime.now(),
        ),
      ];
      when(() => mockCollection.putAll(any())).thenAnswer((_) async => [1, 2]);

      await repository.saveVitalSigns(vitals);

      verify(() => mockCollection.putAll(any())).called(1);
    });

    test('saveVitalSigns with empty list does nothing', () async {
      await repository.saveVitalSigns([]);
      verifyNever(() => mockCollection.putAll(any()));
    });
  });

  group('VitalSignRepositoryImpl (Real Isar - Encryption)', () {
    late Isar isar;
    late VitalSignRepositoryImpl repository;
    late String testDir;
    late EncryptionService encryptionService;
    late MockSecureStorageService mockSecureStorageService;

    setUpAll(() async {
      testDir = p.join(Directory.current.path, 'test_db_vitals_real');
      await Directory(testDir).create(recursive: true);

      await Isar.initializeIsarCore(download: true);
      isar = await Isar.open([VitalSignSchema], directory: testDir);

      mockSecureStorageService = MockSecureStorageService();
      when(
        () => mockSecureStorageService.containsKey(any()),
      ).thenAnswer((_) async => true);
      when(() => mockSecureStorageService.readSecure(any(), any())).thenAnswer(
        (_) async =>
            '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );

      encryptionService = EncryptionService(mockSecureStorageService);

      repository = VitalSignRepositoryImpl(isar, encryptionService);
    });

    tearDownAll(() async {
      await isar.close();
      if (await Directory(testDir).exists()) {
        await Directory(testDir).delete(recursive: true);
      }
    });

    setUp(() async {
      await isar.writeTxn(() => isar.vitalSigns.clear());
    });

    test(
      'Should save and retrieve a vital sign with real encryption',
      () async {
        final vital = VitalSign(
          type: VitalSignType.bloodPressureSystolic,
          value: 120.0,
          dateTime: DateTime.now(),
          notes: 'Normal',
        );

        final valueBefore = vital.encryptedValue;
        final notesBefore = vital.encryptedNotes;

        await repository.saveVitalSign(vital);

        expect(vital.encryptedValue, valueBefore);
        expect(vital.encryptedNotes, notesBefore);

        // Verify raw data in Isar is encrypted (does not contain plaintext)
        final rawVital = await isar.vitalSigns.where().findFirst();
        expect(rawVital, isNotNull);
        expect(rawVital!.encryptedValue!.contains('120.0'), isFalse);
        expect(rawVital.encryptedNotes!.contains('Normal'), isFalse);

        // Verify repository returns decrypted data
        final vitals = await repository.getAllVitalSigns();
        expect(vitals.length, 1);
        expect(vitals.first.value, 120.0);
        expect(vitals.first.notes, 'Normal');
      },
    );

    test('Should fallback to raw plaintext when decrypt fails', () async {
      await isar.writeTxn(() async {
        final legacyVital = VitalSign(
          type: VitalSignType.bloodPressureSystolic,
          value: 120.0,
          dateTime: DateTime.now(),
        );
        legacyVital.encryptedNotes = 'PlaintextNotes';
        await isar.vitalSigns.put(legacyVital);
      });

      final vitals = await repository.getAllVitalSigns();
      expect(vitals.length, 1);
      expect(vitals.first.notes, 'PlaintextNotes');
    });
  });
}
