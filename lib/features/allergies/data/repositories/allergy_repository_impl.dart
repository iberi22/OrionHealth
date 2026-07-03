import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/allergy.dart';
import '../../domain/repositories/allergy_repository.dart';
import '../datasources/allergy_local_datasource.dart';

@LazySingleton(as: AllergyRepository)
class AllergyRepositoryImpl implements AllergyRepository {
  final AllergyLocalDataSource _localDataSource;

  AllergyRepositoryImpl(this._localDataSource);

  @override
  Future<List<Allergy>> getAllergies() {
    return _localDataSource.getAllergies();
  }

  @override
  Future<void> saveAllergy(Allergy allergy) {
    return _localDataSource.saveAllergy(allergy);
  }

  @override
  Future<void> deleteAllergy(Id id) {
    return _localDataSource.deleteAllergy(id);
  }
}
