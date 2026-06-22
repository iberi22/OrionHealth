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

  group('CalendarApiDatasource', () {
    test('hasPermissions returns true on success', () async {
      final resultData = Result<bool>()..data = true;
      when(() => mockPlugin.hasPermissions()).thenAnswer(
        (_) async => resultData,
      );

      final result = await datasource.hasPermissions();

      expect(result, isTrue);
    });

    test('requestPermissions returns true on success', () async {
      final resultData = Result<bool>()..data = true;
      when(() => mockPlugin.requestPermissions()).thenAnswer(
        (_) async => resultData,
      );

      final result = await datasource.requestPermissions();

      expect(result, isTrue);
    });

    test('getCalendars returns list of calendars', () async {
      final calendars = [Calendar(id: '1', name: 'Personal')];
      final resultData = Result<UnmodifiableListView<Calendar>>()..data = UnmodifiableListView(calendars);

      when(() => mockPlugin.retrieveCalendars()).thenAnswer(
        (_) async => resultData,
      );

      final result = await datasource.getCalendars();

      expect(result, calendars);
    });

    test('getEvents returns list of events', () async {
      final events = [Event('1', title: 'Test Event')];
      final resultData = Result<UnmodifiableListView<Event>>()..data = UnmodifiableListView(events);

      when(() => mockPlugin.retrieveEvents(any(), any())).thenAnswer(
        (_) async => resultData,
      );

      final result = await datasource.getEvents('1');

      expect(result, events);
    });
  });
}
