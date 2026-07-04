import 'package:injectable/injectable.dart';
import '../entities/medical_record.dart';
import '../repositories/health_record_repository.dart';

@injectable
class SaveRecordUseCase {
  final HealthRecordRepository repository;

  SaveRecordUseCase(this.repository);

  Future<void> call(MedicalRecord record) async {
    return repository.saveRecord(record);
  }
}
