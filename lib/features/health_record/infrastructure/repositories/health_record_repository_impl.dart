import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../../auth/infrastructure/services/encryption_service.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/repositories/health_record_repository.dart';

@LazySingleton(as: HealthRecordRepository)
class HealthRecordRepositoryImpl implements HealthRecordRepository {
  final Isar _isar;
  final EncryptionService _encryptionService;

  HealthRecordRepositoryImpl(this._isar, this._encryptionService);

  // MedicalRecord.summary is @ignore (never stored in clear); it lives in
  // encryptedSummary. Without this the summary was lost on every save.
  @override
  Future<void> saveRecord(MedicalRecord record) async {
    final summary = record.summary;
    if (summary != null) {
      record.encryptedSummary = await _encryptionService.encryptHealthData(
        summary,
      );
    }
    await _isar.writeTxn(() async {
      await _isar.medicalRecords.put(record);
    });
  }

  @override
  Future<List<MedicalRecord>> getAllRecords() async {
    final records = await _isar.medicalRecords.where().findAll();
    for (final record in records) {
      final encrypted = record.encryptedSummary;
      if (encrypted != null) {
        record.summary = await _encryptionService.decryptHealthData(encrypted);
      }
    }
    return records;
  }
}
