import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/calendar_import/infrastructure/calendar_repository.dart';
import 'package:orionhealth_health/features/calendar_import/application/calendar_import_cubit.dart';

class MockCalendarRepository extends Mock implements CalendarRepository {}
class MockAppointmentRepository extends Mock implements AppointmentRepository {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(Appointment(
      doctorName: '',
      specialty: '',
      dateTime: DateTime.now(),
      status: AppointmentStatus.upcoming,
    ));
  });

  late CalendarImportCubit cubit;
  late MockCalendarRepository mockCalendarRepository;
  late MockAppointmentRepository mockAppointmentRepository;
  late MockUserProfileRepository mockUserProfileRepository;

  setUp(() {
    mockCalendarRepository = MockCalendarRepository();
    mockAppointmentRepository = MockAppointmentRepository();
    mockUserProfileRepository = MockUserProfileRepository();
    cubit = CalendarImportCubit(
      mockCalendarRepository,
      mockAppointmentRepository,
      mockUserProfileRepository,
    );
  });

  test('initial state is CalendarImportInitial', () {
    expect(cubit.state, isA<CalendarImportInitial>());
  });

  group('scanCalendar', () {
    test('emits [Loading, Loaded] when permissions are granted and events found', () async {
      final appointments = [
        Appointment(
          doctorName: 'Dr. Smith',
          specialty: 'Cardiology',
          dateTime: DateTime.now(),
          status: AppointmentStatus.upcoming,
        )
      ];

      when(() => mockCalendarRepository.hasPermissions()).thenAnswer((_) async => true);
      when(() => mockCalendarRepository.fetchMedicalEvents()).thenAnswer((_) async => appointments);

      final expectedStates = [
        isA<CalendarImportLoading>(),
        isA<CalendarImportLoaded>(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.scanCalendar();
    });

    test('emits [Loading, PermissionDenied] when permissions are not granted', () async {
      when(() => mockCalendarRepository.hasPermissions()).thenAnswer((_) async => false);
      when(() => mockCalendarRepository.requestPermissions()).thenAnswer((_) async => false);

      final expectedStates = [
        isA<CalendarImportLoading>(),
        isA<CalendarImportPermissionDenied>(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.scanCalendar();
    });
  });

  group('importAppointments', () {
    test('emits [Loading, Success] when appointments are saved', () async {
      final appointments = [
        Appointment(
          doctorName: 'Dr. Smith',
          specialty: 'Cardiology',
          dateTime: DateTime.now(),
          status: AppointmentStatus.upcoming,
        )
      ];

      when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => null);
      when(() => mockAppointmentRepository.saveAppointment(any())).thenAnswer((_) async => {});

      final expectedStates = [
        isA<CalendarImportLoading>(),
        isA<CalendarImportSuccess>(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.importAppointments(appointments);

      verify(() => mockAppointmentRepository.saveAppointment(any())).called(1);
    });
  });
}
