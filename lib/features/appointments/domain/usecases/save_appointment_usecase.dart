import 'package:injectable/injectable.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

@injectable
class SaveAppointmentUseCase {
  final AppointmentRepository repository;

  SaveAppointmentUseCase(this.repository);

  Future<void> call(Appointment appointment) async {
    return repository.saveAppointment(appointment);
  }
}
