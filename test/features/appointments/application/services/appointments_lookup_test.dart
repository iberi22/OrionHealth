import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/appointments/application/services/appointments_lookup.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

void main() {
  group('AppointmentsLookup', () {
    test(
      'empty lookup returns false for hasAppointmentsOn and empty list for getAppointmentsOn',
      () {
        final lookup = AppointmentsLookup.empty();
        final now = DateTime.now();

        expect(lookup.hasAppointmentsOn(now), isFalse);
        expect(lookup.getAppointmentsOn(now), isEmpty);
      },
    );

    test('indexes appointments by date normalized to year, month, day', () {
      final date1 = DateTime(2025, 3, 15, 10, 30);
      final date2 = DateTime(2025, 3, 15, 15, 00);
      final date3 = DateTime(2025, 3, 16, 9, 00);

      final app1 = Appointment(
        id: 1,
        doctorName: 'Dr. House',
        specialty: 'Diagnostic',
        dateTime: date1,
        status: AppointmentStatus.upcoming,
      );

      final app2 = Appointment(
        id: 2,
        doctorName: 'Dr. Wilson',
        specialty: 'Oncology',
        dateTime: date2,
        status: AppointmentStatus.upcoming,
      );

      final app3 = Appointment(
        id: 3,
        doctorName: 'Dr. Cuddy',
        specialty: 'Administration',
        dateTime: date3,
        status: AppointmentStatus.completed,
      );

      final lookup = AppointmentsLookup.fromList([app1, app2, app3]);

      // Check March 15 (different time of day query)
      final query1 = DateTime(2025, 3, 15, 0, 0);
      expect(lookup.hasAppointmentsOn(query1), isTrue);
      expect(lookup.getAppointmentsOn(query1), equals([app1, app2]));

      // Check March 16
      final query2 = DateTime(2025, 3, 16, 23, 59);
      expect(lookup.hasAppointmentsOn(query2), isTrue);
      expect(lookup.getAppointmentsOn(query2), equals([app3]));

      // Check March 17
      final query3 = DateTime(2025, 3, 17, 12, 0);
      expect(lookup.hasAppointmentsOn(query3), isFalse);
      expect(lookup.getAppointmentsOn(query3), isEmpty);
    });
  });
}
