import 'dart:async';

import 'package:isar/isar.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/right_to_erasure_repository.dart';

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
          await _isar.medicalRecords.filter().userIdEqualTo(userId).count();
      await _isar.medicalRecords
          .filter()
          .userIdEqualTo(userId)
          .deleteAll();

      // Medications
      counts.medications =
          await _isar.medications.filter().userIdEqualTo(userId).count();
      await _isar.medications.filter().userIdEqualTo(userId).deleteAll();

      // Allergies
      counts.allergies =
          await _isar.allergies.filter().userIdEqualTo(userId).count();
      await _isar.allergies.filter().userIdEqualTo(userId).deleteAll();

      // Appointments
      counts.appointments =
          await _isar.appointments.filter().userIdEqualTo(userId).count();
      await _isar.appointments
          .filter()
          .userIdEqualTo(userId)
          .deleteAll();

      // Vital signs
      counts.vitalSigns =
          await _isar.vitalSigns.filter().userIdEqualTo(userId).count();
      await _isar.vitalSigns.filter().userIdEqualTo(userId).deleteAll();

      // Reports
      counts.reports =
          await _isar.reports.filter().userIdEqualTo(userId).count();
      await _isar.reports.filter().userIdEqualTo(userId).deleteAll();

      // Doctor profiles
      counts.doctorProfiles =
          await _isar.doctorProfiles.filter().userIdEqualTo(userId).count();
      await _isar.doctorProfiles
          .filter()
          .userIdEqualTo(userId)
          .deleteAll();
    });

    // Secure storage (auth tokens, PIN, biometric secrets)
    await _secureStorage.deleteAll();
    counts.secureStorageKeysDeleted = -1; // unknown

    return counts;
  }
}