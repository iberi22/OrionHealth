import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/email-citas/domain/services/reminder_service.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

void main() {
  group('ReminderService', () {
    late ReminderService reminderService;
    late Appointment appointment;

    setUp(() {
      reminderService = ReminderService();
      appointment = Appointment(
        doctorName: 'Juan Perez',
        specialty: 'Cardiología',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        status: AppointmentStatus.upcoming,
      );
    });

    test('calculateReminderTime returns correct time with default lead time', () {
      final appointmentTime = DateTime(2025, 5, 20, 10, 0);
      appointment.dateTime = appointmentTime;

      final reminderTime = reminderService.calculateReminderTime(appointment);

      expect(reminderTime, equals(DateTime(2025, 5, 19, 10, 0)));
    });

    test('calculateReminderTime returns correct time with custom lead time', () {
      final appointmentTime = DateTime(2025, 5, 20, 10, 0);
      appointment.dateTime = appointmentTime;

      final reminderTime = reminderService.calculateReminderTime(
        appointment,
        leadTime: const Duration(hours: 2),
      );

      expect(reminderTime, equals(DateTime(2025, 5, 20, 8, 0)));
    });

    test('shouldScheduleReminder returns true for future reminders', () {
      // Appointment in 48 hours, reminder in 24 hours -> should be true
      expect(reminderService.shouldScheduleReminder(appointment), isTrue);
    });

    test('shouldScheduleReminder returns false for past reminders', () {
      // Appointment was 1 hour ago
      appointment.dateTime = DateTime.now().subtract(const Duration(hours: 1));
      expect(reminderService.shouldScheduleReminder(appointment), isFalse);

      // Appointment is in 1 hour, reminder (24h before) is in the past
      appointment.dateTime = DateTime.now().add(const Duration(hours: 1));
      expect(reminderService.shouldScheduleReminder(appointment), isFalse);
    });
  });
}
