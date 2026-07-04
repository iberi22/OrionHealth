import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/email-citas/presentation/email_connect_page.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_cubit.dart';
import 'package:orionhealth_health/features/email-citas/domain/repositories/email_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/services.dart';
import 'utils/video_recorder.dart';

class MockEmailRepository extends Mock implements EmailRepository {}
class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockEmailRepository mockEmailRepository;
  late MockAppointmentRepository mockAppointmentRepository;
  late EmailCitasCubit cubit;

  const MethodChannel messagesChannel = MethodChannel('com.llfbandit.app_links/messages');
  const MethodChannel eventsChannel = MethodChannel('com.llfbandit.app_links/events');

  setUpAll(() {
    registerFallbackValue(Appointment(
      doctorName: '',
      specialty: '',
      dateTime: DateTime.now(),
      status: AppointmentStatus.upcoming,
    ));
  });

  setUp(() async {
    await getIt.reset();

    // Mock AppLinks channels to avoid platform-related failures
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      messagesChannel,
      (MethodCall methodCall) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      eventsChannel,
      (MethodCall methodCall) async => null,
    );

    mockEmailRepository = MockEmailRepository();
    mockAppointmentRepository = MockAppointmentRepository();

    getIt.registerSingleton<EmailRepository>(mockEmailRepository);
    getIt.registerSingleton<AppointmentRepository>(mockAppointmentRepository);

    cubit = EmailCitasCubit(mockEmailRepository, mockAppointmentRepository);
    getIt.registerSingleton<EmailCitasCubit>(cubit);
  });

  group('Email Citas Flow - E2E Tests', () {
    testWidgets('E2E: Connect and Sync Gmail', (WidgetTester tester) async {
      // 1. Initial State
      await tester.pumpWidget(const MaterialApp(home: EmailConnectPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'email_citas', '01_initial');

      expect(find.text('Gmail'), findsOneWidget);
      expect(find.text('No conectado').first, findsOneWidget);

      // 2. Connect Gmail (triggers OAuth flow)
      when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => true);

      await tester.tap(find.text('CONECTAR').first);
      await tester.pumpAndSettle();

      verify(() => mockEmailRepository.connectGmail()).called(1);
      await VideoRecorder.recordStep(tester, 'email_citas', '02_connecting');

      // 3. Simulate OAuth redirect success
      final uri = Uri.parse('orionhealth://oauth2redirect?code=test_code');

      // Mock repository methods for sync
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any()))
          .thenAnswer((_) async => [
            Appointment(
              doctorName: 'Dr. Test',
              specialty: 'E2E Testing',
              dateTime: DateTime.now(),
              status: AppointmentStatus.upcoming,
            )
          ]);
      when(() => mockAppointmentRepository.saveAppointment(any())).thenAnswer((_) async => 1);
      when(() => mockEmailRepository.syncToNativeCalendar(any())).thenAnswer((_) async => {});

      await cubit.handleOAuthRedirect(uri);
      await tester.pumpAndSettle();

      // Check if snackbar appeared and UI updated to Connected
      expect(find.text('Sincronización completada'), findsOneWidget);
      expect(find.text('Conectado').first, findsOneWidget);
      expect(find.text('SINCRONIZAR AHORA'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'email_citas', '03_connected_and_synced');
    });

    testWidgets('E2E: Manual Sync Flow', (WidgetTester tester) async {
      // Setup: Start as connected
      final uri = Uri.parse('orionhealth://oauth2redirect?code=test_code');
      when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => true);
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any())).thenAnswer((_) async => []);

      await cubit.connectGmail();
      await cubit.handleOAuthRedirect(uri);

      await tester.pumpWidget(const MaterialApp(home: EmailConnectPage()));
      await tester.pumpAndSettle();

      expect(find.text('SINCRONIZAR AHORA'), findsOneWidget);

      // Trigger manual sync
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any()))
          .thenAnswer((_) async => []);

      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pump(); // Start loading

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'email_citas', '04_manual_sync_loading');

      await tester.pumpAndSettle();
      expect(find.text('Sincronización completada'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'email_citas', '05_manual_sync_success');
    });

    testWidgets('E2E: Error Handling - Connection Failed', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: EmailConnectPage()));
      await tester.pumpAndSettle();

      when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => false);

      await tester.tap(find.text('CONECTAR').first);
      await tester.pumpAndSettle();

      expect(find.textContaining('No se pudo abrir la página de conexión'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'email_citas', '06_connection_error');
    });

    testWidgets('E2E: Error Handling - Sync Failed', (WidgetTester tester) async {
      // Setup: Start as connected
      final uri = Uri.parse('orionhealth://oauth2redirect?code=test_code');
      when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => true);
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any())).thenAnswer((_) async => []);

      await cubit.connectGmail();
      await cubit.handleOAuthRedirect(uri);

      await tester.pumpWidget(const MaterialApp(home: EmailConnectPage()));
      await tester.pumpAndSettle();

      // Mock sync failure
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any()))
          .thenThrow(Exception('Network Error'));

      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error: Exception: Network Error'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'email_citas', '07_sync_error');
    });
  });
}
