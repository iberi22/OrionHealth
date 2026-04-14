import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/allergy.dart';
import '../../domain/repositories/allergy_repository.dart';

@LazySingleton(as: AllergyRepository)
class AllergyRepositoryImpl implements AllergyRepository {
  final Isar _isar;

  AllergyRepositoryImpl(this._isar);

  @override
  Future<List<Allergy>> getAllAllergies() {
    return _isar.allergys.where().findAll();
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

  @override
  Stream<List<Allergy>> watchAllergies() {
    return _isar.allergys.where().watch(fireImmediately: true);
  }
}
