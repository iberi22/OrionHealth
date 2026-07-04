import 'package:injectable/injectable.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

@injectable
class GetAllMedicationsUseCase {
  final MedicationRepository repository;

  GetAllMedicationsUseCase(this.repository);

  Future<List<Medication>> call() async {
    return repository.getAllMedications();
  }
}
