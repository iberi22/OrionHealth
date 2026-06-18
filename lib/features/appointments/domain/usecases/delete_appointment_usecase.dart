import 'package:injectable/injectable.dart';
import '../repositories/appointment_repository.dart';

@injectable
class DeleteAppointmentUseCase {
  final AppointmentRepository repository;

  DeleteAppointmentUseCase(this.repository);

  Future<void> call(int id) async {
    return repository.deleteAppointment(id);
  }
}
