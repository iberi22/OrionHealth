import '../entities/medication.dart';

abstract class MedicationRepository {
  Future<List<Medication>> getAllMedications();
  Future<void> saveMedication(Medication medication);
  Future<void> deleteMedication(int id);
  Stream<List<Medication>> watchMedications();
}
