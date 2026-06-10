import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/appointments/application/appointments_cubit.dart';
import 'package:orionhealth_health/features/appointments/application/appointments_state.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

class FakeAppointment extends Fake implements Appointment {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAppointment());
  });
  late MockAppointmentRepository repository;
  late AppointmentsCubit cubit;

  setUp(() {
    repository = MockAppointmentRepository();
    cubit = AppointmentsCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('AppointmentsCubit', () {
    final tAppointments = [
      Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      ),
    ];

    test('initial state is AppointmentsInitial', () {
      expect(cubit.state, isA<AppointmentsInitial>());
    });

    group('loadAppointments', () {
      test('emits loading then loaded on success', () async {
        when(() => repository.getAllAppointments()).thenAnswer((_) async => tAppointments);

        expectLater(cubit.stream, emitsInOrder([
          isA<AppointmentsLoading>(),
          isA<AppointmentsLoaded>(),
        ]));
        await cubit.loadAppointments();
      });

      test('emits loading then error on failure', () async {
        when(() => repository.getAllAppointments()).thenThrow(Exception('db error'));

        expectLater(cubit.stream, emitsInOrder([
          isA<AppointmentsLoading>(),
          isA<AppointmentsError>(),
        ]));
        await cubit.loadAppointments();
      });
    });

    group('saveAppointment', () {
      test('saves and reloads on success', () async {
        when(() => repository.saveAppointment(any())).thenAnswer((_) async {});
        when(() => repository.getAllAppointments()).thenAnswer((_) async => tAppointments);

        expectLater(cubit.stream, emitsInOrder([
          isA<AppointmentsLoading>(),
          isA<AppointmentsLoaded>(),
        ]));
        await cubit.saveAppointment(tAppointments.first);
      });
    });

    group('deleteAppointment', () {
      test('deletes and reloads on success', () async {
        when(() => repository.deleteAppointment(1)).thenAnswer((_) async {});
        when(() => repository.getAllAppointments()).thenAnswer((_) async => tAppointments);

        expectLater(cubit.stream, emitsInOrder([
          isA<AppointmentsLoading>(),
          isA<AppointmentsLoaded>(),
        ]));
        await cubit.deleteAppointment(1);
      });
    });
  });
}
