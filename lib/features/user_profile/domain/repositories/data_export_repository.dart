/// Abstract repository for GDPR data export operations.
///
/// Decouples DataExportService from concrete Isar collections
/// (avoids circular dependency with generated `*.g.dart` files).
abstract class DataExportRepository {
  // Profile
  Future<int> countUserProfiles(String userId);
  Future<List<Map<String, dynamic>>> getUserProfiles(String userId);

  // Medical records
  Future<int> countMedicalRecords(String userId);
  Future<List<Map<String, dynamic>>> getMedicalRecords(String userId);

  // Medications
  Future<int> countMedications(String userId);
  Future<List<Map<String, dynamic>>> getMedications(String userId);

  // Allergies
  Future<int> countAllergies(String userId);
  Future<List<Map<String, dynamic>>> getAllergies(String userId);

  // Appointments
  Future<int> countAppointments(String userId);
  Future<List<Map<String, dynamic>>> getAppointments(String userId);

  // Vital signs
  Future<int> countVitalSigns(String userId);
  Future<List<Map<String, dynamic>>> getVitalSigns(String userId);

  // Reports
  Future<int> countReports(String userId);
  Future<List<Map<String, dynamic>>> getReports(String userId);

  // Doctor profiles
  Future<int> countDoctorProfiles(String userId);
  Future<List<Map<String, dynamic>>> getDoctorProfiles(String userId);

  // App settings
  Future<int> countAppSettings();
  Future<List<Map<String, dynamic>>> getAppSettings();
}