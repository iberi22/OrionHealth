import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getAllAppointments();
  Future<void> saveAppointment(Appointment appointment);
  Future<void> deleteAppointment(int id);
}
