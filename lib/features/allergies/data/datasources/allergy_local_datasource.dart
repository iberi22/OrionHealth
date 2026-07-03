import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/allergy.dart';

@lazySingleton
class AllergyLocalDataSource {
  final Isar _isar;

  AllergyLocalDataSource(this._isar);

  Future<List<Allergy>> getAllergies() async {
    return await _isar.allergys.where().findAll();
  }

  Future<void> saveAllergy(Allergy allergy) async {
    await _isar.writeTxn(() async {
      await _isar.allergys.put(allergy);
    });
  }

  Future<void> deleteAllergy(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.allergys.delete(id);
    });
  }
}
