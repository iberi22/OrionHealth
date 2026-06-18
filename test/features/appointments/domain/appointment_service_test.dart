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

      // (10:00 < 10:59) AND (10:30 > 10:29) -> TRUE
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

      // (10:30 < 10:30) is FALSE -> FALSE
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
        dateTime: baseDate.add(const Duration(minutes: 30)), // 10:30
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
  });
}
