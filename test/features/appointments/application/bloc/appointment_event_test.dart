import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/appointments/application/bloc/appointment_bloc.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

void main() {
  group('AppointmentEvent', () {
    test('LoadAppointments supports value equality', () {
      expect(LoadAppointments(), isA<LoadAppointments>());
    });

    test('SaveAppointment supports value equality', () {
      final appointment = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );
      expect(SaveAppointment(appointment), isA<SaveAppointment>());
    });

    test('DeleteAppointment supports value equality', () {
      expect(DeleteAppointment(1), isA<DeleteAppointment>());
    });
  });
}
