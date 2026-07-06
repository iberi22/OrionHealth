import '../../domain/entities/medication.dart';

abstract class PharmacyApiService {
  Future<List<Medication>> searchMedications(String query);
  Future<Medication?> getMedicationDetails(String code);
}
