import 'package:injectable/injectable.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

@injectable
class SaveMedicationUseCase {
  final MedicationRepository repository;

  SaveMedicationUseCase(this.repository);

  Future<void> call(Medication medication) async {
    return repository.saveMedication(medication);
  }
}
