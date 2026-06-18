import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/email-citas/domain/services/reminder_service.dart';

void main() {
  group('Appointment Reminder Logic', () {
    late ReminderService reminderService;

    setUp(() {
      reminderService = ReminderService();
    });

    test('calculateReminderTime should be exactly 24 hours before by default', () {
      final appTime = DateTime(2025, 1, 10, 15, 0);
      final app = Appointment(
        doctorName: 'Dr. Test',
        specialty: 'Testing',
        dateTime: appTime,
        status: AppointmentStatus.upcoming,
      );

      final reminderTime = reminderService.calculateReminderTime(app);
      expect(reminderTime, DateTime(2025, 1, 9, 15, 0));
    });

    test('calculateReminderTime should respect custom lead time', () {
      final appTime = DateTime(2025, 1, 10, 15, 0);
      final app = Appointment(
        doctorName: 'Dr. Test',
        specialty: 'Testing',
        dateTime: appTime,
        status: AppointmentStatus.upcoming,
      );

      final reminderTime = reminderService.calculateReminderTime(app, leadTime: const Duration(hours: 1));
      expect(reminderTime, DateTime(2025, 1, 10, 14, 0));
    });

    test('shouldScheduleReminder should be true for far future appointments', () {
      // 2 days in the future, reminder is in 1 day
      final appTime = DateTime.now().add(const Duration(days: 2));
      final app = Appointment(
        doctorName: 'Dr. Test',
        specialty: 'Testing',
        dateTime: appTime,
        status: AppointmentStatus.upcoming,
      );

      expect(reminderService.shouldScheduleReminder(app), isTrue);
    });

    test('shouldScheduleReminder should be false for past appointments', () {
      final appTime = DateTime.now().subtract(const Duration(hours: 1));
      final app = Appointment(
        doctorName: 'Dr. Test',
        specialty: 'Testing',
        dateTime: appTime,
        status: AppointmentStatus.upcoming,
      );

      expect(reminderService.shouldScheduleReminder(app), isFalse);
    });

    test('shouldScheduleReminder should be false if reminder time is in the past even if appointment is in the future', () {
      // Appointment in 10 hours, but reminder is 24 hours before (which was 14 hours ago)
      final appTime = DateTime.now().add(const Duration(hours: 10));
      final app = Appointment(
        doctorName: 'Dr. Test',
        specialty: 'Testing',
        dateTime: appTime,
        status: AppointmentStatus.upcoming,
      );

      expect(reminderService.shouldScheduleReminder(app), isFalse);
    });
  });
}
