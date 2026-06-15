import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_event.dart';
import 'package:orionhealth_health/features/calendar_import/domain/repositories/calendar_repository.dart';
import 'package:orionhealth_health/features/calendar_import/domain/usecases/sync_calendar_usecase.dart';

class MockCalendarRepo extends Mock implements CalendarRepository {}

void main() {
  late MockCalendarRepo mockCalendarRepo;
  late SyncCalendarUseCase useCase;

  setUp(() {
    mockCalendarRepo = MockCalendarRepo();
    useCase = SyncCalendarUseCase(mockCalendarRepo);
  });

  group('SyncCalendarUseCase', () {
    test('should return result with new events when permissions granted',
        () async {
      when(() => mockCalendarRepo.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockCalendarRepo.fetchMedicalEvents(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => [
        CalendarEvent(
          title: 'Cita Médica',
          startDateTime: DateTime.now(),
          source: CalendarEventSource.deviceCalendar,
        ),
      ]);

      final result = await useCase.execute(const SyncCalendarParams());

      expect(result.newEventsFound, 1);
      expect(result.totalEvents, 1);
    });

    test('should request permissions when not granted', () async {
      when(() => mockCalendarRepo.hasPermissions())
          .thenAnswer((_) async => false);
      when(() => mockCalendarRepo.requestPermissions())
          .thenAnswer((_) async => true);
      when(() => mockCalendarRepo.fetchMedicalEvents(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => []);

      final result = await useCase.execute(const SyncCalendarParams());

      expect(result.newEventsFound, 0);
      expect(result.totalEvents, 0);
      verify(() => mockCalendarRepo.requestPermissions()).called(1);
    });

    test('should return zero when permissions denied', () async {
      when(() => mockCalendarRepo.hasPermissions())
          .thenAnswer((_) async => false);
      when(() => mockCalendarRepo.requestPermissions())
          .thenAnswer((_) async => false);

      final result = await useCase.execute(const SyncCalendarParams());

      expect(result.newEventsFound, 0);
      expect(result.totalEvents, 0);
      verifyNever(() => mockCalendarRepo.fetchMedicalEvents(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ));
    });

    test('should deduplicate events with same title and start time', () async {
      final now = DateTime.now();
      when(() => mockCalendarRepo.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockCalendarRepo.fetchMedicalEvents(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => [
        CalendarEvent(
          title: 'Cita Médica',
          startDateTime: now,
          source: CalendarEventSource.deviceCalendar,
        ),
        CalendarEvent(
          title: 'Cita Médica',
          startDateTime: now,
          source: CalendarEventSource.deviceCalendar,
        ),
      ]);

      final result = await useCase.execute(const SyncCalendarParams());

      expect(result.newEventsFound, 1);
      expect(result.totalEvents, 2);
    });

    test('should pass custom lookback days to repository', () async {
      when(() => mockCalendarRepo.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockCalendarRepo.fetchMedicalEvents(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => []);

      await useCase.execute(const SyncCalendarParams(lookBackDays: 30));

      verify(() => mockCalendarRepo.fetchMedicalEvents(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).called(1);
    });
  });
}
