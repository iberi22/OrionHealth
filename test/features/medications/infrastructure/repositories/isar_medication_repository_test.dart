import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/services/secure_storage_service.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/medications/infrastructure/repositories/isar_medication_repository.dart';
import 'package:orionhealth_health/features/medications/infrastructure/services/pharmacy_api_service.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class MockPharmacyApiService extends Mock implements PharmacyApiService {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late Isar isar;
  late IsarMedicationRepository repository;
  late String testDir;
  late MockPharmacyApiService mockApiService;
  late EncryptionService encryptionService;
  late MockSecureStorageService mockSecureStorageService;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_medications');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open([MedicationSchema], directory: testDir);
    mockApiService = MockPharmacyApiService();

    mockSecureStorageService = MockSecureStorageService();
    when(
      () => mockSecureStorageService.containsKey(any()),
    ).thenAnswer((_) async => true);
    when(() => mockSecureStorageService.readSecure(any(), any())).thenAnswer(
      (_) async =>
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
    );

    encryptionService = EncryptionService(mockSecureStorageService);

    repository = IsarMedicationRepository(
      isar,
      mockApiService,
      encryptionService,
    );
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    await isar.writeTxn(() => isar.medications.clear());
  });

  test(
    'Should save and retrieve a medication with encryption using REAL service',
    () async {
      final medication = Medication(
        name: 'Ibuprofeno',
        dosage: '400mg',
        frequency: 'Cada 8 horas',
        startDate: DateTime.now(),
        isActive: true,
      );

      await repository.saveMedication(medication);

      // Verify raw data in Isar is encrypted and not equal to plaintext
      final rawMedication = await isar.medications.where().findFirst();
      expect(rawMedication, isNotNull);

      // It should NOT contain the plaintext string at all
      expect(rawMedication!.encryptedName!.contains('Ibuprofeno'), isFalse);
      expect(rawMedication.encryptedName, isNot('Ibuprofeno'));

      expect(rawMedication.encryptedDosage!.contains('400mg'), isFalse);
      expect(
        rawMedication.encryptedFrequency!.contains('Cada 8 horas'),
        isFalse,
      );

      // Verify repository returns decrypted data
      final medications = await repository.getAllMedications();
      expect(medications.length, 1);
      expect(medications.first.name, 'Ibuprofeno');
      expect(medications.first.dosage, '400mg');
      expect(medications.first.frequency, 'Cada 8 horas');
    },
  );

  test('Should delete a medication', () async {
    final medication = Medication(
      name: 'Paracetamol',
      dosage: '500mg',
      frequency: 'Cada 6 horas',
      startDate: DateTime.now(),
      isActive: true,
    );

    await repository.saveMedication(medication);
    var medications = await repository.getAllMedications();
    expect(medications.length, 1);

    await repository.deleteMedication(medications.first.id);
    medications = await repository.getAllMedications();
    expect(medications.isEmpty, true);
  });
}
