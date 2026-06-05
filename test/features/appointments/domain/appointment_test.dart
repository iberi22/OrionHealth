import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

void main() {
  group('Appointment Model Validation', () {
    test('valid appointment should pass validation', () {
      final appointment = Appointment(
        doctorName: 'Dr. House',
        specialty: 'Diagnostics',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );
      expect(appointment.validate(), isTrue);
    });

    test('appointment with empty doctor name should fail validation', () {
      final appointment = Appointment(
        doctorName: '',
        specialty: 'Diagnostics',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );
      expect(appointment.validate(), isFalse);
    });

    test('appointment with empty specialty should fail validation', () {
      final appointment = Appointment(
        doctorName: 'Dr. House',
        specialty: ' ',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );
      expect(appointment.validate(), isFalse);
    });

    test('appointment with zero duration should fail validation', () {
      final appointment = Appointment(
        doctorName: 'Dr. House',
        specialty: 'Diagnostics',
        dateTime: DateTime.now(),
        durationInMinutes: 0,
        status: AppointmentStatus.upcoming,
      );
      expect(appointment.validate(), isFalse);
    });

    test('appointment with negative duration should fail validation', () {
      final appointment = Appointment(
        doctorName: 'Dr. House',
        specialty: 'Diagnostics',
        dateTime: DateTime.now(),
        durationInMinutes: -15,
        status: AppointmentStatus.upcoming,
      );
      expect(appointment.validate(), isFalse);
    });

    test('isPast should return true for dates in the past', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final appointment = Appointment(
        doctorName: 'Dr. House',
        specialty: 'Diagnostics',
        dateTime: pastDate,
        status: AppointmentStatus.upcoming,
      );
      expect(appointment.isPast, isTrue);
    });

    test('isPast should return false for future dates', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      final appointment = Appointment(
        doctorName: 'Dr. House',
        specialty: 'Diagnostics',
        dateTime: futureDate,
        status: AppointmentStatus.upcoming,
      );
      expect(appointment.isPast, isFalse);
    });
  });
}
