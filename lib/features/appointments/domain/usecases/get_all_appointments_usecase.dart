import 'package:injectable/injectable.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

@injectable
class GetAllAppointmentsUseCase {
  final AppointmentRepository repository;

  GetAllAppointmentsUseCase(this.repository);

  Future<List<Appointment>> call() async {
    return repository.getAllAppointments();
  }
}
