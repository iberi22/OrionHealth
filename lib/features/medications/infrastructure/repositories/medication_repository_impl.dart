import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';

@LazySingleton(as: MedicationRepository)
class MedicationRepositoryImpl implements MedicationRepository {
  final Isar _isar;

  MedicationRepositoryImpl(this._isar);

  @override
  Future<List<Medication>> getAllMedications() async {
    return await _isar.medications.where().findAll();
  }

  @override
  Future<List<Medication>> getActiveMedications() async {
    return await _isar.medications
        .filter()
        .statusEqualTo(MedicationStatus.active)
        .findAll();
  }

  @override
  Future<Medication?> getCurrentMedication() async {
    // Get the most recently started active medication
    return await _isar.medications
        .filter()
        .statusEqualTo(MedicationStatus.active)
        .sortByStartDateDesc()
        .findFirst();
  }

  @override
  Future<Medication?> getMedicationById(int id) async {
    return await _isar.medications.get(id);
  }

  @override
  Future<void> saveMedication(Medication medication) async {
    await _isar.writeTxn(() async {
      await _isar.medications.put(medication);
    });
  }

  @override
  Future<void> updateMedicationStatus(int id, MedicationStatus status) async {
    await _isar.writeTxn(() async {
      final medication = await _isar.medications.get(id);
      if (medication != null) {
        final updated = medication.copyWith(status: status);
        await _isar.medications.put(updated);
      }
    });
  }

  @override
  Future<void> deleteMedication(int id) async {
    await _isar.writeTxn(() async {
      await _isar.medications.delete(id);
    });
  }
}
