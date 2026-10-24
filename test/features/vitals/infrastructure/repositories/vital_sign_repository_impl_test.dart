import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart';
import '../../../../helpers/mock_encryption_service.dart';
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

void main() {
  group('VitalSignRepositoryImpl (Mocked)', () {
    late MockIsar mockIsar;
    late MockIsarCollection mockCollection;
    late VitalSignRepositoryImpl repository;
    late FakeEncryptionService fakeEncryptionService;

    setUpAll(() {
      registerFallbackValue(FakeVitalSign());
      registerFallbackValue(const <VitalSign>[]);
    });

    setUp(() {
      mockIsar = MockIsar();
      mockCollection = MockIsarCollection();
      fakeEncryptionService = FakeEncryptionService();
      repository = VitalSignRepositoryImpl(mockIsar, fakeEncryptionService);

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

      verify(() => mockCollection.put(vital)).called(1);
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

      verify(() => mockCollection.putAll(vitals)).called(1);
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
    late FakeEncryptionService fakeEncryptionService;

    setUpAll(() async {
      testDir = p.join(Directory.current.path, 'test_db_vitals');
      await Directory(testDir).create(recursive: true);

      await Isar.initializeIsarCore(download: true);
      isar = await Isar.open([VitalSignSchema], directory: testDir);
      fakeEncryptionService = FakeEncryptionService();
      repository = VitalSignRepositoryImpl(isar, fakeEncryptionService);
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

    test('Should save and retrieve a vital sign with encryption', () async {
      final vital = VitalSign(
        type: VitalSignType.bloodPressureSystolic,
        value: 120.0,
        dateTime: DateTime.now(),
        notes: 'Normal',
      );

      await repository.saveVitalSign(vital);

      // Verify raw data in Isar is encrypted
      final rawVital = await isar.vitalSigns.where().findFirst();
      expect(rawVital, isNotNull);
      expect(rawVital!.encryptedValue, 'enc:120.0');
      expect(rawVital.encryptedNotes, 'enc:Normal');

      // Verify repository returns decrypted data
      final vitals = await repository.getAllVitalSigns();
      expect(vitals.length, 1);
      expect(vitals.first.value, 120.0);
      expect(vitals.first.notes, 'Normal');
    });
  });
}
