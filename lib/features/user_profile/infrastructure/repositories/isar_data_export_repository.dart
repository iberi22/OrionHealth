import 'package:isar/isar.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/data_export_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../../health_record/domain/entities/medical_record.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../../allergies/domain/entities/allergy.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../doctor_verification/domain/entities/doctor_profile.dart';
import '../../../reports/domain/entities/report.dart';
import '../../../vitals/domain/entities/vital_sign.dart';

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
    return await _isar.medicalRecords.where().count();
  }

  @override
  Future<List<Map<String, dynamic>>> getMedicalRecords(String userId) async {
    final records =
        await _isar.medicalRecords.where().findAll();
    return records.map((r) => r.toJson()).toList();
  }

  @override
  Future<int> countMedications(String userId) async {
    return await _isar.medications.where().count();
  }

  @override
  Future<List<Map<String, dynamic>>> getMedications(String userId) async {
    final meds =
        await _isar.medications.where().findAll();
    return meds.map((m) => m.toJson()).toList();
  }

  @override
  Future<int> countAllergies(String userId) async {
    return await _isar.allergys.where().count();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllergies(String userId) async {
    final allergies =
        await _isar.allergys.where().findAll();
    return allergies.map((a) => a.toJson()).toList();
  }

  @override
  Future<int> countAppointments(String userId) async {
    return await _isar.appointments.where().count();
  }

  @override
  Future<List<Map<String, dynamic>>> getAppointments(String userId) async {
    final appts =
        await _isar.appointments.where().findAll();
    return appts.map((a) => a.toJson()).toList();
  }

  @override
  Future<int> countVitalSigns(String userId) async {
    return await _isar.vitalSigns.where().count();
  }

  @override
  Future<List<Map<String, dynamic>>> getVitalSigns(String userId) async {
    final vitals =
        await _isar.vitalSigns.where().findAll();
    return vitals.map((v) => v.toJson()).toList();
  }

  @override
  Future<int> countReports(String userId) async {
    return await _isar.reports.where().count();
  }

  @override
  Future<List<Map<String, dynamic>>> getReports(String userId) async {
    final reports =
        await _isar.reports.where().findAll();
    return reports.map((r) => r.toJson()).toList();
  }

  @override
  Future<int> countDoctorProfiles(String userId) async {
    return await _isar.doctorProfiles.where().count();
  }

  @override
  Future<List<Map<String, dynamic>>> getDoctorProfiles(String userId) async {
    final doctors =
        await _isar.doctorProfiles.where().findAll();
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
