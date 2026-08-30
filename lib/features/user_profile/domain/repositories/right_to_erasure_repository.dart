/// Abstract repository for GDPR Right to Erasure operations.
abstract class RightToErasureRepository {
  /// Deletes all user data (PHI, profile, secure storage). **IRREVERSIBLE.**
  /// Returns counts of records deleted per collection.
  Future<ErasureCounts> eraseAllUserData(String userId);
}

class ErasureCounts {
  int userProfile = 0;
  int medicalRecords = 0;
  int medications = 0;
  int allergies = 0;
  int appointments = 0;
  int vitalSigns = 0;
  int reports = 0;
  int doctorProfiles = 0;
  int secureStorageKeysDeleted = 0;

  int get total => userProfile +
      medicalRecords +
      medications +
      allergies +
      appointments +
      vitalSigns +
      reports +
      doctorProfiles;

  Map<String, dynamic> toJson() => {
        'user_profile': userProfile,
        'medical_records': medicalRecords,
        'medications': medications,
        'allergies': allergies,
        'appointments': appointments,
        'vital_signs': vitalSigns,
        'reports': reports,
        'doctor_profiles': doctorProfiles,
        'secure_storage_keys_deleted': secureStorageKeysDeleted,
        'total_db_records': total,
      };
}