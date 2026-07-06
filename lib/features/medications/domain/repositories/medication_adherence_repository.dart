import '../entities/medication_adherence.dart';

abstract class MedicationAdherenceRepository {
  Future<List<MedicationAdherence>> getAdherenceForMedication(int medicationId);
  Future<List<MedicationAdherence>> getAdherenceForDateRange(DateTime start, DateTime end);
  Future<void> saveAdherence(MedicationAdherence adherence);
  Future<void> deleteAdherence(int id);
}
