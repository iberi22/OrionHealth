import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/allergies/infrastructure/repositories/isar_allergy_repository.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late IsarAllergyRepository repository;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_allergies_enhanced');
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [AllergySchema],
      directory: testDir,
    );
    repository = IsarAllergyRepository(isar);
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    await isar.writeTxn(() => isar.allergys.clear());
  });

  group('IsarAllergyRepository', () {
    test('Should return an empty list when no allergies exist', () async {
      final allergies = await repository.getAllergies();
      expect(allergies, isEmpty);
    });

    test('Should save and retrieve an allergy', () async {
      final allergy = Allergy(
        allergen: 'Peanuts',
        severity: AllergySeverity.severe,
        notes: 'Strict avoidance',
      );

      await repository.saveAllergy(allergy);

      final allergies = await repository.getAllergies();
      expect(allergies.length, 1);
      expect(allergies.first.allergen, 'Peanuts');
      expect(allergies.first.severity, AllergySeverity.severe);
      expect(allergies.first.notes, 'Strict avoidance');
    });

    test('Should update an existing allergy and persist all fields', () async {
      final allergy = Allergy(
        allergen: 'Pollen',
        severity: AllergySeverity.mild,
        notes: 'Initial note',
      );

      await repository.saveAllergy(allergy);

      final savedAllergies = await repository.getAllergies();
      final savedAllergy = savedAllergies.first;

      savedAllergy.allergen = 'Updated Pollen';
      savedAllergy.severity = AllergySeverity.moderate;
      savedAllergy.notes = 'Updated note';

      await repository.saveAllergy(savedAllergy);

      final updatedAllergies = await repository.getAllergies();
      expect(updatedAllergies.length, 1);
      expect(updatedAllergies.first.id, savedAllergy.id);
      expect(updatedAllergies.first.allergen, 'Updated Pollen');
      expect(updatedAllergies.first.severity, AllergySeverity.moderate);
      expect(updatedAllergies.first.notes, 'Updated note');
    });

    test('Should delete an allergy', () async {
      final allergy = Allergy(
        allergen: 'Dust',
        severity: AllergySeverity.mild,
      );

      await repository.saveAllergy(allergy);
      var allergies = await repository.getAllergies();
      expect(allergies.length, 1);

      await repository.deleteAllergy(allergies.first.id);
      allergies = await repository.getAllergies();
      expect(allergies.isEmpty, true);
    });

    test('Should not fail when deleting a non-existent allergy ID', () async {
      await expectLater(repository.deleteAllergy(999), completes);
    });

    test('Should return multiple allergies and maintain their order/data', () async {
      await repository.saveAllergy(Allergy(allergen: 'A1', severity: AllergySeverity.mild));
      await repository.saveAllergy(Allergy(allergen: 'A2', severity: AllergySeverity.moderate));
      await repository.saveAllergy(Allergy(allergen: 'A3', severity: AllergySeverity.severe));

      final allergies = await repository.getAllergies();
      expect(allergies.length, 3);

      final a1 = allergies.firstWhere((a) => a.allergen == 'A1');
      expect(a1.severity, AllergySeverity.mild);

      final a2 = allergies.firstWhere((a) => a.allergen == 'A2');
      expect(a2.severity, AllergySeverity.moderate);

      final a3 = allergies.firstWhere((a) => a.allergen == 'A3');
      expect(a3.severity, AllergySeverity.severe);
    });
  });
}
