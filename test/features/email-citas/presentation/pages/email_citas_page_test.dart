import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/email-citas/presentation/email_connect_page.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_cubit.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_state.dart';

class MockEmailCitasCubit extends Mock implements EmailCitasCubit {}

void main() {
  late MockEmailCitasCubit mockCubit;
  const MethodChannel messagesChannel = MethodChannel('com.llfbandit.app_links/messages');
  const MethodChannel eventsChannel = MethodChannel('com.llfbandit.app_links/events');

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
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
    mockCubit = MockEmailCitasCubit();
    final getIt = GetIt.instance;
    if (getIt.isRegistered<EmailCitasCubit>()) {
      getIt.unregister<EmailCitasCubit>();
    }
    getIt.registerSingleton<EmailCitasCubit>(mockCubit);

    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: EmailConnectPage(),
    );
  }

  group('EmailConnectPage Tests', () {
    testWidgets('calls connectGmail when Gmail connect button is pressed', (tester) async {
      when(() => mockCubit.state).thenReturn(EmailCitasInitial());
      when(() => mockCubit.connectGmail()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'CONECTAR').first);
      verify(() => mockCubit.connectGmail()).called(1);
    });

    testWidgets('calls connectOutlook when Outlook connect button is pressed', (tester) async {
      when(() => mockCubit.state).thenReturn(EmailCitasInitial());
      when(() => mockCubit.connectOutlook()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'CONECTAR').last);
      verify(() => mockCubit.connectOutlook()).called(1);
    });

    testWidgets('calls manualSync when sync button is pressed', (tester) async {
      when(() => mockCubit.state).thenReturn(const EmailCitasConnected(isGmailConnected: true));
      when(() => mockCubit.manualSync()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('SINCRONIZAR AHORA'));
      verify(() => mockCubit.manualSync()).called(1);
    });

    testWidgets('shows snackbar on SyncSuccess', (tester) async {
      final controller = StreamController<EmailCitasState>.broadcast();
      when(() => mockCubit.stream).thenAnswer((_) => controller.stream);
      when(() => mockCubit.state).thenReturn(EmailCitasInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      controller.add(EmailCitasSyncSuccess());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Sincronización completada'), findsOneWidget);
      await controller.close();
    });

    testWidgets('shows snackbar on Error', (tester) async {
      final controller = StreamController<EmailCitasState>.broadcast();
      when(() => mockCubit.stream).thenAnswer((_) => controller.stream);
      when(() => mockCubit.state).thenReturn(EmailCitasInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      controller.add(const EmailCitasError('Test Error'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Error: Test Error'), findsOneWidget);
      await controller.close();
    });
  });
}
