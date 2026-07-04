import 'package:injectable/injectable.dart';
import '../entities/medical_record.dart';
import '../repositories/health_record_repository.dart';

@injectable
class GetAllRecordsUseCase {
  final HealthRecordRepository repository;

  GetAllRecordsUseCase(this.repository);

  Future<List<MedicalRecord>> call() async {
    return repository.getAllRecords();
  }
}
