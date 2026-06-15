import '../../domain/entities/medical_record.dart';
import '../../domain/repositories/health_record_repository.dart';
import '../datasources/health_record_local_datasource.dart';

class HealthRecordRepositoryImpl implements HealthRecordRepository {
  final HealthRecordLocalDataSource _localDataSource;
  HealthRecordRepositoryImpl(this._localDataSource);

  @override
  Future<void> saveRecord(MedicalRecord r) => _localDataSource.saveRecord(r);
  @override
  Future<List<MedicalRecord>> getAllRecords() => _localDataSource.getAllRecords();
}
