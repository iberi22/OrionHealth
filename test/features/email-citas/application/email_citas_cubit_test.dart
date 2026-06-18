import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_cubit.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_state.dart';
import 'package:orionhealth_health/features/email-citas/domain/repositories/email_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

class MockEmailRepository extends Mock implements EmailRepository {}

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

class FakeAppointment extends Fake implements Appointment {}

void main() {
  late EmailCitasCubit cubit;
  late MockEmailRepository mockEmailRepository;
  late MockAppointmentRepository mockAppointmentRepository;

  setUpAll(() {
    registerFallbackValue(FakeAppointment());
  });

  setUp(() {
    mockEmailRepository = MockEmailRepository();
    mockAppointmentRepository = MockAppointmentRepository();
    cubit = EmailCitasCubit(mockEmailRepository, mockAppointmentRepository);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is EmailCitasInitial', () {
    expect(cubit.state, isA<EmailCitasInitial>());
  });

  group('connectGmail', () {
    test('emits error when connectGmail fails', () async {
      when(
        () => mockEmailRepository.connectGmail(),
      ).thenAnswer((_) async => false);

      await cubit.connectGmail();

      expect(cubit.state, isA<EmailCitasError>());
    });

    test('does not emit error when connectGmail succeeds', () async {
      when(
        () => mockEmailRepository.connectGmail(),
      ).thenAnswer((_) async => true);

      await cubit.connectGmail();

      expect(cubit.state, isA<EmailCitasInitial>());
    });
  });

  group('handleOAuthRedirect', () {
    test('syncs appointments on successful redirect', () async {
      final uri = Uri.parse('orionhealth://oauth2redirect?code=test_code');
      final appointment = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );

      when(
        () => mockEmailRepository.connectGmail(),
      ).thenAnswer((_) async => true);
      when(
        () => mockEmailRepository.fetchParsedAppointments(any(), any()),
      ).thenAnswer((_) async => [appointment]);
      when(
        () => mockAppointmentRepository.saveAppointment(any()),
      ).thenAnswer((_) async => {});
      when(
        () => mockEmailRepository.syncToNativeCalendar(any()),
      ).thenAnswer((_) async => {});

      await cubit.connectGmail(); // set _pendingProvider
      await cubit.handleOAuthRedirect(uri);

      verify(
        () => mockEmailRepository.fetchParsedAppointments('Gmail', 'test_code'),
      ).called(1);
      verify(() => mockAppointmentRepository.saveAppointment(any())).called(1);
    });
  });
}
