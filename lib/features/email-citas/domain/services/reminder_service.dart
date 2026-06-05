import '../../../appointments/domain/entities/appointment.dart';

class ReminderService {
  /// Calculates the time to send a reminder.
  /// Default is 24 hours before the appointment.
  DateTime calculateReminderTime(Appointment appointment, {Duration leadTime = const Duration(hours: 24)}) {
    return appointment.dateTime.subtract(leadTime);
  }

  /// Returns true if a reminder should be scheduled (e.g., appointment is in the future).
  bool shouldScheduleReminder(Appointment appointment) {
    final now = DateTime.now();
    final reminderTime = calculateReminderTime(appointment);
    return reminderTime.isAfter(now);
  }
}
