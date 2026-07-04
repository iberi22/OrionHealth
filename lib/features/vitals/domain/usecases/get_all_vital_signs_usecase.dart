import 'package:injectable/injectable.dart';
import '../entities/vital_sign.dart';
import '../repositories/vital_sign_repository.dart';

@injectable
class GetAllVitalSignsUseCase {
  final VitalSignRepository repository;

  GetAllVitalSignsUseCase(this.repository);

  Future<List<VitalSign>> call() async {
    return repository.getAllVitalSigns();
  }
}
