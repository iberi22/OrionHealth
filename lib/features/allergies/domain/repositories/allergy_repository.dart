import 'package:isar/isar.dart';
import '../entities/allergy.dart';

abstract class AllergyRepository {
  Future<List<Allergy>> getAllergies();
  Future<void> saveAllergy(Allergy allergy);
  Future<void> deleteAllergy(Id id);
}
