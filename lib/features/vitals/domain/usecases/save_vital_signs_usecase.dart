import 'package:injectable/injectable.dart';
import '../entities/vital_sign.dart';
import '../repositories/vital_sign_repository.dart';

@injectable
class SaveVitalSignsUseCase {
  final VitalSignRepository repository;

  SaveVitalSignsUseCase(this.repository);

  Future<void> call(List<VitalSign> vitalSigns) async {
    return repository.saveVitalSigns(vitalSigns);
  }
}
