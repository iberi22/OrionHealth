import '../../../vitals/domain/entities/vital_sign.dart';
import '../../../vitals/domain/repositories/vital_sign_repository.dart';

class GetHealthSummaryUseCase {
  final VitalSignRepository _repository;

  GetHealthSummaryUseCase(this._repository);

  Future<Map<VitalSignType, VitalSign?>> execute() async {
    return await _repository.getLatestVitals();
  }
}
