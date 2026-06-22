import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_event.dart';
import 'package:orionhealth_health/features/calendar_import/infrastructure/services/calendar_parser_service_impl.dart';

void main() {
  late CalendarParserServiceImpl service;

  setUp(() {
    service = CalendarParserServiceImpl();
  });

  group('CalendarParserServiceImpl', () {
    test('parseIcs delegates to CalendarParser', () {
      const ics = '''
BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
SUMMARY:Cita con Dr. House
DTSTART:20231027T100000Z
DESCRIPTION:Chequeo general
END:VEVENT
END:VCALENDAR
''';
      final results = service.parseIcs(ics);
      expect(results.length, 1);
      expect(results[0].title, 'Cita con Dr. House');
    });

    test('parseCsv delegates to CalendarParser', () {
      const csv = '''
Subject,Start Date,Start Time,Description
Cita con Dra. Grey,2023-10-27,09:00:00,Cirugía
''';
      final results = service.parseCsv(csv);
      expect(results.length, 1);
      expect(results[0].title, 'Cita con Dra. Grey');
    });
  });
}
