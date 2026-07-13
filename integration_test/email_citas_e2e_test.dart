// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/email-citas/presentation/email_connect_page.dart';
import 'package:orionhealth_health/features/email-citas/domain/repositories/email_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';
import 'package:mocktail/mocktail.dart';
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
      theme: CyberTheme.darkTheme,
    );
  }

  Finder findProviderCard(String name) {
    return find.ancestor(
      of: find.text(name),
      matching: find.byType(GlassmorphicCard),
    );
  }

  group('Email Citas Flow - E2E Tests', () {
    testWidgets('E2E: Full Integration Flow - Connect, Sync, and Error Handling', (WidgetTester tester) async {
      // 1. Initial State
      await tester.pumpWidget(createTestWidget(const EmailConnectPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'email_citas', '01_initial');

      expect(find.text('Gmail'), findsOneWidget);
      expect(find.text('Outlook'), findsOneWidget);
      expect(find.textContaining('No conectado'), findsNWidgets(2));
      expect(find.text('SINCRONIZAR AHORA'), findsNothing);

      // 2. Connect Gmail
      await tester.tap(find.descendant(of: findProviderCard('Gmail'), matching: find.text('CONECTAR')));
      await tester.pumpAndSettle();
      verify(() => mockEmailRepository.connectGmail()).called(1);

      // Simulate deep link redirect
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        'com.llfbandit.app_links/events',
        const StandardMethodCodec().encodeSuccessEnvelope('orionhealth://oauth2redirect?code=gmail_code'),
        (data) {},
      );
      await tester.pumpAndSettle();

      // Verify Gmail is connected
      expect(find.descendant(of: findProviderCard('Gmail'), matching: find.text('Conectado')), findsOneWidget);
      expect(find.text('SINCRONIZAR AHORA'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'email_citas', '02_gmail_connected');

      // 3. Manual Sync Success
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

      when(() => mockEmailRepository.fetchParsedAppointments('Gmail', 'gmail_code'))
          .thenAnswer((_) async => mockAppointments);

      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pump(); // Start loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      verify(() => mockAppointmentRepository.saveAppointment(any())).called(2);
      verify(() => mockEmailRepository.syncToNativeCalendar(any())).called(2);
      expect(find.text('Sincronización completada'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'email_citas', '03_sync_success');

      // 4. Connect Outlook
      await tester.tap(find.descendant(of: findProviderCard('Outlook'), matching: find.text('CONECTAR')));
      await tester.pumpAndSettle();
      verify(() => mockEmailRepository.connectOutlook()).called(1);

      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        'com.llfbandit.app_links/events',
        const StandardMethodCodec().encodeSuccessEnvelope('orionhealth://oauth2redirect?code=outlook_code'),
        (data) {},
      );
      await tester.pumpAndSettle();

      expect(find.descendant(of: findProviderCard('Outlook'), matching: find.text('Conectado')), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'email_citas', '04_both_connected');

      // 5. Sync Error
      when(() => mockEmailRepository.fetchParsedAppointments('Outlook', 'outlook_code'))
          .thenThrow(Exception('Error de conexión con Outlook'));

      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error: Exception: Error de conexión con Outlook'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'email_citas', '05_sync_error');
    });
  });
}
