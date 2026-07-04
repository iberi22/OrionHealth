import 'package:injectable/injectable.dart';
import '../entities/allergy.dart';
import '../repositories/allergy_repository.dart';

@injectable
class SaveAllergyUseCase {
  final AllergyRepository repository;

  SaveAllergyUseCase(this.repository);

  Future<void> call(Allergy allergy) async {
    return repository.saveAllergy(allergy);
  }
}
