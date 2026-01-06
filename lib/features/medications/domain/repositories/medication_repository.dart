import '../entities/medication.dart';

abstract class MedicationRepository {
  Future<List<Medication>> getAllMedications();
  Future<List<Medication>> getActiveMedications();
  Future<Medication?> getCurrentMedication();
  Future<Medication?> getMedicationById(int id);
  Future<void> saveMedication(Medication medication);
  Future<void> updateMedicationStatus(int id, MedicationStatus status);
  Future<void> deleteMedication(int id);
}
