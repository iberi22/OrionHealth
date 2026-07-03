import 'package:device_calendar/device_calendar.dart' as device;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

  group('CalendarRepositoryImpl', () {
    test('hasPermissions proxies to datasource', () async {
      when(() => mockDatasource.hasPermissions()).thenAnswer((_) async => true);
      expect(await repository.hasPermissions(), isTrue);
    });

    test('fetchMedicalEvents filters for medical keywords', () async {
      final medicalCalendar = device.Calendar(id: '1', name: 'Health');
      final medicalEvent = device.Event('1', title: 'Cita médica', description: 'Control anual');
      final normalEvent = device.Event('1', title: 'Lunch', description: 'Pizza with friends');

      when(() => mockDatasource.getCalendars()).thenAnswer((_) async => [medicalCalendar]);
      when(() => mockDatasource.getEvents(any(), startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
          .thenAnswer((_) async => [medicalEvent, normalEvent]);

      final result = await repository.fetchMedicalEvents();

      expect(result.length, 1);
      expect(result.first.title, 'Cita médica');
    });

    test('requestPermissions proxies to datasource', () async {
      when(() => mockDatasource.requestPermissions()).thenAnswer((_) async => true);
      expect(await repository.requestPermissions(), isTrue);
    });

    test('getCalendarSources returns list of sources', () async {
      final calendar = device.Calendar(id: '1', name: 'Personal', isReadOnly: false);
      when(() => mockDatasource.getCalendars()).thenAnswer((_) async => [calendar]);

      final result = await repository.getCalendarSources();

      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.name, 'Personal');
    });

    test('fetchMedicalEvents handles null calendar ID', () async {
      final calendar = device.Calendar(id: null, name: 'Null ID');
      when(() => mockDatasource.getCalendars()).thenAnswer((_) async => [calendar]);

      final result = await repository.fetchMedicalEvents();

      expect(result, isEmpty);
      verifyNever(() => mockDatasource.getEvents(any(), startDate: any(named: 'startDate'), endDate: any(named: 'endDate')));
    });

    test('fetchMedicalEvents handles no calendars', () async {
      when(() => mockDatasource.getCalendars()).thenAnswer((_) async => []);

      final result = await repository.fetchMedicalEvents();

      expect(result, isEmpty);
    });
  });
}
