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
  });
}
