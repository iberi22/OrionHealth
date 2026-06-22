import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/appointments/application/bloc/appointment_bloc.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

class FakeAppointment extends Fake implements Appointment {}

void main() {
  late AppointmentBloc appointmentBloc;
  late MockAppointmentRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeAppointment());
  });

  setUp(() {
    mockRepository = MockAppointmentRepository();
    appointmentBloc = AppointmentBloc(mockRepository);
  });

  tearDown(() {
    appointmentBloc.close();
  });

  group('AppointmentBloc', () {
    final tAppointment = Appointment(
      id: 1,
      doctorName: 'Dr. Smith',
      specialty: 'Cardiology',
      dateTime: DateTime(2023, 1, 1),
      status: AppointmentStatus.upcoming,
    );
    final tAppointments = <Appointment>[tAppointment];

    test('initial state should be AppointmentInitial', () {
      expect(appointmentBloc.state, const AppointmentInitial());
    });

    group('LoadAppointments', () {
      test('emits [Loading, Loaded] when success', () async {
        when(() => mockRepository.getAllAppointments()).thenAnswer((_) async => tAppointments);

        appointmentBloc.add(LoadAppointments());

        expectLater(
          appointmentBloc.stream,
          emitsInOrder([
            const AppointmentLoading(),
            AppointmentLoaded(tAppointments),
          ]),
        );
      });

      test('emits [Loading, Error] when fails', () async {
        when(() => mockRepository.getAllAppointments()).thenThrow(Exception('DB Error'));

        appointmentBloc.add(LoadAppointments());

        expectLater(
          appointmentBloc.stream,
          emitsInOrder([
            const AppointmentLoading(),
            const AppointmentError('Exception: DB Error'),
          ]),
        );
      });
    });

    group('SaveAppointment', () {
      test('calls repository and reloads', () async {
        when(() => mockRepository.saveAppointment(any())).thenAnswer((_) async {});
        when(() => mockRepository.getAllAppointments()).thenAnswer((_) async => tAppointments);

        appointmentBloc.add(SaveAppointment(tAppointment));

        await untilCalled(() => mockRepository.saveAppointment(any()));
        verify(() => mockRepository.saveAppointment(tAppointment)).called(1);
      });
    });

    group('DeleteAppointment', () {
      test('calls repository and reloads', () async {
        when(() => mockRepository.deleteAppointment(any())).thenAnswer((_) async {});
        when(() => mockRepository.getAllAppointments()).thenAnswer((_) async => []);

        appointmentBloc.add(DeleteAppointment(1));

        await untilCalled(() => mockRepository.deleteAppointment(any()));
        verify(() => mockRepository.deleteAppointment(1)).called(1);
      });
    });
  });
}
