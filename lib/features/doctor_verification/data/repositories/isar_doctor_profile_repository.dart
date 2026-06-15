// TODO: migrate from data/ — moved to infrastructure/repositories/isar_doctor_profile_repository.dart
// This file is kept temporarily. Remove after verifying new imports work.

import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/repositories/doctor_profile_repository.dart';

@LazySingleton(as: DoctorProfileRepository)
class IsarDoctorProfileRepository implements DoctorProfileRepository {
  final Isar _isar;

  IsarDoctorProfileRepository(this._isar);

  @override
  Future<DoctorProfile?> getDoctorProfile(String id) async {
    return await _isar.doctorProfiles.filter().idEqualTo(id).findFirst();
  }

  @override
  Future<void> saveDoctorProfile(DoctorProfile profile) async {
    await _isar.writeTxn(() async {
      await _isar.doctorProfiles.put(profile);
    });
  }

  @override
  Future<void> deleteDoctorProfile(String id) async {
    await _isar.writeTxn(() async {
      await _isar.doctorProfiles.filter().idEqualTo(id).deleteAll();
    });
  }

  @override
  Future<List<DoctorProfile>> getAllDoctorProfiles() async {
    return await _isar.doctorProfiles.where().findAll();
  }
}
