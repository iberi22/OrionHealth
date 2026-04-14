import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';

@LazySingleton(as: MedicationRepository)
class IsarMedicationRepository implements MedicationRepository {
  final Isar _isar;

  IsarMedicationRepository(this._isar);

  @override
  Future<List<Medication>> getAllMedications() async {
    return await _isar.medications.where().findAll();
  }

  @override
  Future<void> saveMedication(Medication medication) async {
    await _isar.writeTxn(() async {
      await _isar.medications.put(medication);
    });
  }

  @override
  Future<void> deleteMedication(int id) async {
    await _isar.writeTxn(() async {
      await _isar.medications.delete(id);
    });
  }
}
