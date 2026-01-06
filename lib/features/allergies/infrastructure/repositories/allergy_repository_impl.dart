import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/allergy.dart';
import '../../domain/repositories/allergy_repository.dart';

@LazySingleton(as: AllergyRepository)
class AllergyRepositoryImpl implements AllergyRepository {
  final Isar _isar;

  AllergyRepositoryImpl(this._isar);

  @override
  Future<List<Allergy>> getAllergies() async {
    return await _isar.allergys.where().findAll();
  }

  @override
  Future<List<Allergy>> getCriticalAllergies() async {
    return await _isar.allergys.filter().isCriticalEqualTo(true).findAll();
  }

  @override
  Future<Allergy?> getAllergyById(int id) async {
    return await _isar.allergys.get(id);
  }

  @override
  Future<void> saveAllergy(Allergy allergy) async {
    await _isar.writeTxn(() async {
      await _isar.allergys.put(allergy);
    });
  }

  @override
  Future<void> deleteAllergy(int id) async {
    await _isar.writeTxn(() async {
      await _isar.allergys.delete(id);
    });
  }
}
