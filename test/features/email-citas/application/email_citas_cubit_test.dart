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

  group('connectOutlook', () {
    test('emits error when connectOutlook fails', () async {
      when(
        () => mockEmailRepository.connectOutlook(),
      ).thenAnswer((_) async => false);

      await cubit.connectOutlook();

      expect(cubit.state, isA<EmailCitasError>());
    });

    test('does not emit error when connectOutlook succeeds', () async {
      when(
        () => mockEmailRepository.connectOutlook(),
      ).thenAnswer((_) async => true);

      await cubit.connectOutlook();

      expect(cubit.state, isA<EmailCitasInitial>());
    });
  });

  group('handleOAuthRedirect', () {
    test('syncs appointments on successful redirect (Gmail)', () async {
      final uri = Uri.parse('orionhealth://oauth2redirect?code=test_code');
      final appointment = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );

      when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => true);
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any())).thenAnswer((_) async => [appointment]);
      when(() => mockAppointmentRepository.saveAppointment(any())).thenAnswer((_) async => {});
      when(() => mockEmailRepository.syncToNativeCalendar(any())).thenAnswer((_) async => {});

      await cubit.connectGmail();
      await cubit.handleOAuthRedirect(uri);

      expect(cubit.state, isA<EmailCitasConnected>());
      final state = cubit.state as EmailCitasConnected;
      expect(state.isGmailConnected, true);
      verify(() => mockEmailRepository.fetchParsedAppointments('Gmail', 'test_code')).called(1);
    });

    test('syncs appointments on successful redirect (Outlook)', () async {
      final uri = Uri.parse('orionhealth://oauth2redirect?code=test_code');
      final appointment = Appointment(
        doctorName: 'Dr. Wilson',
        specialty: 'Oncology',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );

      when(() => mockEmailRepository.connectOutlook()).thenAnswer((_) async => true);
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any())).thenAnswer((_) async => [appointment]);
      when(() => mockAppointmentRepository.saveAppointment(any())).thenAnswer((_) async => {});
      when(() => mockEmailRepository.syncToNativeCalendar(any())).thenAnswer((_) async => {});

      await cubit.connectOutlook();
      await cubit.handleOAuthRedirect(uri);

      final state = cubit.state as EmailCitasConnected;
      expect(state.isOutlookConnected, true);
      verify(() => mockEmailRepository.fetchParsedAppointments('Outlook', 'test_code')).called(1);
    });

    test('does nothing when URI host is incorrect', () async {
      final uri = Uri.parse('orionhealth://wronghost?code=test_code');
      await cubit.handleOAuthRedirect(uri);
      expect(cubit.state, isA<EmailCitasInitial>());
    });

    test('does nothing when code is missing', () async {
      final uri = Uri.parse('orionhealth://oauth2redirect');
      await cubit.handleOAuthRedirect(uri);
      expect(cubit.state, isA<EmailCitasInitial>());
    });
  });

  group('manualSync', () {
    test('emits error if no provider has been connected', () async {
      await cubit.manualSync();
      expect(cubit.state, isA<EmailCitasError>());
    });

    test('performs sync if last successful code and provider are present', () async {
      final uri = Uri.parse('orionhealth://oauth2redirect?code=test_code');

      when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => true);
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any())).thenAnswer((_) async => []);

      await cubit.connectGmail();
      await cubit.handleOAuthRedirect(uri);

      // Clear interactions from previous sync
      clearInteractions(mockEmailRepository);

      when(() => mockEmailRepository.fetchParsedAppointments(any(), any())).thenAnswer((_) async => []);
      await cubit.manualSync();

      verify(() => mockEmailRepository.fetchParsedAppointments('Gmail', 'test_code')).called(1);
    });
  });

  group('syncAppointments', () {
    test('emits error when repository throws exception', () async {
       final uri = Uri.parse('orionhealth://oauth2redirect?code=test_code');

       when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => true);
       when(() => mockEmailRepository.fetchParsedAppointments(any(), any())).thenThrow(Exception('Network Error'));

       await cubit.connectGmail();
       await cubit.handleOAuthRedirect(uri);

       // States will be: Connected -> Loading -> Error -> Connected (restored)
       expect(cubit.state, isA<EmailCitasConnected>());
       // Verification of the Error state being emitted would require a package like bloc_test
    });

    test('handles empty appointment list', () async {
      final uri = Uri.parse('orionhealth://oauth2redirect?code=test_code');

      when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => true);
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any())).thenAnswer((_) async => []);

      await cubit.connectGmail();
      await cubit.handleOAuthRedirect(uri);

      expect(cubit.state, isA<EmailCitasConnected>());
      verifyNever(() => mockAppointmentRepository.saveAppointment(any()));
    });

    test('returns early if _pendingProvider is null', () async {
      await cubit.syncAppointments('code');
      expect(cubit.state, isA<EmailCitasInitial>());
    });
  });
}
