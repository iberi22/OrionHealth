import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/repositories/health_record_repository.dart';

@LazySingleton(as: HealthRecordRepository)
class HealthRecordRepositoryImpl implements HealthRecordRepository {
  final Isar _isar;

  HealthRecordRepositoryImpl(this._isar);

  @override
  Future<void> saveRecord(MedicalRecord record) async {
    await _isar.writeTxn(() async {
      await _isar.medicalRecords.put(record);
    });
  }

  @override
  Future<List<MedicalRecord>> getAllRecords() async {
    return await _isar.medicalRecords.where().findAll();
  }
}
