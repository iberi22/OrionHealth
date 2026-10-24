/// FEAT-022: Use case for updating the Medical ID
library;

import 'package:injectable/injectable.dart';
import '../entities/medical_id.dart';
import '../repositories/medical_id_repository.dart';

@injectable
class UpdateMedicalIdUseCase {
  final MedicalIdRepository _repo;
  UpdateMedicalIdUseCase(this._repo);

  /// Saves the medical ID with `lastUpdated` set to now.
  Future<void> call(MedicalIdEntity medicalId) {
    final updated = medicalId.copyWith(lastUpdated: DateTime.now());
    return _repo.save(updated);
  }
}
