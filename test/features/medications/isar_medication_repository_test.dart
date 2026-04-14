import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/medications/infrastructure/repositories/isar_medication_repository.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late IsarMedicationRepository repository;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_medications');
    await Directory(testDir).create(recursive: true);

    // Initialize Isar with the Medication schema
    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [MedicationSchema],
      directory: testDir,
    );
    repository = IsarMedicationRepository(isar);
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

  test('Should save and retrieve a medication', () async {
    final medication = Medication(
      name: 'Ibuprofeno',
      dosage: '400mg',
      frequency: 'Cada 8 horas',
      startDate: DateTime.now(),
      isActive: true,
    );

    await repository.saveMedication(medication);

    final medications = await repository.getAllMedications();
    expect(medications.length, 1);
    expect(medications.first.name, 'Ibuprofeno');
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
