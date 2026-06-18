import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_event.dart';
import 'package:orionhealth_health/features/calendar_import/domain/repositories/calendar_repository.dart';
import 'package:orionhealth_health/features/calendar_import/domain/usecases/import_calendar_usecase.dart';

class MockCalendarRepo extends Mock implements CalendarRepository {}
class MockAppointmentRepo extends Mock implements AppointmentRepository {}
class MockUserProfileRepo extends Mock implements UserProfileRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Appointment(
        doctorName: '',
        specialty: '',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      ),
    );
    registerFallbackValue(
      CalendarEvent(
        title: 'test',
        startDateTime: DateTime.now(),
      ),
    );
  });

  late MockCalendarRepo mockCalendarRepo;
  late MockAppointmentRepo mockAppointmentRepo;
  late MockUserProfileRepo mockUserProfileRepo;
  late ImportCalendarUseCase useCase;

  setUp(() {
    mockCalendarRepo = MockCalendarRepo();
    mockAppointmentRepo = MockAppointmentRepo();
    mockUserProfileRepo = MockUserProfileRepo();
    useCase = ImportCalendarUseCase(
      mockCalendarRepo,
      mockAppointmentRepo,
      mockUserProfileRepo,
    );
  });

  group('ensurePermissions', () {
    test('should return true when permissions already granted', () async {
      when(() => mockCalendarRepo.hasPermissions())
          .thenAnswer((_) async => true);

      final result = await useCase.ensurePermissions();

      expect(result, true);
      verify(() => mockCalendarRepo.hasPermissions()).called(1);
      verifyNever(() => mockCalendarRepo.requestPermissions());
    });

    test('should request permissions when not granted and return true',
        () async {
      when(() => mockCalendarRepo.hasPermissions())
          .thenAnswer((_) async => false);
      when(() => mockCalendarRepo.requestPermissions())
          .thenAnswer((_) async => true);

      final result = await useCase.ensurePermissions();

      expect(result, true);
      verify(() => mockCalendarRepo.hasPermissions()).called(1);
      verify(() => mockCalendarRepo.requestPermissions()).called(1);
    });

    test('should return false when permissions denied', () async {
      when(() => mockCalendarRepo.hasPermissions())
          .thenAnswer((_) async => false);
      when(() => mockCalendarRepo.requestPermissions())
          .thenAnswer((_) async => false);

      final result = await useCase.ensurePermissions();

      expect(result, false);
    });
  });

  group('scanForMedicalEvents', () {
    test('should return events from repository', () async {
      final events = [
        CalendarEvent(
          title: 'Cita',
          startDateTime: DateTime.now(),
        ),
      ];
      when(() => mockCalendarRepo.fetchMedicalEvents())
          .thenAnswer((_) async => events);

      final result = await useCase.scanForMedicalEvents();

      expect(result, events);
    });

    test('should return empty list when no events', () async {
      when(() => mockCalendarRepo.fetchMedicalEvents())
          .thenAnswer((_) async => []);

      final result = await useCase.scanForMedicalEvents();

      expect(result, isEmpty);
    });
  });

  group('execute', () {
    test('should import events as appointments', () async {
      final events = [
        CalendarEvent(
          title: 'Cita con Dr. House',
          startDateTime: DateTime(2026, 6, 10, 10, 0),
          description: 'Revisión general',
          source: CalendarEventSource.deviceCalendar,
        ),
      ];

      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => null);
      when(() => mockAppointmentRepo.saveAppointment(any()))
          .thenAnswer((_) async => {});

      final result = await useCase.execute(
        ImportCalendarParams(events: events),
      );

      expect(result.importedCount, 1);
      expect(result.appointments.length, 1);
      expect(result.syncedToFhirCount, 0);
      expect(result.appointments[0].doctorName, 'Dr. House');
      expect(result.appointments[0].specialty, 'cita');
      expect(result.appointments[0].dateTime,
          DateTime(2026, 6, 10, 10, 0));
      expect(result.appointments[0].source, 'DEVICE_CALENDAR');
      expect(result.appointments[0].status, AppointmentStatus.upcoming);

      verify(() => mockAppointmentRepo.saveAppointment(any())).called(1);
    });

    test('should sync to FHIR when user is connected', () async {
      final events = [
        CalendarEvent(
          title: 'Consulta Médica',
          startDateTime: DateTime(2026, 6, 10, 14, 30),
          source: CalendarEventSource.deviceCalendar,
        ),
      ];

      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => UserProfile(uniqueId: 'patient-123'));
      when(() => mockAppointmentRepo.saveAppointment(any()))
          .thenAnswer((_) async => {});

      final result = await useCase.execute(
        ImportCalendarParams(events: events),
      );

      expect(result.importedCount, 1);
      expect(result.syncedToFhirCount, 1);

      verify(() => mockAppointmentRepo.saveAppointment(any())).called(1);
    });

    test('should import multiple events', () async {
      final events = [
        CalendarEvent(
          title: 'Cita Dr. A',
          startDateTime: DateTime(2026, 6, 10, 9, 0),
          source: CalendarEventSource.deviceCalendar,
        ),
        CalendarEvent(
          title: 'Control con Dra. B',
          startDateTime: DateTime(2026, 6, 11, 10, 0),
          source: CalendarEventSource.icsFile,
        ),
      ];

      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => null);
      when(() => mockAppointmentRepo.saveAppointment(any()))
          .thenAnswer((_) async => {});

      final result = await useCase.execute(
        ImportCalendarParams(events: events),
      );

      expect(result.importedCount, 2);
      expect(result.appointments.length, 2);
      expect(result.appointments[0].doctorName, 'Dr. A');
      expect(result.appointments[1].doctorName, 'Dra. B');

      verify(() => mockAppointmentRepo.saveAppointment(any())).called(2);
    });

    test('should handle unknown doctor name', () async {
      final events = [
        CalendarEvent(
          title: 'Cita Médica',
          startDateTime: DateTime(2026, 6, 10, 10, 0),
          source: CalendarEventSource.unknown,
        ),
      ];

      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => null);
      when(() => mockAppointmentRepo.saveAppointment(any()))
          .thenAnswer((_) async => {});

      final result = await useCase.execute(
        ImportCalendarParams(events: events),
      );

      expect(result.importedCount, 1);
      expect(result.appointments[0].doctorName, 'Médico');
      expect(result.appointments[0].source, 'UNKNOWN_IMPORT');
    });

    test('should cover all specialty keywords', () async {
      final keywords = [
        'cita',
        'médico',
        'consulta',
        'EPS',
        'Sura',
        'Comfama',
        'Sanitas',
        'doctor',
        'especialista',
        'control',
        'examen',
        'procedimiento',
        'odontología',
        'terapia',
        'laboratorio',
        'vacuna',
      ];

      when(() => mockUserProfileRepo.getUserProfile()).thenAnswer((_) async => null);
      when(() => mockAppointmentRepo.saveAppointment(any())).thenAnswer((_) async => {});

      for (final keyword in keywords) {
        final result = await useCase.execute(ImportCalendarParams(events: [
          CalendarEvent(
            title: 'Mi $keyword',
            startDateTime: DateTime.now(),
          )
        ]));
        expect(result.appointments[0].specialty, keyword);
      }

      // Default case
      final resultDefault = await useCase.execute(ImportCalendarParams(events: [
        CalendarEvent(
          title: 'Algo diferente',
          startDateTime: DateTime.now(),
        )
      ]));
      expect(resultDefault.appointments[0].specialty, 'Consulta General');
    });

    test('should cover all source tags', () async {
      final sources = [
        CalendarEventSource.deviceCalendar,
        CalendarEventSource.icsFile,
        CalendarEventSource.csvFile,
        CalendarEventSource.manual,
        CalendarEventSource.unknown,
      ];
      final expectedTags = [
        'DEVICE_CALENDAR',
        'ICS_IMPORT',
        'CSV_IMPORT',
        'MANUAL_IMPORT',
        'UNKNOWN_IMPORT',
      ];

      when(() => mockUserProfileRepo.getUserProfile()).thenAnswer((_) async => null);
      when(() => mockAppointmentRepo.saveAppointment(any())).thenAnswer((_) async => {});

      for (int i = 0; i < sources.length; i++) {
        final result = await useCase.execute(ImportCalendarParams(events: [
          CalendarEvent(
            title: 'Cita',
            startDateTime: DateTime.now(),
            source: sources[i],
          )
        ]));
        expect(result.appointments[0].source, expectedTags[i]);
      }
    });

    test('should handle doctor name with multiple parts', () async {
      when(() => mockUserProfileRepo.getUserProfile()).thenAnswer((_) async => null);
      when(() => mockAppointmentRepo.saveAppointment(any())).thenAnswer((_) async => {});

      final result = await useCase.execute(ImportCalendarParams(events: [
        CalendarEvent(
          title: 'Cita con Dr. Juan Perez Rodriguez',
          startDateTime: DateTime.now(),
        )
      ]));
      expect(result.appointments[0].doctorName, 'Dr. Juan Perez Rodriguez');
    });
  });
}
