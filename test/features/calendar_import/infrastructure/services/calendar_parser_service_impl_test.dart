import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/calendar_import/infrastructure/services/calendar_parser_service_impl.dart';

void main() {
  group('CalendarParserServiceImpl', () {
    late CalendarParserServiceImpl service;

    setUp(() {
      service = CalendarParserServiceImpl();
    });

    test('parseIcs returns empty list for empty content', () {
      final result = service.parseIcs('');
      expect(result, isEmpty);
    });

    test('parseCsv returns empty list for empty content', () {
      final result = service.parseCsv('');
      expect(result, isEmpty);
    });

    test('parseIcs handles basic ICS format', () {
      const ics = '''
BEGIN:VCALENDAR
BEGIN:VEVENT
SUMMARY:Cita Médica
DTSTART:20240101T100000Z
DTEND:20240101T110000Z
DESCRIPTION:Control general
END:VEVENT
END:VCALENDAR
''';
      final result = service.parseIcs(ics);
      expect(result.length, 1);
      expect(result.first.title, 'Cita Médica');
    });
  });
}
