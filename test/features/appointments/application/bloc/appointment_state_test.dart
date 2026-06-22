import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/appointments/application/bloc/appointment_bloc.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

void main() {
  group('AppointmentState', () {
    test('initial supports value equality', () {
      expect(const AppointmentState.initial(), const AppointmentState.initial());
    });

    test('loading supports value equality', () {
      expect(const AppointmentState.loading(), const AppointmentState.loading());
    });

    test('loaded supports value equality', () {
      final appointments = <Appointment>[
        Appointment(
          doctorName: 'Dr. Smith',
          specialty: 'Cardiology',
          dateTime: DateTime.now(),
          status: AppointmentStatus.upcoming,
        )
      ];
      expect(AppointmentState.loaded(appointments), AppointmentState.loaded(appointments));
    });

    test('error supports value equality', () {
      expect(const AppointmentState.error('error'), const AppointmentState.error('error'));
    });
  });
}
