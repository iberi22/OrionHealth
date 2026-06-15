import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/calendar_import/infrastructure/calendar_parser.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_event.dart';

void main() {
  late CalendarParser parser;

  setUp(() {
    parser = CalendarParser();
  });

  group('CalendarParser - ICS', () {
    test('should parse valid ICS with medical keywords', () {
      const ics = '''
BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
SUMMARY:Cita con Dr. House
DTSTART:20231027T100000Z
DESCRIPTION:Chequeo general
END:VEVENT
BEGIN:VEVENT
SUMMARY:Almuerzo con amigos
DTSTART:20231027T130000Z
DESCRIPTION:Pizza
END:VEVENT
END:VCALENDAR
''';
      final results = parser.parseIcs(ics);
      expect(results.length, 1);
      expect(results[0].title, 'Cita con Dr. House');
      expect(results[0].source, CalendarEventSource.icsFile);
    });

    test('should handle ICS timezone (Z suffix)', () {
      const ics = '''
BEGIN:VCALENDAR
BEGIN:VEVENT
SUMMARY:Consulta Médica
DTSTART:20231027T100000Z
END:VEVENT
END:VCALENDAR
''';
      final results = parser.parseIcs(ics);
      expect(results.length, 1);
      // Should be converted to local time (non-UTC)
      expect(results[0].startDateTime.isUtc, false);
    });

    test('should deduplicate identical events in ICS', () {
      const ics = '''
BEGIN:VCALENDAR
BEGIN:VEVENT
SUMMARY:Cita Médica
DTSTART:20231027T100000Z
END:VEVENT
BEGIN:VEVENT
SUMMARY:Cita Médica
DTSTART:20231027T100000Z
END:VEVENT
END:VCALENDAR
''';
      final results = parser.parseIcs(ics);
      expect(results.length, 1);
    });

    test('should return empty list for non-medical events', () {
      const ics = '''
BEGIN:VCALENDAR
BEGIN:VEVENT
SUMMARY:Birthday party
DTSTART:20231027T100000Z
DESCRIPTION:Fun celebration
END:VEVENT
END:VCALENDAR
''';
      final results = parser.parseIcs(ics);
      expect(results, isEmpty);
    });
  });

  group('CalendarParser - CSV', () {
    test('should parse valid CSV with medical keywords', () {
      const csv = '''
Subject,Start Date,Start Time,Description
Cita con Dra. Grey,2023-10-27,09:00:00,Cirugía
Partido de fútbol,2023-10-27,18:00:00,Estadio
''';
      final results = parser.parseCsv(csv);
      expect(results.length, 1);
      expect(results[0].title, 'Cita con Dra. Grey');
      expect(results[0].source, CalendarEventSource.csvFile);
      expect(results[0].startDateTime.hour, 9);
    });

    test('should handle malformed CSV rows', () {
      const csv = '''
Subject,Start Date,Start Time,Description
,2023-10-27
''';
      final results = parser.parseCsv(csv);
      expect(results.isEmpty, true);
    });

    test('should deduplicate events in CSV', () {
      const csv = '''
Subject,Start Date,Start Time,Description
Cita Médica,2023-10-27,10:00:00,
Cita Médica,2023-10-27,10:00:00,
''';
      final results = parser.parseCsv(csv);
      expect(results.length, 1);
    });
  });
}
