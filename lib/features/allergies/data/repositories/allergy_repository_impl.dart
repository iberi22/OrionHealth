import '../../domain/entities/allergy.dart';
import '../../domain/repositories/allergy_repository.dart';
import '../datasources/allergy_local_datasource.dart';
import '../datasources/allergy_remote_datasource.dart';

class AllergyRepositoryImpl implements AllergyRepository {
  final AllergyLocalDataSource _localDataSource;
  final AllergyRemoteDataSource _remoteDataSource;
  AllergyRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<List<Allergy>> getAllAllergies() => _localDataSource.getAllAllergies();

  @override
  Future<void> saveAllergy(Allergy allergy) => _localDataSource.saveAllergy(allergy);

  @override
  Future<void> deleteAllergy(int id) => _localDataSource.deleteAllergy(id);
}
