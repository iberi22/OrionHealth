import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/domain/services/appointment_service.dart';

void main() {
  late AppointmentService service;

  setUp(() {
    service = AppointmentService();
  });

  group('AppointmentService - Conflict Detection', () {
    final baseTime = DateTime(2025, 5, 20, 10, 0); // 10:00 AM

    test('should detect conflict when appointments overlap perfectly', () {
      final existing = [
        Appointment(
          id: 1,
          doctorName: 'Dr. Smith',
          specialty: 'GP',
          dateTime: baseTime,
          durationInMinutes: 30,
          status: AppointmentStatus.upcoming,
        ),
      ];
      final newApp = Appointment(
        id: 2,
        doctorName: 'Dr. Jones',
        specialty: 'Cardio',
        dateTime: baseTime,
        durationInMinutes: 30,
        status: AppointmentStatus.upcoming,
      );

      final conflict = service.hasConflict(newApp, existing);
      expect(conflict, isTrue);
    });

    test('should detect conflict when new appointment starts during existing one', () {
      final existing = [
        Appointment(
          id: 1,
          doctorName: 'Dr. Smith',
          specialty: 'GP',
          dateTime: baseTime,
          durationInMinutes: 60,
          status: AppointmentStatus.upcoming,
        ),
      ];
      final newApp = Appointment(
        id: 2,
        doctorName: 'Dr. Jones',
        specialty: 'Cardio',
        dateTime: baseTime.add(const Duration(minutes: 30)),
        durationInMinutes: 30,
        status: AppointmentStatus.upcoming,
      );

      expect(service.hasConflict(newApp, existing), isTrue);
    });

    test('should detect conflict when new appointment ends during existing one', () {
      final existing = [
        Appointment(
          id: 1,
          doctorName: 'Dr. Smith',
          specialty: 'GP',
          dateTime: baseTime,
          durationInMinutes: 60,
          status: AppointmentStatus.upcoming,
        ),
      ];
      final newApp = Appointment(
        id: 2,
        doctorName: 'Dr. Jones',
        specialty: 'Cardio',
        dateTime: baseTime.subtract(const Duration(minutes: 30)),
        durationInMinutes: 45,
        status: AppointmentStatus.upcoming,
      );

      expect(service.hasConflict(newApp, existing), isTrue);
    });

    test('should NOT detect conflict when appointments are back-to-back', () {
      final existing = [
        Appointment(
          id: 1,
          doctorName: 'Dr. Smith',
          specialty: 'GP',
          dateTime: baseTime,
          durationInMinutes: 30,
          status: AppointmentStatus.upcoming,
        ),
      ];
      final newApp = Appointment(
        id: 2,
        doctorName: 'Dr. Jones',
        specialty: 'Cardio',
        dateTime: baseTime.add(const Duration(minutes: 30)),
        durationInMinutes: 30,
        status: AppointmentStatus.upcoming,
      );

      expect(service.hasConflict(newApp, existing), isFalse);
    });

    test('should ignore cancelled appointments for conflict detection', () {
      final existing = [
        Appointment(
          id: 1,
          doctorName: 'Dr. Smith',
          specialty: 'GP',
          dateTime: baseTime,
          durationInMinutes: 30,
          status: AppointmentStatus.cancelled,
        ),
      ];
      final newApp = Appointment(
        id: 2,
        doctorName: 'Dr. Jones',
        specialty: 'Cardio',
        dateTime: baseTime,
        durationInMinutes: 30,
        status: AppointmentStatus.upcoming,
      );

      expect(service.hasConflict(newApp, existing), isFalse);
    });

    test('should NOT detect conflict if new appointment is cancelled', () {
      final existing = [
        Appointment(
          id: 1,
          doctorName: 'Dr. Smith',
          specialty: 'GP',
          dateTime: baseTime,
          durationInMinutes: 30,
          status: AppointmentStatus.upcoming,
        ),
      ];
      final newApp = Appointment(
        id: 2,
        doctorName: 'Dr. Jones',
        specialty: 'Cardio',
        dateTime: baseTime,
        durationInMinutes: 30,
        status: AppointmentStatus.cancelled,
      );

      expect(service.hasConflict(newApp, existing), isFalse);
    });
  });

  group('AppointmentService - Recurrence Logic', () {
    final baseTime = DateTime(2025, 5, 20, 10, 0);

    test('should return only one instance if no recurrence rule', () {
      final app = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'GP',
        dateTime: baseTime,
        status: AppointmentStatus.upcoming,
      );

      final instances = service.generateInstances(app);
      expect(instances.length, 1);
      expect(instances.first.dateTime, baseTime);
    });

    test('should generate daily instances', () {
      final app = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'GP',
        dateTime: baseTime,
        status: AppointmentStatus.upcoming,
        recurrenceRule: 'FREQ=DAILY',
      );

      final instances = service.generateInstances(app, count: 5);
      expect(instances.length, 5);
      expect(instances[0].dateTime, baseTime);
      expect(instances[1].dateTime, baseTime.add(const Duration(days: 1)));
      expect(instances[4].dateTime, baseTime.add(const Duration(days: 4)));
    });

    test('should generate weekly instances', () {
      final app = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'GP',
        dateTime: baseTime,
        status: AppointmentStatus.upcoming,
        recurrenceRule: 'FREQ=WEEKLY',
      );

      final instances = service.generateInstances(app, count: 3);
      expect(instances.length, 3);
      expect(instances[0].dateTime, baseTime);
      expect(instances[1].dateTime, baseTime.add(const Duration(days: 7)));
      expect(instances[2].dateTime, baseTime.add(const Duration(days: 14)));
    });
  });
}
