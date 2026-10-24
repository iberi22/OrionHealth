import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/medications/infrastructure/repositories/isar_medication_repository.dart';
import 'package:orionhealth_health/features/medications/infrastructure/services/pharmacy_api_service.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../../../../helpers/mock_encryption_service.dart';

class MockPharmacyApiService extends Mock implements PharmacyApiService {}

void main() {
  late Isar isar;
  late IsarMedicationRepository repository;
  late String testDir;
  late MockPharmacyApiService mockApiService;
  late FakeEncryptionService fakeEncryptionService;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_medications');
    await Directory(testDir).create(recursive: true);

    // Initialize Isar with the Medication schema
    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open([MedicationSchema], directory: testDir);
    mockApiService = MockPharmacyApiService();
    fakeEncryptionService = FakeEncryptionService();
    repository = IsarMedicationRepository(
      isar,
      mockApiService,
      fakeEncryptionService,
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

  test('Should save and retrieve a medication with encryption', () async {
    final medication = Medication(
      name: 'Ibuprofeno',
      dosage: '400mg',
      frequency: 'Cada 8 horas',
      startDate: DateTime.now(),
      isActive: true,
    );

    await repository.saveMedication(medication);

    // Verify raw data in Isar is encrypted
    final rawMedication = await isar.medications.where().findFirst();
    expect(rawMedication, isNotNull);
    expect(rawMedication!.encryptedName, 'enc:Ibuprofeno');
    expect(rawMedication.encryptedDosage, 'enc:400mg');
    expect(rawMedication.encryptedFrequency, 'enc:Cada 8 horas');

    // Verify repository returns decrypted data
    final medications = await repository.getAllMedications();
    expect(medications.length, 1);
    expect(medications.first.name, 'Ibuprofeno');
    expect(medications.first.dosage, '400mg');
    expect(medications.first.frequency, 'Cada 8 horas');
  });

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
