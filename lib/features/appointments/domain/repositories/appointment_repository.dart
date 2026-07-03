import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getAppointments();
  Future<void> saveAppointment(Appointment appointment);
  Future<void> deleteAppointment(int id);
}
