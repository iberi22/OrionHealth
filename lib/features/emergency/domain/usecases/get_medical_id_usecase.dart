/// FEAT-022: Use case for fetching the current Medical ID
library;

import 'package:injectable/injectable.dart';
import '../entities/medical_id.dart';
import '../repositories/medical_id_repository.dart';

@injectable
class GetMedicalIdUseCase {
  final MedicalIdRepository _repo;
  GetMedicalIdUseCase(this._repo);

  Future<MedicalIdEntity?> call(String userId) => _repo.getByUser(userId);
}
