import 'package:injectable/injectable.dart';
import '../entities/doctor_profile.dart';
import '../repositories/doctor_profile_repository.dart';

@injectable
class GetAllDoctorsUseCase {
  final DoctorProfileRepository repository;

  GetAllDoctorsUseCase(this.repository);

  Future<List<DoctorProfile>> call() async {
    return repository.getAllDoctorProfiles();
  }
}
