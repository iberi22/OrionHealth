import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getAllAppointments();
  Future<List<Appointment>> getUpcomingAppointments();
  Future<List<Appointment>> getPastAppointments();
  Future<Appointment?> getNextAppointment();
  Future<Appointment?> getLastCompletedAppointment();
  Future<Appointment?> getAppointmentById(int id);
  Future<void> saveAppointment(Appointment appointment);
  Future<void> updateAppointmentStatus(int id, AppointmentStatus status);
  Future<void> deleteAppointment(int id);
}
