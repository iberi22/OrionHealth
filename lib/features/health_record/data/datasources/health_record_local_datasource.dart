import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/entities/medical_attachment.dart';

@lazySingleton
class HealthRecordLocalDataSource {
  final Isar _isar;
  HealthRecordLocalDataSource(this._isar);

  Future<List<MedicalRecord>> getAllRecords() =>
      _isar.medicalRecords.where().sortByRecordDateDesc().findAll();

  Future<void> saveRecord(MedicalRecord record) =>
      _isar.writeTxn(() async => _isar.medicalRecords.put(record));

  Future<void> deleteRecord(int id) =>
      _isar.writeTxn(() async => _isar.medicalRecords.delete(id));

  Future<MedicalRecord?> getRecordById(int id) =>
      _isar.medicalRecords.get(id);
}
