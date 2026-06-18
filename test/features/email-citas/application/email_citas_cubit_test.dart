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
  late MockEmailRepository mockEmailRepository;
  late MockAppointmentRepository mockAppointmentRepository;
  late EmailCitasCubit cubit;

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

  group('EmailCitasCubit', () {
    test('initial state is EmailCitasInitial', () {
      expect(cubit.state, equals(EmailCitasInitial()));
    });

    test('connectGmail emits error when connectGmail fails', () async {
      when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => false);

      expectLater(
        cubit.stream,
        emitsInOrder([
          const EmailCitasError('No se pudo abrir la página de conexión de Gmail'),
        ]),
      );

      await cubit.connectGmail();
    });

    test('connectGmail does not emit error when connectGmail succeeds', () async {
      when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => true);
      await cubit.connectGmail();
      expect(cubit.state, isNot(isA<EmailCitasError>()));
    });

    test('connectOutlook emits error when connectOutlook fails', () async {
      when(() => mockEmailRepository.connectOutlook()).thenAnswer((_) async => false);

      expectLater(
        cubit.stream,
        emitsInOrder([
          const EmailCitasError('No se pudo abrir la página de conexión de Outlook'),
        ]),
      );

      await cubit.connectOutlook();
    });

    test('connectOutlook does not emit error when connectOutlook succeeds', () async {
      when(() => mockEmailRepository.connectOutlook()).thenAnswer((_) async => true);
      await cubit.connectOutlook();
      expect(cubit.state, isNot(isA<EmailCitasError>()));
    });

    test('handleOAuthRedirect for Gmail syncs appointments on successful redirect', () async {
      when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => true);
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any()))
          .thenAnswer((_) async => []);

      await cubit.connectGmail();
      final uri = Uri.parse('orionhealth://oauth2redirect?code=test_code');
      await cubit.handleOAuthRedirect(uri);

      expect(cubit.state, const EmailCitasConnected(isGmailConnected: true));
      verify(() => mockEmailRepository.fetchParsedAppointments('Gmail', 'test_code')).called(1);
    });

    test('handleOAuthRedirect for Outlook syncs appointments on successful redirect', () async {
      when(() => mockEmailRepository.connectOutlook()).thenAnswer((_) async => true);
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any()))
          .thenAnswer((_) async => []);

      await cubit.connectOutlook();
      final uri = Uri.parse('orionhealth://oauth2redirect?code=test_code');
      await cubit.handleOAuthRedirect(uri);

      expect(cubit.state, const EmailCitasConnected(isOutlookConnected: true));
      verify(() => mockEmailRepository.fetchParsedAppointments('Outlook', 'test_code')).called(1);
    });

    test('handleOAuthRedirect maintains previous state', () async {
      when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => true);
      when(() => mockEmailRepository.connectOutlook()).thenAnswer((_) async => true);
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any()))
          .thenAnswer((_) async => []);

      // Connect Gmail first
      await cubit.connectGmail();
      await cubit.handleOAuthRedirect(Uri.parse('orionhealth://oauth2redirect?code=code1'));

      // Then connect Outlook
      await cubit.connectOutlook();
      await cubit.handleOAuthRedirect(Uri.parse('orionhealth://oauth2redirect?code=code2'));

      expect(
        cubit.state,
        const EmailCitasConnected(isGmailConnected: true, isOutlookConnected: true),
      );
    });

    test('manualSync calls syncAppointments when connected', () async {
      when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => true);
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any()))
          .thenAnswer((_) async => []);

      await cubit.connectGmail();
      await cubit.handleOAuthRedirect(Uri.parse('orionhealth://oauth2redirect?code=code1'));

      await cubit.manualSync();

      verify(() => mockEmailRepository.fetchParsedAppointments('Gmail', 'code1')).called(2);
    });

    test('manualSync emits error when not connected', () async {
      expectLater(
        cubit.stream,
        emitsInOrder([
          const EmailCitasError('Primero debes conectar una cuenta'),
        ]),
      );
      await cubit.manualSync();
    });

    test('syncAppointments handles errors and restores state', () async {
      when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => true);
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any()))
          .thenThrow(Exception('Sync failed'));

      await cubit.connectGmail();
      await cubit.syncAppointments('code');

      expect(cubit.state, const EmailCitasConnected());
    });

    test('syncAppointments saves appointments and syncs to native calendar', () async {
      final appointment = Appointment(
        doctorName: 'Dr. Test',
        specialty: 'Test',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );
      when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => true);
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any()))
          .thenAnswer((_) async => [appointment]);
      when(() => mockAppointmentRepository.saveAppointment(any())).thenAnswer((_) async => 1);
      when(() => mockEmailRepository.syncToNativeCalendar(any())).thenAnswer((_) async => {});

      await cubit.connectGmail();
      await cubit.syncAppointments('code');

      verify(() => mockAppointmentRepository.saveAppointment(appointment)).called(1);
      verify(() => mockEmailRepository.syncToNativeCalendar(appointment)).called(1);
    });
  });
}
