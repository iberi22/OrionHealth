import '../entities/allergy.dart';

abstract class AllergyRepository {
  Future<List<Allergy>> getAllAllergies();
  Future<void> saveAllergy(Allergy allergy);
  Future<void> deleteAllergy(int id);
  Stream<List<Allergy>> watchAllergies();
}
