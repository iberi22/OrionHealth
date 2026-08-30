/// FEAT-022: Use case for fetching the current Medical ID
library;

import '../entities/medical_id.dart';
import '../repositories/medical_id_repository.dart';

class GetMedicalIdUseCase {
  final MedicalIdRepository _repo;
  GetMedicalIdUseCase(this._repo);

  Future<MedicalIdEntity?> call(String userId) => _repo.getByUser(userId);
}
