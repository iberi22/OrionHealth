import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/appointments/application/appointments_state.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

void main() {
  group('AppointmentsState', () {
    group('AppointmentsInitial', () {
      test('supports value equality', () {
        expect(const AppointmentsInitial(), equals(const AppointmentsInitial()));
      });
      test('props are empty', () {
        expect(const AppointmentsInitial().props, []);
      });
    });

    group('AppointmentsLoading', () {
      test('supports value equality', () {
        expect(const AppointmentsLoading(), equals(const AppointmentsLoading()));
      });
      test('props are empty', () {
        expect(const AppointmentsLoading().props, []);
      });
    });

    group('AppointmentsLoaded', () {
      final appointments = [
        Appointment(
          id: 1,
          doctorName: 'Dr. House',
          specialty: 'Diagnostics',
          dateTime: DateTime.now(),
          status: AppointmentStatus.upcoming,
        ),
      ];

      test('supports value equality', () {
        expect(AppointmentsLoaded(appointments), equals(AppointmentsLoaded(appointments)));
      });

      test('props are correct', () {
        expect(AppointmentsLoaded(appointments).props, [appointments]);
      });

      test('different appointments are not equal', () {
        expect(AppointmentsLoaded(appointments), isNot(equals(const AppointmentsLoaded([]))));
      });
    });

    group('AppointmentsError', () {
      test('supports value equality', () {
        expect(
          const AppointmentsError('err'),
          equals(const AppointmentsError('err')),
        );
      });
      test('different messages are not equal', () {
        expect(
          const AppointmentsError('err1'),
          isNot(equals(const AppointmentsError('err2'))),
        );
      });
      test('props contain message', () {
        expect(const AppointmentsError('err').props, ['err']);
      });
    });
  });
}
