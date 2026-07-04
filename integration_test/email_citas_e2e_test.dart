import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/email-citas/presentation/email_connect_page.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_cubit.dart';
import 'package:orionhealth_health/features/email-citas/domain/repositories/email_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'utils/video_recorder.dart';

class MockEmailRepository extends Mock implements EmailRepository {}
class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockEmailRepository mockEmailRepo;
  late MockAppointmentRepository mockApptRepo;

  const MethodChannel messagesChannel = MethodChannel('com.llfbandit.app_links/messages');
  const MethodChannel eventsChannel = MethodChannel('com.llfbandit.app_links/events');

  setUpAll(() async {
    // Mock the MethodChannels used by app_links to prevent platform errors
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      messagesChannel,
      (MethodCall methodCall) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      eventsChannel,
      (MethodCall methodCall) async => null,
    );
  });

  setUp(() {
    mockEmailRepo = MockEmailRepository();
    mockApptRepo = MockAppointmentRepository();

    di.getIt.allowReassignment = true;
    di.getIt.registerSingleton<EmailRepository>(mockEmailRepo);
    di.getIt.registerSingleton<AppointmentRepository>(mockApptRepo);

    // Use the real Cubit with mocked repositories
    di.getIt.registerFactory<EmailCitasCubit>(
      () => EmailCitasCubit(mockEmailRepo, mockApptRepo),
    );
  });

  tearDown(() {
    if (di.getIt.isRegistered<EmailRepository>()) {
      di.getIt.unregister<EmailRepository>();
    }
    if (di.getIt.isRegistered<AppointmentRepository>()) {
      di.getIt.unregister<AppointmentRepository>();
    }
    if (di.getIt.isRegistered<EmailCitasCubit>()) {
      di.getIt.unregister<EmailCitasCubit>();
    }
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: const EmailConnectPage(),
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

  group('Email Citas Flow - E2E Tests', () {
    testWidgets('E2E: Full Connect and Sync Flow', (WidgetTester tester) async {
      when(() => mockEmailRepo.connectGmail()).thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'email_citas', '01_initial');

      expect(find.text('Gmail'), findsOneWidget);
      expect(find.text('No conectado').first, findsOneWidget);

      // 1. Trigger Gmail connection
      await tester.tap(find.text('CONECTAR').first);
      await tester.pumpAndSettle();
      verify(() => mockEmailRepo.connectGmail()).called(1);

      // 2. Simulate OAuth Redirect (incoming deep link)
      final cubit = di.getIt<EmailCitasCubit>();
      final redirectUri = Uri.parse('orionhealth://oauth2redirect?code=test-code');

      when(() => mockEmailRepo.fetchParsedAppointments('Gmail', 'test-code'))
          .thenAnswer((_) async => []);

      await cubit.handleOAuthRedirect(redirectUri);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'email_citas', '02_connected');

      expect(find.text('Conectado'), findsAtLeastNWidgets(1));

      // 3. Perform Manual Sync
      when(() => mockEmailRepo.fetchParsedAppointments('Gmail', 'test-code'))
          .thenAnswer((_) async => []);

      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'email_citas', '03_synced');

      expect(find.text('Sincronización completada'), findsOneWidget);
    });

    testWidgets('E2E: Connection Error handling', (WidgetTester tester) async {
      when(() => mockEmailRepo.connectGmail()).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('CONECTAR').first);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'email_citas', '04_connect_error');

      expect(find.textContaining('No se pudo abrir la página de conexión de Gmail'), findsOneWidget);
    });

    testWidgets('E2E: Sync Error handling', (WidgetTester tester) async {
      // Pre-connect Gmail
      when(() => mockEmailRepo.connectGmail()).thenAnswer((_) async => true);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('CONECTAR').first);
      await tester.pumpAndSettle();

      final cubit = di.getIt<EmailCitasCubit>();
      when(() => mockEmailRepo.fetchParsedAppointments('Gmail', 'test-code'))
          .thenAnswer((_) async => []);
      await cubit.handleOAuthRedirect(Uri.parse('orionhealth://oauth2redirect?code=test-code'));
      await tester.pumpAndSettle();

      // Trigger sync that fails
      when(() => mockEmailRepo.fetchParsedAppointments('Gmail', 'test-code'))
          .thenThrow(Exception('Sync failed'));

      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'email_citas', '05_sync_error');

      expect(find.textContaining('Sync failed'), findsOneWidget);
    });
  });
}
