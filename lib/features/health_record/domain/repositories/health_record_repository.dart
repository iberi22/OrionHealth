import '../../domain/entities/medical_record.dart';

abstract class HealthRecordRepository {
  Future<void> saveRecord(MedicalRecord record);
  Future<List<MedicalRecord>> getAllRecords();
}
