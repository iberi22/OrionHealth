import 'package:isar/isar.dart';
import '../../domain/entities/allergy.dart';
import '../../domain/repositories/allergy_repository.dart';

class IsarAllergyRepository implements AllergyRepository {
  final Isar _isar;

  IsarAllergyRepository(this._isar);

  @override
  Future<List<Allergy>> getAllergies() async {
    return _isar.collection<Allergy>().where().findAll();
  }

  @override
  Future<void> saveAllergy(Allergy allergy) async {
    await _isar.writeTxn(() async {
      await _isar.collection<Allergy>().put(allergy);
    });
  }

  @override
  Future<void> deleteAllergy(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.collection<Allergy>().delete(id);
    });
  }
}
