import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_appointment.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_event.dart';
import 'package:orionhealth_health/features/calendar_import/domain/repositories/calendar_import_repository.dart';
import 'package:orionhealth_health/features/calendar_import/domain/usecases/import_calendar_usecase.dart';

class MockCalendarRepo extends Mock implements CalendarImportRepository {}
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
    registerFallbackValue(
      CalendarAppointment(
        doctorName: 'test',
        specialty: 'test',
        dateTime: DateTime.now(),
      ),
    );
    registerFallbackValue(<Appointment>[]);
    registerFallbackValue(<CalendarAppointment>[]);
    registerFallbackValue(<CalendarEvent>[]);
    registerFallbackValue(AppointmentStatus.upcoming);
    registerFallbackValue(CalendarEventSource.unknown);
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
    test('should return appointments from repository', () async {
      final appointments = [
        CalendarAppointment(
          doctorName: 'Dr. House',
          specialty: 'Cita',
          dateTime: DateTime.now(),
        ),
      ];
      when(() => mockCalendarRepo.fetchMedicalAppointments())
          .thenAnswer((_) async => appointments);

      final result = await useCase.scanForMedicalEvents();

      expect(result, appointments);
    });

    test('should return empty list when no events', () async {
      when(() => mockCalendarRepo.fetchMedicalAppointments())
          .thenAnswer((_) async => []);

      final result = await useCase.scanForMedicalEvents();

      expect(result, isEmpty);
    });
  });

  group('execute', () {
    test('should import events as appointments', () async {
      final appointments = [
        CalendarAppointment(
          doctorName: 'Dr. House',
          specialty: 'Cita',
          dateTime: DateTime(2026, 6, 10, 10, 0),
          notes: 'Revisión general',
          source: CalendarEventSource.deviceCalendar,
        ),
      ];

      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => null);
      when(() => mockAppointmentRepo.saveAppointment(any()))
          .thenAnswer((_) async => {});

      final result = await useCase.execute(
        ImportCalendarParams(appointments: appointments),
      );

      expect(result.importedCount, 1);
      expect(result.appointments.length, 1);
      expect(result.syncedToFhirCount, 0);
      expect(result.appointments[0].doctorName, 'Dr. House');
      expect(result.appointments[0].specialty, 'Cita');
      expect(result.appointments[0].dateTime,
          DateTime(2026, 6, 10, 10, 0));
      expect(result.appointments[0].source, 'DEVICE_CALENDAR');
      expect(result.appointments[0].status, AppointmentStatus.upcoming);

      verify(() => mockAppointmentRepo.saveAppointment(any())).called(1);
    });

    test('should sync to FHIR when user is connected', () async {
      final appointments = [
        CalendarAppointment(
          doctorName: 'Médico',
          specialty: 'Consulta Médica',
          dateTime: DateTime(2026, 6, 10, 14, 30),
          source: CalendarEventSource.deviceCalendar,
        ),
      ];

      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => UserProfile(uniqueId: 'patient-123'));
      when(() => mockAppointmentRepo.saveAppointment(any()))
          .thenAnswer((_) async => {});

      final result = await useCase.execute(
        ImportCalendarParams(appointments: appointments),
      );

      expect(result.importedCount, 1);
      expect(result.syncedToFhirCount, 1);

      verify(() => mockAppointmentRepo.saveAppointment(any())).called(1);
    });

    test('should import multiple events', () async {
      final appointments = [
        CalendarAppointment(
          doctorName: 'Dr. A',
          specialty: 'Cita',
          dateTime: DateTime(2026, 6, 10, 9, 0),
          source: CalendarEventSource.deviceCalendar,
        ),
        CalendarAppointment(
          doctorName: 'Dra. B',
          specialty: 'Control',
          dateTime: DateTime(2026, 6, 11, 10, 0),
          source: CalendarEventSource.icsFile,
        ),
      ];

      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => null);
      when(() => mockAppointmentRepo.saveAppointment(any()))
          .thenAnswer((_) async => {});

      final result = await useCase.execute(
        ImportCalendarParams(appointments: appointments),
      );

      expect(result.importedCount, 2);
      expect(result.appointments.length, 2);
      expect(result.appointments[0].doctorName, 'Dr. A');
      expect(result.appointments[1].doctorName, 'Dra. B');

      verify(() => mockAppointmentRepo.saveAppointment(any())).called(2);
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
        final result = await useCase.execute(ImportCalendarParams(appointments: [
          CalendarAppointment(
            doctorName: 'Médico',
            specialty: 'Cita',
            dateTime: DateTime.now(),
            source: sources[i],
          )
        ]));
        expect(result.appointments[0].source, expectedTags[i]);
      }
    });
  });
}
