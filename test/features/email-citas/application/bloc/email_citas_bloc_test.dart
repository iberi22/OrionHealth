import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/email-citas/application/bloc/email_citas_bloc.dart';
import 'package:orionhealth_health/features/email-citas/application/bloc/email_citas_event.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_state.dart';
import 'package:orionhealth_health/features/email-citas/domain/repositories/email_repository.dart';
import 'package:orionhealth_health/features/email-citas/domain/usecases/email_citas_usecases.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

class MockConnectEmailProviderUseCase extends Mock implements ConnectEmailProviderUseCase {}
class MockSyncEmailAppointmentsUseCase extends Mock implements SyncEmailAppointmentsUseCase {}
class MockEmailRepository extends Mock implements EmailRepository {}
class MockAppointmentRepository extends Mock implements AppointmentRepository {}
class FakeAppointment extends Fake implements Appointment {}

void main() {
  late EmailCitasBloc bloc;
  late MockConnectEmailProviderUseCase mockConnectUseCase;
  late MockSyncEmailAppointmentsUseCase mockSyncUseCase;
  late MockEmailRepository mockEmailRepository;
  late MockAppointmentRepository mockAppointmentRepository;

  setUpAll(() {
    registerFallbackValue(FakeAppointment());
  });

  setUp(() {
    mockConnectUseCase = MockConnectEmailProviderUseCase();
    mockSyncUseCase = MockSyncEmailAppointmentsUseCase();
    mockEmailRepository = MockEmailRepository();
    mockAppointmentRepository = MockAppointmentRepository();
    bloc = EmailCitasBloc(
      mockConnectUseCase,
      mockSyncUseCase,
      mockEmailRepository,
      mockAppointmentRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('EmailCitasBloc', () {
    test('initial state should be EmailCitasInitial', () {
      expect(bloc.state, const EmailCitasInitial());
    });

    test('ConnectGmail emits error if usecase fails', () async {
      when(() => mockConnectUseCase(any())).thenAnswer((_) async => false);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const EmailCitasError('No se pudo abrir la página de conexión de Gmail'),
        ]),
      );

      bloc.add(const ConnectGmail());
      await expectation;
    });

    test('ConnectOutlook emits error if usecase fails', () async {
      when(() => mockConnectUseCase(any())).thenAnswer((_) async => false);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const EmailCitasError('No se pudo abrir la página de conexión de Outlook'),
        ]),
      );

      bloc.add(const ConnectOutlook());
      await expectation;
    });

    test('HandleOAuthRedirect sets state and triggers sync', () async {
      when(() => mockConnectUseCase(any())).thenAnswer((_) async => true);
      when(() => mockSyncUseCase(any(), any())).thenAnswer((_) async => []);

      bloc.add(const ConnectGmail()); // Set pending provider

      final uri = Uri.parse('orionhealth://oauth2redirect?code=test_code');

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const EmailCitasConnected(isGmailConnected: true),
          const EmailCitasLoading(),
          const EmailCitasSyncSuccess(),
          const EmailCitasConnected(isGmailConnected: true),
        ]),
      );

      bloc.add(HandleOAuthRedirect(uri));
      await expectation;
    });

    test('SyncAppointments saves appointments and syncs to calendar', () async {
      final tAppointment = Appointment(
        doctorName: 'Dr. Test',
        specialty: 'Test',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );

      when(() => mockConnectUseCase(any())).thenAnswer((_) async => true);
      when(() => mockSyncUseCase(any(), any())).thenAnswer((_) async => [tAppointment]);
      when(() => mockAppointmentRepository.saveAppointment(any())).thenAnswer((_) async => 1);
      when(() => mockEmailRepository.syncToNativeCalendar(any())).thenAnswer((_) async => true);

      bloc.add(const ConnectGmail());
      bloc.add(HandleOAuthRedirect(Uri.parse('orionhealth://oauth2redirect?code=code')));

      await expectLater(
        bloc.stream,
        emitsThrough(const EmailCitasSyncSuccess()),
      );

      verify(() => mockAppointmentRepository.saveAppointment(any())).called(1);
      verify(() => mockEmailRepository.syncToNativeCalendar(any())).called(1);
    });
  });
}
