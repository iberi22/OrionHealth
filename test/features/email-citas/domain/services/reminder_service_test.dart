import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/email-citas/domain/services/reminder_service.dart';

void main() {
  late ReminderService service;

  setUp(() {
    service = ReminderService();
  });

  group('ReminderService', () {
    final appointment = Appointment(
      doctorName: 'Dr. Smith',
      specialty: 'Cardiology',
      dateTime: DateTime(2023, 10, 27, 10, 0),
      status: AppointmentStatus.upcoming,
    );

    test('calculateReminderTime returns time 24 hours before by default', () {
      final reminderTime = service.calculateReminderTime(appointment);
      expect(reminderTime, DateTime(2023, 10, 26, 10, 0));
    });

    test('calculateReminderTime returns time with custom lead time', () {
      final reminderTime = service.calculateReminderTime(
        appointment,
        leadTime: const Duration(hours: 2),
      );
      expect(reminderTime, DateTime(2023, 10, 27, 8, 0));
    });

    test('shouldScheduleReminder returns true if reminder time is in the future', () {
      final futureAppointment = Appointment(
        doctorName: 'Dr. Future',
        specialty: 'Time Travel',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        status: AppointmentStatus.upcoming,
      );
      expect(service.shouldScheduleReminder(futureAppointment), true);
    });

    test('shouldScheduleReminder returns false if reminder time is in the past', () {
      final pastAppointment = Appointment(
        doctorName: 'Dr. Past',
        specialty: 'History',
        dateTime: DateTime.now().subtract(const Duration(hours: 12)),
        status: AppointmentStatus.upcoming,
      );
      expect(service.shouldScheduleReminder(pastAppointment), false);
    });
  });
}
