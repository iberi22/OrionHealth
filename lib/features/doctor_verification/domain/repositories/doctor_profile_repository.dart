import '../entities/doctor_profile.dart';

abstract interface class DoctorProfileRepository {
  Future<DoctorProfile?> getDoctorProfile(String id);
  Future<void> saveDoctorProfile(DoctorProfile profile);
  Future<void> deleteDoctorProfile(String id);
  Future<List<DoctorProfile>> getAllDoctorProfiles();
}
