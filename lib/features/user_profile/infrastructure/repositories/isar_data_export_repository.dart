import 'package:isar/isar.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/data_export_repository.dart';

/// Isar implementation of [DataExportRepository] for GDPR data export.
@LazySingleton(as: DataExportRepository)
class IsarDataExportRepository implements DataExportRepository {
  final Isar _isar;

  IsarDataExportRepository(this._isar);

  @override
  Future<int> countUserProfiles(String userId) async {
    return await _isar.userProfiles.filter().uniqueIdEqualTo(userId).count();
  }

  @override
  Future<List<Map<String, dynamic>>> getUserProfiles(String userId) async {
    final profiles =
        await _isar.userProfiles.filter().uniqueIdEqualTo(userId).findAll();
    return profiles.map((p) => p.toJson()).toList();
  }

  @override
  Future<int> countMedicalRecords(String userId) async {
    return await _isar.medicalRecords.filter().userIdEqualTo(userId).count();
  }

  @override
  Future<List<Map<String, dynamic>>> getMedicalRecords(String userId) async {
    final records =
        await _isar.medicalRecords.filter().userIdEqualTo(userId).findAll();
    return records.map((r) => r.toJson()).toList();
  }

  @override
  Future<int> countMedications(String userId) async {
    return await _isar.medications.filter().userIdEqualTo(userId).count();
  }

  @override
  Future<List<Map<String, dynamic>>> getMedications(String userId) async {
    final meds =
        await _isar.medications.filter().userIdEqualTo(userId).findAll();
    return meds.map((m) => m.toJson()).toList();
  }

  @override
  Future<int> countAllergies(String userId) async {
    return await _isar.allergies.filter().userIdEqualTo(userId).count();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllergies(String userId) async {
    final allergies =
        await _isar.allergies.filter().userIdEqualTo(userId).findAll();
    return allergies.map((a) => a.toJson()).toList();
  }

  @override
  Future<int> countAppointments(String userId) async {
    return await _isar.appointments.filter().userIdEqualTo(userId).count();
  }

  @override
  Future<List<Map<String, dynamic>>> getAppointments(String userId) async {
    final appts =
        await _isar.appointments.filter().userIdEqualTo(userId).findAll();
    return appts.map((a) => a.toJson()).toList();
  }

  @override
  Future<int> countVitalSigns(String userId) async {
    return await _isar.vitalSigns.filter().userIdEqualTo(userId).count();
  }

  @override
  Future<List<Map<String, dynamic>>> getVitalSigns(String userId) async {
    final vitals =
        await _isar.vitalSigns.filter().userIdEqualTo(userId).findAll();
    return vitals.map((v) => v.toJson()).toList();
  }

  @override
  Future<int> countReports(String userId) async {
    return await _isar.reports.filter().userIdEqualTo(userId).count();
  }

  @override
  Future<List<Map<String, dynamic>>> getReports(String userId) async {
    final reports =
        await _isar.reports.filter().userIdEqualTo(userId).findAll();
    return reports.map((r) => r.toJson()).toList();
  }

  @override
  Future<int> countDoctorProfiles(String userId) async {
    return await _isar.doctorProfiles.filter().userIdEqualTo(userId).count();
  }

  @override
  Future<List<Map<String, dynamic>>> getDoctorProfiles(String userId) async {
    final doctors =
        await _isar.doctorProfiles.filter().userIdEqualTo(userId).findAll();
    return doctors.map((d) => d.toJson()).toList();
  }

  @override
  Future<int> countAppSettings() async {
    return await _isar.appSettings.count();
  }

  @override
  Future<List<Map<String, dynamic>>> getAppSettings() async {
    final settings = await _isar.appSettings.where().findAll();
    return settings.map((s) => s.toJson()).toList();
  }
}