import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/email-citas/presentation/email_connect_page.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_cubit.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_state.dart';
import 'package:flutter/services.dart';

class MockEmailCitasCubit extends Mock implements EmailCitasCubit {}

void main() {
  late MockEmailCitasCubit mockCubit;
  const MethodChannel messagesChannel = MethodChannel('com.llfbandit.app_links/messages');
  const MethodChannel eventsChannel = MethodChannel('com.llfbandit.app_links/events');

  setUp(() async {
    await GetIt.I.reset();
    TestWidgetsFlutterBinding.ensureInitialized();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      messagesChannel,
      (MethodCall methodCall) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      eventsChannel,
      (MethodCall methodCall) async => null,
    );

    mockCubit = MockEmailCitasCubit();
    GetIt.I.registerSingleton<EmailCitasCubit>(mockCubit);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: const EmailConnectPage(),
    );
  }

  testWidgets('renders initial state correctly', (tester) async {
    when(() => mockCubit.state).thenReturn(const EmailCitasInitial());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Conectar Correo'), findsOneWidget);
    expect(find.text('Gmail'), findsOneWidget);
    expect(find.text('Outlook'), findsOneWidget);
    expect(find.text('CONECTAR'), findsNWidgets(2));
  });

  testWidgets('renders loading state correctly', (tester) async {
    when(() => mockCubit.state).thenReturn(const EmailCitasLoading());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders connected state correctly', (tester) async {
    when(() => mockCubit.state).thenReturn(const EmailCitasConnected(
      isGmailConnected: true,
      isOutlookConnected: false,
    ));
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Conectado'), findsOneWidget);
    expect(find.text('No conectado'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('SINCRONIZAR AHORA'), findsOneWidget);
  });

  testWidgets('calls connectGmail when Gmail connect button is pressed', (tester) async {
    when(() => mockCubit.state).thenReturn(const EmailCitasInitial());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.connectGmail()).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('CONECTAR').first);
    verify(() => mockCubit.connectGmail()).called(1);
  });

  testWidgets('calls connectOutlook when Outlook connect button is pressed', (tester) async {
    when(() => mockCubit.state).thenReturn(const EmailCitasInitial());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.connectOutlook()).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('CONECTAR').last);
    verify(() => mockCubit.connectOutlook()).called(1);
  });

  testWidgets('calls manualSync when Sync Now button is pressed', (tester) async {
    when(() => mockCubit.state).thenReturn(const EmailCitasConnected(isGmailConnected: true));
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.manualSync()).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('SINCRONIZAR AHORA'));
    verify(() => mockCubit.manualSync()).called(1);
  });

  testWidgets('shows success snackbar on EmailCitasSyncSuccess', (tester) async {
    when(() => mockCubit.state).thenReturn(const EmailCitasInitial());
    when(() => mockCubit.stream).thenAnswer((_) => Stream.fromIterable([const EmailCitasSyncSuccess()]));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Handle listener

    expect(find.text('Sincronización completada'), findsOneWidget);
  });

  testWidgets('shows error snackbar on EmailCitasError', (tester) async {
    when(() => mockCubit.state).thenReturn(const EmailCitasInitial());
    when(() => mockCubit.stream).thenAnswer((_) => Stream.fromIterable([const EmailCitasError('Test Error')]));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Handle listener

    expect(find.text('Error: Test Error'), findsOneWidget);
  });
}
