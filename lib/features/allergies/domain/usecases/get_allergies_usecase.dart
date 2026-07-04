import 'package:injectable/injectable.dart';
import '../entities/allergy.dart';
import '../repositories/allergy_repository.dart';

@injectable
class GetAllergiesUseCase {
  final AllergyRepository repository;

  GetAllergiesUseCase(this.repository);

  Future<List<Allergy>> call() async {
    return repository.getAllergies();
  }
}
