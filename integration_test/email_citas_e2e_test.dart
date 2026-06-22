import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/email-citas/presentation/email_connect_page.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_cubit.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_state.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockEmailCitasCubit extends Mock implements EmailCitasCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockEmailCitasCubit mockCubit;

  setUp(() {
    mockCubit = MockEmailCitasCubit();
    getIt.allowReassignment = true;
    getIt.registerSingleton<EmailCitasCubit>(mockCubit);

    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    getIt.unregister<EmailCitasCubit>();
  });

  group('Email Citas Flow - E2E Tests', () {
    testWidgets('E2E: Connect Email', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const EmailCitasInitial());

      await tester.pumpWidget(const MaterialApp(home: EmailConnectPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'email_citas', '01_initial');

      expect(find.text('Gmail'), findsOneWidget);
      expect(find.text('No conectado').first, findsOneWidget);

      await tester.tap(find.text('CONECTAR').first);
      verify(() => mockCubit.connectGmail()).called(1);
    });

    testWidgets('E2E: Connection Timeout', (WidgetTester tester) async {
      final stateController = StreamController<EmailCitasState>.broadcast();
      when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
      when(() => mockCubit.state).thenReturn(const EmailCitasInitial());

      await tester.pumpWidget(const MaterialApp(home: EmailConnectPage()));
      await tester.pumpAndSettle();

      when(() => mockCubit.connectGmail()).thenAnswer((_) async {
        stateController.add(const EmailCitasError('Timeout'));
      });

      await tester.tap(find.text('CONECTAR').first);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'email_citas', '02_timeout');

      expect(find.text('Error: Timeout'), findsOneWidget);
    });

    testWidgets('E2E: Invalid Email Credentials', (WidgetTester tester) async {
      final stateController = StreamController<EmailCitasState>.broadcast();
      when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
      when(() => mockCubit.state).thenReturn(const EmailCitasInitial());

      await tester.pumpWidget(const MaterialApp(home: EmailConnectPage()));
      await tester.pumpAndSettle();

      when(() => mockCubit.connectGmail()).thenAnswer((_) async {
        stateController.add(const EmailCitasError('Invalid credentials'));
      });

      await tester.tap(find.text('CONECTAR').first);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'email_citas', '03_invalid_creds');

      expect(find.text('Error: Invalid credentials'), findsOneWidget);
    });

    testWidgets('E2E: Network Drop During Sync', (WidgetTester tester) async {
      final stateController = StreamController<EmailCitasState>.broadcast();
      when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
      when(() => mockCubit.state).thenReturn(const EmailCitasConnected(isGmailConnected: true));

      await tester.pumpWidget(const MaterialApp(home: EmailConnectPage()));
      await tester.pumpAndSettle();

      when(() => mockCubit.manualSync()).thenAnswer((_) async {
        stateController.add(const EmailCitasLoading());
        stateController.add(const EmailCitasError('Network connection lost'));
      });

      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'email_citas', '04_network_drop');

      expect(find.text('Error: Network connection lost'), findsOneWidget);
    });

    testWidgets('E2E: Empty Inbox Sync', (WidgetTester tester) async {
      final stateController = StreamController<EmailCitasState>.broadcast();
      when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
      when(() => mockCubit.state).thenReturn(const EmailCitasConnected(isGmailConnected: true));

      await tester.pumpWidget(const MaterialApp(home: EmailConnectPage()));
      await tester.pumpAndSettle();

      when(() => mockCubit.manualSync()).thenAnswer((_) async {
        stateController.add(const EmailCitasLoading());
        stateController.add(const EmailCitasSyncSuccess());
      });

      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'email_citas', '05_empty_inbox');

      expect(find.text('Sincronización completada'), findsOneWidget);
    });
  });
}
