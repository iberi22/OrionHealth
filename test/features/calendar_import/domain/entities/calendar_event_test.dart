import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_event.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_source.dart';

void main() {
  group('CalendarEvent', () {
    test('should create a CalendarEvent with required values', () {
      final now = DateTime(2026, 6, 10, 10, 0);
      final event = CalendarEvent(
        title: 'Cita con Dr. Smith',
        startDateTime: now,
      );

      expect(event.title, 'Cita con Dr. Smith');
      expect(event.startDateTime, now);
      expect(event.endDateTime, isNull);
      expect(event.description, isNull);
      expect(event.location, isNull);
      expect(event.source, CalendarEventSource.unknown);
    });

    test('should create a CalendarEvent with all values', () {
      final start = DateTime(2026, 6, 10, 10, 0);
      final end = DateTime(2026, 6, 10, 11, 0);
      final event = CalendarEvent(
        title: 'Consulta Médica',
        startDateTime: start,
        endDateTime: end,
        description: 'Chequeo general',
        location: 'Consultorio 301',
        source: CalendarEventSource.deviceCalendar,
      );

      expect(event.title, 'Consulta Médica');
      expect(event.startDateTime, start);
      expect(event.endDateTime, end);
      expect(event.description, 'Chequeo general');
      expect(event.location, 'Consultorio 301');
      expect(event.source, CalendarEventSource.deviceCalendar);
    });

    test('dedupKey should return stable unique key', () {
      final now = DateTime(2026, 6, 10, 10, 0);
      final event1 = CalendarEvent(
        title: 'Cita Médica',
        startDateTime: now,
      );
      final event2 = CalendarEvent(
        title: 'Cita Médica',
        startDateTime: now,
      );
      final event3 = CalendarEvent(
        title: 'Cita Médica',
        startDateTime: now.add(const Duration(hours: 1)),
      );

      expect(event1.dedupKey, event2.dedupKey);
      expect(event1.dedupKey, isNot(event3.dedupKey));
    });

    test('equality should work correctly', () {
      final now = DateTime(2026, 6, 10, 10, 0);
      final event1 = CalendarEvent(
        title: 'Cita',
        startDateTime: now,
        source: CalendarEventSource.icsFile,
      );
      final event2 = CalendarEvent(
        title: 'Cita',
        startDateTime: now,
        source: CalendarEventSource.icsFile,
      );
      final event3 = CalendarEvent(
        title: 'Different',
        startDateTime: now,
      );

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('toString should include title and start date', () {
      final now = DateTime(2026, 6, 10);
      final event = CalendarEvent(
        title: 'Mi Cita',
        startDateTime: now,
      );

      expect(event.toString(), contains('Mi Cita'));
      expect(event.toString(), contains('2026'));
    });
  });

  group('CalendarEventSource', () {
    test('should have expected enum values', () {
      expect(CalendarEventSource.values, hasLength(5));
      expect(CalendarEventSource.values, contains(CalendarEventSource.deviceCalendar));
      expect(CalendarEventSource.values, contains(CalendarEventSource.icsFile));
      expect(CalendarEventSource.values, contains(CalendarEventSource.csvFile));
      expect(CalendarEventSource.values, contains(CalendarEventSource.manual));
      expect(CalendarEventSource.values, contains(CalendarEventSource.unknown));
    });
  });

  group('CalendarSource', () {
    test('should create a CalendarSource with required values', () {
      final source = CalendarSource(
        id: '1',
        name: 'Medical',
      );

      expect(source.id, '1');
      expect(source.name, 'Medical');
      expect(source.isReadOnly, false);
      expect(source.isPrimary, false);
    });

    test('should create a CalendarSource with all values', () {
      final source = CalendarSource(
        id: '2',
        name: 'Work',
        isReadOnly: true,
        isPrimary: false,
      );

      expect(source.id, '2');
      expect(source.name, 'Work');
      expect(source.isReadOnly, true);
      expect(source.isPrimary, false);
    });

    test('equality should be based on id only', () {
      final source1 = CalendarSource(id: '1', name: 'Personal');
      final source2 = CalendarSource(id: '1', name: 'Personal');
      final source3 = CalendarSource(id: '2', name: 'Personal');

      expect(source1, equals(source2));
      expect(source1, isNot(equals(source3)));
    });
  });
}
