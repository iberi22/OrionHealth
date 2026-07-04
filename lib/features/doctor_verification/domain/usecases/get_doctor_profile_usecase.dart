import 'package:injectable/injectable.dart';
import '../entities/doctor_profile.dart';
import '../repositories/doctor_profile_repository.dart';

@injectable
class GetDoctorProfileUseCase {
  final DoctorProfileRepository repository;

  GetDoctorProfileUseCase(this.repository);

  Future<DoctorProfile?> call(String id) async {
    return repository.getDoctorProfile(id);
  }
}
