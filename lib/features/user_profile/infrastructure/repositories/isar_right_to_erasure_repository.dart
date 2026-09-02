import 'dart:async';

import 'package:isar/isar.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/right_to_erasure_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../../health_record/domain/entities/medical_record.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../../allergies/domain/entities/allergy.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../doctor_verification/domain/entities/doctor_profile.dart';
import '../../../reports/domain/entities/report.dart';
import '../../../vitals/domain/entities/vital_sign.dart';

/// Isar implementation of [RightToErasureRepository].
/// See [RightToErasureRepository] for IRREVERSIBLE semantics.
@LazySingleton(as: RightToErasureRepository)
class IsarRightToErasureRepository implements RightToErasureRepository {
  final Isar _isar;
  final SecureStorageService _secureStorage;

  IsarRightToErasureRepository(this._isar, this._secureStorage);

  @override
  Future<ErasureCounts> eraseAllUserData(String userId) async {
    final counts = ErasureCounts();

    await _isar.writeTxn(() async {
      // Profile
      counts.userProfile =
          await _isar.userProfiles.filter().uniqueIdEqualTo(userId).count();
      await _isar.userProfiles.filter().uniqueIdEqualTo(userId).deleteAll();

      // Medical records
      counts.medicalRecords =
          await _isar.medicalRecords.where().count();
      await _isar.medicalRecords
          .where()
          .deleteAll();

      // Medications
      counts.medications =
          await _isar.medications.where().count();
      await _isar.medications.where().deleteAll();

      // Allergies
      counts.allergies =
          await _isar.allergys.where().count();
      await _isar.allergys.where().deleteAll();

      // Appointments
      counts.appointments =
          await _isar.appointments.where().count();
      await _isar.appointments
          .where()
          .deleteAll();

      // Vital signs
      counts.vitalSigns =
          await _isar.vitalSigns.where().count();
      await _isar.vitalSigns.where().deleteAll();

      // Reports
      counts.reports =
          await _isar.reports.where().count();
      await _isar.reports.where().deleteAll();

      // Doctor profiles
      counts.doctorProfiles =
          await _isar.doctorProfiles.where().count();
      await _isar.doctorProfiles
          .where()
          .deleteAll();
    });

    // Secure storage (auth tokens, PIN, biometric secrets)
    await _secureStorage.deleteAll();
    counts.secureStorageKeysDeleted = -1; // unknown

    return counts;
  }
}
