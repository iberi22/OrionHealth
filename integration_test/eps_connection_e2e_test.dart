import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/pages/eps_connection_page.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_cubit.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_connection.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'utils/video_recorder.dart';

class MockEpsConnectionCubit extends Mock implements EpsConnectionCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockEpsConnectionCubit mockCubit;

  setUp(() {
    mockCubit = MockEpsConnectionCubit();
    // In this case, the widget doesn't use getIt for the Cubit directly in the build
    // but expects it to be provided or handles it.
    // Checking EpsConnectionPage... it expects BlocBuilder so it needs a provider.
    // Wait, EpsConnectionPage doesn't have a BlocProvider inside its build.
    // It must be provided by the caller.

    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  group('EPS Connection Flow - E2E Tests', () {
    testWidgets('E2E: List Connections', (WidgetTester tester) async {
      final connections = [
        EPSConnection(
          provider: const EPSProvider(
            id: '1',
            name: 'Sura',
            discoveryUrl: 'https://discovery.url',
            clientId: 'client_id',
            redirectUrl: 'redirect_url',
            scopes: ['openid'],
          ),
          token: const OAuthToken(accessToken: 'token'),
          patientId: 'patient_id',
          connectedAt: DateTime.now(),
        ),
      ];

      when(() => mockCubit.state).thenReturn(EpsConnectionLoaded(connections));

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<EpsConnectionCubit>.value(
          value: mockCubit,
          child: const EpsConnectionPage(),
        ),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'eps', '01_list');

      expect(find.text('Sura'), findsOneWidget);
    });
  });
}
