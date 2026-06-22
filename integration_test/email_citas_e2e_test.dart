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
  });
}
