// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/email-citas/presentation/email_connect_page.dart';
import 'package:orionhealth_health/features/email-citas/domain/repositories/email_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/services.dart';
import 'utils/video_recorder.dart';

class MockEmailRepository extends Mock implements EmailRepository {}
class MockAppointmentRepository extends Mock implements AppointmentRepository {}
class FakeAppointment extends Fake implements Appointment {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockEmailRepository mockEmailRepository;
  late MockAppointmentRepository mockAppointmentRepository;

  setUpAll(() async {
    registerFallbackValue(FakeAppointment());
    await di.configureDependencies();
  });

  setUp(() {
    mockEmailRepository = MockEmailRepository();
    mockAppointmentRepository = MockAppointmentRepository();

    di.getIt.allowReassignment = true;
    di.getIt.registerSingleton<EmailRepository>(mockEmailRepository);
    di.getIt.registerSingleton<AppointmentRepository>(mockAppointmentRepository);

    // Default behaviors
    when(() => mockEmailRepository.connectGmail()).thenAnswer((_) async => true);
    when(() => mockEmailRepository.connectOutlook()).thenAnswer((_) async => true);
    when(() => mockEmailRepository.fetchParsedAppointments(any(), any()))
        .thenAnswer((_) async => []);
    when(() => mockAppointmentRepository.saveAppointment(any()))
        .thenAnswer((_) async => {});
    when(() => mockEmailRepository.syncToNativeCalendar(any()))
        .thenAnswer((_) async => {});

    // Mock MethodChannel for app_links
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.llfbandit.app_links/messages'),
      (MethodCall methodCall) async {
        return null;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.llfbandit.app_links/events'),
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  Widget createTestWidget(Widget home) {
    return MaterialApp(
      home: home,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
    );
  }

  Finder findProviderCard(String name) {
    return find.ancestor(
      of: find.text(name),
      matching: find.byType(GlassmorphicCard),
    );
  }

  group('Email Citas Flow - E2E Tests', () {
    testWidgets('E2E: Full Integration Flow - Connect Providers and Sync Appointments',
        (WidgetTester tester) async {
      // 1. Initial State - Page Renders
      await tester.pumpWidget(createTestWidget(const EmailConnectPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'email-citas', '01_initial');

      expect(find.text('Conectar Correo'), findsOneWidget);
      expect(find.text('Gmail'), findsOneWidget);
      expect(find.text('Outlook'), findsOneWidget);
      expect(find.textContaining('No conectado'), findsNWidgets(2));

      // 2. Connect Gmail
      await tester.tap(
        find.descendant(
          of: findProviderCard('Gmail'),
          matching: find.text('CONECTAR'),
        ),
      );
      await tester.pumpAndSettle();
      verify(() => mockEmailRepository.connectGmail()).called(1);

      // Simulate OAuth redirect via deep link
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'com.llfbandit.app_links/events',
        const StandardMethodCodec()
            .encodeSuccessEnvelope('orionhealth://oauth2redirect?code=gmail_auth_code'),
        (data) {},
      );
      await tester.pumpAndSettle();

      // Verify Gmail shows as connected
      expect(
        find.descendant(
          of: findProviderCard('Gmail'),
          matching: find.text('Conectado'),
        ),
        findsOneWidget,
      );
      // Sync button should appear
      expect(find.text('SINCRONIZAR AHORA'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'email-citas', '02_gmail_connected');

      // 3. Connect Outlook as well
      await tester.tap(
        find.descendant(
          of: findProviderCard('Outlook'),
          matching: find.text('CONECTAR'),
        ),
      );
      await tester.pumpAndSettle();
      verify(() => mockEmailRepository.connectOutlook()).called(1);

      // Simulate Outlook OAuth redirect
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'com.llfbandit.app_links/events',
        const StandardMethodCodec()
            .encodeSuccessEnvelope('orionhealth://oauth2redirect?code=outlook_auth_code'),
        (data) {},
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: findProviderCard('Outlook'),
          matching: find.text('Conectado'),
        ),
        findsOneWidget,
      );
      await VideoRecorder.recordStep(tester, 'email-citas', '03_both_connected');

      // 4. Manual Sync with Appointments
      final mockAppointments = [
        Appointment(
          doctorName: 'Dr. House',
          specialty: 'Diagnóstico',
          dateTime: DateTime.now().add(const Duration(days: 2)),
          status: AppointmentStatus.upcoming,
        ),
        Appointment(
          doctorName: 'Dr. Strange',
          specialty: 'Neurocirugía',
          dateTime: DateTime.now().add(const Duration(days: 5)),
          status: AppointmentStatus.upcoming,
        ),
      ];

      when(() => mockEmailRepository.fetchParsedAppointments('Outlook', 'outlook_auth_code'))
          .thenAnswer((_) async => mockAppointments);

      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pump(); // Start loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Verify appointments were saved
      verify(() => mockAppointmentRepository.saveAppointment(any())).called(2);
      verify(() => mockEmailRepository.syncToNativeCalendar(any())).called(2);

      // Verify success snackbar appears
      expect(find.text('Sincronización completada'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'email-citas', '04_sync_success');

      // 5. Error Handling during Sync
      when(() => mockEmailRepository.fetchParsedAppointments(any(), any()))
          .thenThrow(Exception('Network error'));

      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'email-citas', '05_sync_error');
    });
  });
}
