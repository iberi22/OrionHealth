import 'dart:collection';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart';

class MockDeviceCalendarPlugin extends Mock implements DeviceCalendarPlugin {}

void main() {
  late CalendarApiDatasource datasource;
  late MockDeviceCalendarPlugin mockPlugin;

  setUp(() {
    mockPlugin = MockDeviceCalendarPlugin();
    datasource = CalendarApiDatasource(deviceCalendarPlugin: mockPlugin);
  });

  Result<T> _successResult<T>(T data) {
    final result = Result<T>();
    result.data = data;
    result.errors = [];
    return result;
  }

  Result<T> _errorResult<T>() {
    final result = Result<T>();
    result.data = null;
    result.errors = [ResultError(1, 'error')];
    return result;
  }

  group('CalendarApiDatasource', () {
    group('hasPermissions', () {
      test('should return true when permissions are granted', () async {
        when(() => mockPlugin.hasPermissions()).thenAnswer(
          (_) async => _successResult(true),
        );

        final result = await datasource.hasPermissions();

        expect(result, isTrue);
        verify(() => mockPlugin.hasPermissions()).called(1);
      });

      test('should return false when permissions are denied', () async {
        final r = Result<bool>();
        r.data = false;
        r.errors = [];
        when(() => mockPlugin.hasPermissions()).thenAnswer(
          (_) async => r,
        );

        final result = await datasource.hasPermissions();

        expect(result, isFalse);
      });

      test('should return false when Result has errors', () async {
        when(() => mockPlugin.hasPermissions()).thenAnswer(
          (_) async => _errorResult<bool>(),
        );

        final result = await datasource.hasPermissions();

        expect(result, isFalse);
      });

      test('should return false when data is null', () async {
        final r = Result<bool>();
        r.data = null;
        r.errors = [];
        when(() => mockPlugin.hasPermissions()).thenAnswer(
          (_) async => r,
        );

        final result = await datasource.hasPermissions();

        expect(result, isFalse);
      });
    });

    group('requestPermissions', () {
      test('should return true when permissions are granted', () async {
        when(() => mockPlugin.requestPermissions()).thenAnswer(
          (_) async => _successResult(true),
        );

        final result = await datasource.requestPermissions();

        expect(result, isTrue);
        verify(() => mockPlugin.requestPermissions()).called(1);
      });

      test('should return false when permissions are denied', () async {
        final r = Result<bool>();
        r.data = false;
        r.errors = [];
        when(() => mockPlugin.requestPermissions()).thenAnswer(
          (_) async => r,
        );

        final result = await datasource.requestPermissions();

        expect(result, isFalse);
      });

      test('should return false on error', () async {
        when(() => mockPlugin.requestPermissions()).thenAnswer(
          (_) async => _errorResult<bool>(),
        );

        final result = await datasource.requestPermissions();

        expect(result, isFalse);
      });
    });

    group('getCalendars', () {
      test('should return list of calendars on success', () async {
        final calendar1 = Calendar();
        calendar1.id = '1';
        calendar1.name = 'Personal';

        final calendar2 = Calendar();
        calendar2.id = '2';
        calendar2.name = 'Work';

        final calendars = UnmodifiableListView<Calendar>([calendar1, calendar2]);
        when(() => mockPlugin.retrieveCalendars()).thenAnswer(
          (_) async => _successResult(calendars),
        );

        final result = await datasource.getCalendars();

        expect(result, hasLength(2));
        expect(result[0].id, '1');
        expect(result[1].id, '2');
      });

      test('should return empty list when data is null', () async {
        when(() => mockPlugin.retrieveCalendars()).thenAnswer(
          (_) async => _errorResult<UnmodifiableListView<Calendar>>(),
        );

        final result = await datasource.getCalendars();

        expect(result, isEmpty);
      });

      test('should return empty list on error', () async {
        final r = Result<UnmodifiableListView<Calendar>>();
        r.data = null;
        r.errors = [];
        when(() => mockPlugin.retrieveCalendars()).thenAnswer(
          (_) async => r,
        );

        final result = await datasource.getCalendars();

        expect(result, isEmpty);
      });
    });

    group('getEvents', () {
      final tCalendarId = 'cal1';
      final tStartDate = DateTime(2026, 6, 1);
      final tEndDate = DateTime(2026, 6, 30);

      test('should return events for the given calendar and date range', () async {
        final event = Event(tCalendarId, eventId: 'e1', title: 'Doctor Appointment');
        final events = UnmodifiableListView<Event>([event]);

        when(() => mockPlugin.retrieveEvents(
              any(),
              any(),
            )).thenAnswer(
          (_) async => _successResult(events),
        );

        final result = await datasource.getEvents(
          tCalendarId,
          startDate: tStartDate,
          endDate: tEndDate,
        );

        expect(result, hasLength(1));
        expect(result[0].eventId, 'e1');
        verify(() => mockPlugin.retrieveEvents(
          tCalendarId,
          any(
            that: isA<RetrieveEventsParams>().having(
              (p) => p.startDate,
              'startDate',
              tStartDate,
            ),
          ),
        )).called(1);
      });

      test('should return empty list when no events', () async {
        when(() => mockPlugin.retrieveEvents(
              any(),
              any(),
            )).thenAnswer(
          (_) async => _successResult(UnmodifiableListView<Event>([])),
        );

        final result = await datasource.getEvents(
          tCalendarId,
          startDate: tStartDate,
          endDate: tEndDate,
        );

        expect(result, isEmpty);
      });

      test('should return empty list on error', () async {
        when(() => mockPlugin.retrieveEvents(
              any(),
              any(),
            )).thenAnswer(
          (_) async => _errorResult<UnmodifiableListView<Event>>(),
        );

        final result = await datasource.getEvents(
          tCalendarId,
          startDate: tStartDate,
          endDate: tEndDate,
        );

        expect(result, isEmpty);
      });
    });
  });
}
