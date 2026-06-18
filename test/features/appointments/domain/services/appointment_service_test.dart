import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/domain/services/appointment_service.dart';

void main() {
  late AppointmentService service;

  setUp(() {
    service = AppointmentService();
  });

  group('AppointmentService - hasConflict', () {
    final baseDate = DateTime(2023, 10, 10, 10, 0); // 10:00 AM

    test('should return false if new appointment is cancelled', () {
      final existing = [
        Appointment(
          doctorName: 'Dr. Smith',
          specialty: 'Cardio',
          dateTime: baseDate,
          status: AppointmentStatus.upcoming,
        )
      ];

      final newApp = Appointment(
        doctorName: 'Dr. Jones',
        specialty: 'Neuro',
        dateTime: baseDate,
        status: AppointmentStatus.cancelled,
      );

      final result = service.hasConflict(newApp, existing);
      expect(result, isFalse);
    });

    test('should return true if new appointment overlaps exactly', () {
      final existing = [
        Appointment(
          id: 1,
          doctorName: 'Dr. Smith',
          specialty: 'Cardio',
          dateTime: baseDate,
          status: AppointmentStatus.upcoming,
        )
      ];

      final newApp = Appointment(
        id: 2,
        doctorName: 'Dr. Jones',
        specialty: 'Neuro',
        dateTime: baseDate, // Same time
        status: AppointmentStatus.upcoming,
      );

      final result = service.hasConflict(newApp, existing);
      expect(result, isTrue);
    });

    test('should return false if new appointment starts exactly when existing ends (no overlap)', () {
      final existing = [
        Appointment(
          doctorName: 'Dr. Smith',
          specialty: 'Cardio',
          dateTime: baseDate, // 10:00 - 10:30
          durationInMinutes: 30,
          status: AppointmentStatus.upcoming,
        )
      ];

      final newApp = Appointment(
        doctorName: 'Dr. Jones',
        specialty: 'Neuro',
        dateTime: baseDate.add(const Duration(minutes: 30)), // 10:30 - 11:00
        durationInMinutes: 30,
        status: AppointmentStatus.upcoming,
      );

      final result = service.hasConflict(newApp, existing);
      expect(result, isFalse);
    });

    test('should return false if existing appointment is cancelled', () {
      final existing = [
        Appointment(
          doctorName: 'Dr. Smith',
          specialty: 'Cardio',
          dateTime: baseDate,
          status: AppointmentStatus.cancelled,
        )
      ];

      final newApp = Appointment(
        doctorName: 'Dr. Jones',
        specialty: 'Neuro',
        dateTime: baseDate,
        status: AppointmentStatus.upcoming,
      );

      final result = service.hasConflict(newApp, existing);
      expect(result, isFalse);
    });

    test('should return false if new appointment is after existing', () {
      final existing = [
        Appointment(
          doctorName: 'Dr. Smith',
          specialty: 'Cardio',
          dateTime: baseDate, // 10:00 - 10:30
          durationInMinutes: 30,
          status: AppointmentStatus.upcoming,
        )
      ];

      final newApp = Appointment(
        doctorName: 'Dr. Jones',
        specialty: 'Neuro',
        dateTime: baseDate.add(const Duration(minutes: 60)), // 11:00
        status: AppointmentStatus.upcoming,
      );

      final result = service.hasConflict(newApp, existing);
      expect(result, isFalse);
    });

    test('should return true if new appointment partially overlaps existing', () {
      final existing = [
        Appointment(
          id: 1,
          doctorName: 'Dr. Smith',
          specialty: 'Cardio',
          dateTime: baseDate, // 10:00 - 10:30
          durationInMinutes: 30,
          status: AppointmentStatus.upcoming,
        )
      ];

      final newApp = Appointment(
        id: 2,
        doctorName: 'Dr. Jones',
        specialty: 'Neuro',
        dateTime: baseDate.add(const Duration(minutes: 15)), // 10:15 - 10:45
        durationInMinutes: 30,
        status: AppointmentStatus.upcoming,
      );

      final result = service.hasConflict(newApp, existing);
      expect(result, isTrue);
    });

    test('should return false when comparing an appointment with itself (same ID)', () {
      final app = Appointment(
        id: 1,
        doctorName: 'Dr. Smith',
        specialty: 'Cardio',
        dateTime: baseDate,
        status: AppointmentStatus.upcoming,
      );

      final result = service.hasConflict(app, [app]);
      expect(result, isFalse);
    });

    test('should return true if new appointment entirely encompasses an existing one', () {
      final existing = [
        Appointment(
          id: 1,
          doctorName: 'Dr. Smith',
          specialty: 'Cardio',
          dateTime: baseDate.add(const Duration(minutes: 10)), // 10:10 - 10:20
          durationInMinutes: 10,
          status: AppointmentStatus.upcoming,
        )
      ];

      final newApp = Appointment(
        id: 2,
        doctorName: 'Dr. Jones',
        specialty: 'Neuro',
        dateTime: baseDate, // 10:00 - 10:30
        durationInMinutes: 30,
        status: AppointmentStatus.upcoming,
      );

      final result = service.hasConflict(newApp, existing);
      expect(result, isTrue);
    });

    test('should return true if existing appointment entirely encompasses the new one', () {
      final existing = [
        Appointment(
          id: 1,
          doctorName: 'Dr. Smith',
          specialty: 'Cardio',
          dateTime: baseDate, // 10:00 - 10:30
          durationInMinutes: 30,
          status: AppointmentStatus.upcoming,
        )
      ];

      final newApp = Appointment(
        id: 2,
        doctorName: 'Dr. Jones',
        specialty: 'Neuro',
        dateTime: baseDate.add(const Duration(minutes: 10)), // 10:10 - 10:20
        durationInMinutes: 10,
        status: AppointmentStatus.upcoming,
      );

      final result = service.hasConflict(newApp, existing);
      expect(result, isTrue);
    });

    test('should return true if overlap is at the last millisecond', () {
      final existing = [
        Appointment(
          id: 1,
          doctorName: 'Dr. Smith',
          specialty: 'Cardio',
          dateTime: baseDate, // 10:00:00 - 10:30:00
          durationInMinutes: 30,
          status: AppointmentStatus.upcoming,
        )
      ];

      final newApp = Appointment(
        id: 2,
        doctorName: 'Dr. Jones',
        specialty: 'Neuro',
        dateTime: baseDate.add(const Duration(minutes: 29, seconds: 59, milliseconds: 999)),
        durationInMinutes: 30,
        status: AppointmentStatus.upcoming,
      );

      final result = service.hasConflict(newApp, existing);
      expect(result, isTrue);
    });

    test('should return true if conflict is in the middle of a list', () {
      final existing = [
        Appointment(
          id: 1,
          doctorName: 'Dr. One',
          specialty: 'General',
          dateTime: baseDate.subtract(const Duration(hours: 2)),
          status: AppointmentStatus.upcoming,
        ),
        Appointment(
          id: 2,
          doctorName: 'Dr. Two',
          specialty: 'General',
          dateTime: baseDate,
          status: AppointmentStatus.upcoming,
        ),
        Appointment(
          id: 3,
          doctorName: 'Dr. Three',
          specialty: 'General',
          dateTime: baseDate.add(const Duration(hours: 2)),
          status: AppointmentStatus.upcoming,
        ),
      ];

      final newApp = Appointment(
        id: 4,
        doctorName: 'Dr. New',
        specialty: 'Special',
        dateTime: baseDate.add(const Duration(minutes: 10)),
        status: AppointmentStatus.upcoming,
      );

      final result = service.hasConflict(newApp, existing);
      expect(result, isTrue);
    });
  });

  group('AppointmentService - generateInstances', () {
    final baseDate = DateTime(2023, 10, 10, 10, 0);

    test('should return single instance if recurrenceRule is null', () {
      final app = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardio',
        dateTime: baseDate,
        status: AppointmentStatus.upcoming,
      );

      final instances = service.generateInstances(app);
      expect(instances.length, 1);
      expect(instances.first.dateTime, baseDate);
    });

    test('should return multiple instances for daily recurrence', () {
      final app = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardio',
        dateTime: baseDate,
        status: AppointmentStatus.upcoming,
        recurrenceRule: 'FREQ=DAILY',
      );

      final instances = service.generateInstances(app, count: 5);
      expect(instances.length, 5);
      expect(instances[0].dateTime, baseDate);
      expect(instances[1].dateTime, baseDate.add(const Duration(days: 1)));
      expect(instances[4].dateTime, baseDate.add(const Duration(days: 4)));
    });

    test('should return multiple instances for weekly recurrence', () {
      final app = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardio',
        dateTime: baseDate,
        status: AppointmentStatus.upcoming,
        recurrenceRule: 'FREQ=WEEKLY',
      );

      final instances = service.generateInstances(app, count: 3);
      expect(instances.length, 3);
      expect(instances[0].dateTime, baseDate);
      expect(instances[1].dateTime, baseDate.add(const Duration(days: 7)));
      expect(instances[2].dateTime, baseDate.add(const Duration(days: 14)));
    });

    test('should return single instance for unsupported recurrence rule', () {
      final app = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardio',
        dateTime: baseDate,
        status: AppointmentStatus.upcoming,
        recurrenceRule: 'FREQ=MONTHLY',
      );

      final instances = service.generateInstances(app);
      expect(instances.length, 1);
    });

    test('should return original appointment if recurrenceRule is empty string', () {
      final app = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardio',
        dateTime: baseDate,
        status: AppointmentStatus.upcoming,
        recurrenceRule: '',
      );

      final instances = service.generateInstances(app);
      expect(instances.length, 1);
      expect(instances.first, app);
    });

    test('should return single instance if count is 1', () {
      final app = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardio',
        dateTime: baseDate,
        status: AppointmentStatus.upcoming,
        recurrenceRule: 'FREQ=DAILY',
      );

      final instances = service.generateInstances(app, count: 1);
      expect(instances.length, 1);
      expect(instances.first.dateTime, baseDate);
    });

    test('should return no instances if count is 0', () {
      final app = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardio',
        dateTime: baseDate,
        status: AppointmentStatus.upcoming,
        recurrenceRule: 'FREQ=DAILY',
      );

      final instances = service.generateInstances(app, count: 0);
      expect(instances.length, 0);
    });

    test('should handle year transition (Dec 31st)', () {
      final yearEnd = DateTime(2023, 12, 31, 10, 0);
      final app = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardio',
        dateTime: yearEnd,
        status: AppointmentStatus.upcoming,
        recurrenceRule: 'FREQ=DAILY',
      );

      final instances = service.generateInstances(app, count: 2);
      expect(instances.length, 2);
      expect(instances[0].dateTime, yearEnd);
      expect(instances[1].dateTime, DateTime(2024, 1, 1, 10, 0));
    });

    test('should handle month transition (Jan 31st)', () {
      final monthEnd = DateTime(2024, 1, 31, 10, 0);
      final app = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardio',
        dateTime: monthEnd,
        status: AppointmentStatus.upcoming,
        recurrenceRule: 'FREQ=DAILY',
      );

      final instances = service.generateInstances(app, count: 2);
      expect(instances.length, 2);
      expect(instances[0].dateTime, monthEnd);
      expect(instances[1].dateTime, DateTime(2024, 2, 1, 10, 0));
    });

    test('should handle leap year (Feb 28th 2024)', () {
      final febEnd = DateTime(2024, 2, 28, 10, 0);
      final app = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardio',
        dateTime: febEnd,
        status: AppointmentStatus.upcoming,
        recurrenceRule: 'FREQ=DAILY',
      );

      final instances = service.generateInstances(app, count: 2);
      expect(instances.length, 2);
      expect(instances[0].dateTime, febEnd);
      expect(instances[1].dateTime, DateTime(2024, 2, 29, 10, 0));
    });
  });
}
