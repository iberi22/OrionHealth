import '../entities/allergy.dart';

abstract class AllergyRepository {
  Future<List<Allergy>> getAllergies();
  Future<List<Allergy>> getCriticalAllergies();
  Future<Allergy?> getAllergyById(int id);
  Future<void> saveAllergy(Allergy allergy);
  Future<void> deleteAllergy(int id);
}
