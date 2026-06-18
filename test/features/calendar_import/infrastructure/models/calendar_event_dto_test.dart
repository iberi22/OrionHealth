import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/calendar_import/infrastructure/models/calendar_event_dto.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_event.dart';

void main() {
  group('CalendarEventDto', () {
    test('fromDeviceCalendar converts device_calendar.Event to DTO', () {
      final now = DateTime.now();
      final event = Event('1',
        eventId: 'e1',
        title: 'Cita',
        description: 'Desc',
        location: 'Loc',
        start: TZDateTime.from(now, local),
        end: TZDateTime.from(now.add(Duration(hours: 1)), local),
      );

      final dto = CalendarEventDto.fromDeviceCalendar(event);

      expect(dto.title, 'Cita');
      expect(dto.startDateTime.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(dto.description, 'Desc');
      expect(dto.location, 'Loc');
    });

    test('fromDeviceCalendar handles null fields', () {
      final event = Event('1', eventId: 'e1', title: null);
      // event.start/end are null by default

      final dto = CalendarEventDto.fromDeviceCalendar(event);

      expect(dto.title, '');
      expect(dto.startDateTime, isA<DateTime>());
      expect(dto.endDateTime, isNull);
    });

    test('fromDeviceCalendar handles when TZDateTime conversion might be needed', () {
      final now = DateTime.now();
      final event = Event('1',
        eventId: 'e1',
        title: 'Cita',
        start: TZDateTime.from(now, local),
        end: TZDateTime.from(now.add(Duration(hours: 1)), local),
      );

      final dto = CalendarEventDto.fromDeviceCalendar(event);
      expect(dto.startDateTime, isNotNull);
    });

    test('toEntity converts to domain entity', () {
      final now = DateTime.now();
      final dto = CalendarEventDto(
        title: 'T',
        startDateTime: now,
        description: 'D',
        location: 'L',
      );

      final entity = dto.toEntity(source: CalendarEventSource.manual);

      expect(entity.title, 'T');
      expect(entity.source, CalendarEventSource.manual);
    });

    test('toJson and fromJson work correctly', () {
      final now = DateTime(2026, 6, 10, 10, 0);
      final dto = CalendarEventDto(
        title: 'T',
        startDateTime: now,
        endDateTime: now.add(Duration(hours: 1)),
        description: 'D',
        location: 'L',
      );

      final json = dto.toJson();
      final fromJson = CalendarEventDto.fromJson(json);

      expect(fromJson.title, 'T');
      expect(fromJson.startDateTime, now);
      expect(fromJson.endDateTime, now.add(Duration(hours: 1)));
      expect(fromJson.description, 'D');
      expect(fromJson.location, 'L');
    });

    test('fromJson handles null endDateTime', () {
      final json = {
        'title': 'T',
        'startDateTime': DateTime.now().toIso8601String(),
        'endDateTime': null,
        'description': 'D',
        'location': 'L',
      };
      final dto = CalendarEventDto.fromJson(json);
      expect(dto.endDateTime, isNull);
    });
  });
}
