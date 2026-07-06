import '../entities/medication.dart';

abstract class MedicationRepository {
  Future<List<Medication>> getAllMedications();
  Future<void> saveMedication(Medication medication);
  Future<void> deleteMedication(int id);
  Future<List<Medication>> searchMedications(String query);
  Future<Medication?> getMedicationDetails(String code);
}
