import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_event.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_source.dart';
import 'package:orionhealth_health/features/calendar_import/domain/repositories/calendar_repository.dart';
import 'package:orionhealth_health/features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart';
import 'package:orionhealth_health/features/calendar_import/infrastructure/repositories/calendar_repository_impl.dart';

class MockCalendarApiDatasource extends Mock implements CalendarApiDatasource {}

void main() {
  late CalendarRepositoryImpl repository;
  late MockCalendarApiDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockCalendarApiDatasource();
    repository = CalendarRepositoryImpl(mockDatasource);
  });

  Calendar _makeCalendar(String id, String name, {bool isReadOnly = false}) {
    final cal = Calendar();
    cal.id = id;
    cal.name = name;
    cal.isReadOnly = isReadOnly;
    return cal;
  }

  Event _makeEvent(String calendarId, String eventId, String title, {String? description}) {
    return Event(calendarId, eventId: eventId, title: title, description: description);
  }

  group('CalendarRepositoryImpl', () {
    group('hasPermissions', () {
      test('should delegate to datasource and return true', () async {
        when(() => mockDatasource.hasPermissions()).thenAnswer((_) async => true);

        final result = await repository.hasPermissions();

        expect(result, isTrue);
        verify(() => mockDatasource.hasPermissions()).called(1);
      });

      test('should delegate to datasource and return false', () async {
        when(() => mockDatasource.hasPermissions()).thenAnswer((_) async => false);

        final result = await repository.hasPermissions();

        expect(result, isFalse);
      });
    });

    group('requestPermissions', () {
      test('should delegate to datasource and return true', () async {
        when(() => mockDatasource.requestPermissions()).thenAnswer((_) async => true);

        final result = await repository.requestPermissions();

        expect(result, isTrue);
        verify(() => mockDatasource.requestPermissions()).called(1);
      });

      test('should delegate to datasource and return false', () async {
        when(() => mockDatasource.requestPermissions()).thenAnswer((_) async => false);

        final result = await repository.requestPermissions();

        expect(result, isFalse);
      });
    });

    group('getCalendarSources', () {
      test('should convert device calendars to CalendarSource entities', () async {
        final tDeviceCalendars = [
          _makeCalendar('1', 'Personal'),
          _makeCalendar('2', 'Work', isReadOnly: true),
        ];

        when(() => mockDatasource.getCalendars()).thenAnswer((_) async => tDeviceCalendars);

        final result = await repository.getCalendarSources();

        expect(result, hasLength(2));
        expect(result[0].id, '1');
        expect(result[0].name, 'Personal');
        expect(result[0].isReadOnly, isFalse);
        expect(result[1].id, '2');
        expect(result[1].name, 'Work');
        expect(result[1].isReadOnly, isTrue);
      });

      test('should return empty list when no calendars', () async {
        when(() => mockDatasource.getCalendars()).thenAnswer((_) async => []);

        final result = await repository.getCalendarSources();

        expect(result, isEmpty);
      });
    });

    group('fetchMedicalEvents', () {
      test('should filter and return medical events only', () async {
        final tDeviceCalendars = [
          _makeCalendar('1', 'Personal'),
        ];

        final tAllEvents = <Event>[
          _makeEvent('1', 'e1', 'Cita con Dr. Smith', description: 'Consulta médica'),
          _makeEvent('1', 'e2', 'Lunch', description: 'Almuerzo con amigos'),
          _makeEvent('1', 'e3', 'Examen de sangre', description: 'Lab'),
        ];

        when(() => mockDatasource.getCalendars()).thenAnswer((_) async => tDeviceCalendars);
        when(() => mockDatasource.getEvents('1', startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
            .thenAnswer((_) async => tAllEvents);

        final result = await repository.fetchMedicalEvents();

        expect(result, hasLength(2));
        expect(result[0].title, 'Cita con Dr. Smith');
        expect(result[1].title, 'Examen de sangre');
      });

      test('should cover all medical keywords (case-insensitive)', () async {
        final keywords = [
          'cita',
          'médico',
          'consulta',
          'eps',
          'sura',
          'comfama',
          'sanitas',
          'doctor',
          'especialista',
          'control',
          'examen',
          'procedimiento',
          'odontología',
          'terapia',
          'laboratorio',
          'vacuna',
          'hospital',
          'clínica',
          'salud',
          'pediatría',
          'ginecología',
          'cardiología',
        ];

        final tDeviceCalendars = [_makeCalendar('1', 'Personal')];
        when(() => mockDatasource.getCalendars()).thenAnswer((_) async => tDeviceCalendars);

        for (final keyword in keywords) {
          final event = _makeEvent('1', 'e-$keyword', keyword.toUpperCase());
          when(() => mockDatasource.getEvents('1',
                  startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
              .thenAnswer((_) async => [event]);

          final result = await repository.fetchMedicalEvents();
          expect(result, isNotEmpty, reason: 'Failed for keyword: $keyword');
          expect(result.first.title, keyword.toUpperCase());
        }
      });

      test('should handle null title or description by treating as empty string', () async {
        final tDeviceCalendars = [_makeCalendar('1', 'Personal')];
        final event = Event('1', eventId: 'e1', title: null, description: null);

        when(() => mockDatasource.getCalendars()).thenAnswer((_) async => tDeviceCalendars);
        when(() => mockDatasource.getEvents('1',
                startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
            .thenAnswer((_) async => [event]);

        final result = await repository.fetchMedicalEvents();
        expect(result, isEmpty);
      });

      test('should handle null calendar ids by skipping them', () async {
        final cal = Calendar();
        cal.name = 'No ID Calendar';
        // id intentionally null
        final tDeviceCalendars = [cal];

        when(() => mockDatasource.getCalendars()).thenAnswer((_) async => tDeviceCalendars);

        final result = await repository.fetchMedicalEvents();

        expect(result, isEmpty);
        verifyNever(() => mockDatasource.getEvents(any(), startDate: any(named: 'startDate'), endDate: any(named: 'endDate')));
      });

      test('should use custom date range when provided', () async {
        final tDeviceCalendars = [
          _makeCalendar('1', 'Personal'),
        ];
        final tStartDate = DateTime(2026, 7, 1);
        final tEndDate = DateTime(2026, 7, 31);

        when(() => mockDatasource.getCalendars()).thenAnswer((_) async => tDeviceCalendars);
        when(() => mockDatasource.getEvents('1', startDate: tStartDate, endDate: tEndDate))
            .thenAnswer((_) async => <Event>[]);

        await repository.fetchMedicalEvents(startDate: tStartDate, endDate: tEndDate);

        verify(() => mockDatasource.getEvents('1', startDate: tStartDate, endDate: tEndDate)).called(1);
      });

      test('should set source to deviceCalendar for all medical events', () async {
        final tDeviceCalendars = [
          _makeCalendar('1', 'Personal'),
        ];
        final tMedicalEvent = _makeEvent('1', 'e1', 'Cita médica', description: 'Control');

        when(() => mockDatasource.getCalendars()).thenAnswer((_) async => tDeviceCalendars);
        when(() => mockDatasource.getEvents(any(), startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
            .thenAnswer((_) async => [tMedicalEvent]);

        final result = await repository.fetchMedicalEvents();

        expect(result.first.source, CalendarEventSource.deviceCalendar);
      });

      test('should return empty list when no calendars exist', () async {
        when(() => mockDatasource.getCalendars()).thenAnswer((_) async => []);

        final result = await repository.fetchMedicalEvents();

        expect(result, isEmpty);
      });
    });
  });
}
