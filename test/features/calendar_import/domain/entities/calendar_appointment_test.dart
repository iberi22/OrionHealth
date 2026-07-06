import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_appointment.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_event.dart';

void main() {
  group('CalendarAppointment', () {
    final tDateTime = DateTime(2025, 1, 1, 10, 0);

    test('should support value equality', () {
      final a1 = CalendarAppointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: tDateTime,
        notes: 'Checkup',
        source: CalendarEventSource.deviceCalendar,
      );
      final a2 = CalendarAppointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: tDateTime,
        notes: 'Checkup',
        source: CalendarEventSource.deviceCalendar,
      );

      expect(a1, equals(a2));
    });

    test('should have different hashCodes for different values', () {
      final a1 = CalendarAppointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: tDateTime,
      );
      final a2 = CalendarAppointment(
        doctorName: 'Dr. Jones',
        specialty: 'Cardiology',
        dateTime: tDateTime,
      );

      expect(a1.hashCode, isNot(equals(a2.hashCode)));
    });

    test('toString should return correct string representation', () {
      final a1 = CalendarAppointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: tDateTime,
      );

      expect(a1.toString(), contains('Dr. Smith'));
      expect(a1.toString(), contains('Cardiology'));
    });
  });
}
