import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/allergy.dart';
import '../../domain/repositories/allergy_repository.dart';

@LazySingleton(as: AllergyRepository)
class IsarAllergyRepository implements AllergyRepository {
  final Isar _isar;

  IsarAllergyRepository(this._isar);

  @override
  Future<List<Allergy>> getAllergies() async {
    return _isar.allergys.where().findAll();
  }

  @override
  Future<void> saveAllergy(Allergy allergy) async {
    await _isar.writeTxn(() async {
      await _isar.allergys.put(allergy);
    });
  }

  @override
  Future<void> deleteAllergy(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.allergys.delete(id);
    });
  }
}
