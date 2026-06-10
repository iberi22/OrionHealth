import '../../../appointments/domain/entities/appointment.dart';

abstract class EmailRepository {
  Future<bool> connectGmail();
  Future<bool> connectOutlook();
  Future<List<Appointment>> fetchParsedAppointments(String provider, String code);
  Future<void> syncToNativeCalendar(Appointment appointment);
}
