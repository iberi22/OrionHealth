import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/allergy.dart';
import '../../domain/repositories/allergy_repository.dart';
import '../datasources/allergy_local_datasource.dart';
import '../../../auth/infrastructure/services/encryption_service.dart';

@LazySingleton(as: AllergyRepository)
class AllergyRepositoryImpl implements AllergyRepository {
  final AllergyLocalDataSource _localDataSource;
  final EncryptionService _encryptionService;

  AllergyRepositoryImpl(this._localDataSource, {this._encryptionService});

  @override
  Future<List<Allergy>> getAllergies() async {
    final allergies = await _localDataSource.getAllergies();
    for (var allergy in allergies) {
      if (allergy.encryptedAllergen != null) {
        allergy.allergen = await _encryptionService.decryptHealthData(allergy.encryptedAllergen!);
      }
      if (allergy.encryptedNotes != null) {
        allergy.notes = await _encryptionService.decryptHealthData(allergy.encryptedNotes!);
      }
    }
    return allergies;
  }

  @override
  Future<void> saveAllergy(Allergy allergy) async {
    if (allergy.allergen != null) {
      allergy.encryptedAllergen = await _encryptionService.encryptHealthData(allergy.allergen!);
    }
    if (allergy.notes != null) {
      allergy.encryptedNotes = await _encryptionService.encryptHealthData(allergy.notes!);
    }
    return _localDataSource.saveAllergy(allergy);
  }

  @override
  Future<void> deleteAllergy(Id id) {
    return _localDataSource.deleteAllergy(id);
  }
}

