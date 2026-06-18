import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_cubit.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/eps_connect_button.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_connection.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';

class MockEpsConnectionCubit extends Mock implements EpsConnectionCubit {}

void main() {
  late MockEpsConnectionCubit mockCubit;

  setUp(() {
    mockCubit = MockEpsConnectionCubit();
  });

  testWidgets('EpsConnectButton shows connected state', (tester) async {
    final connection = EPSConnection(
      provider: const EPSProvider(id: '1', name: 'Provider 1', discoveryUrl: 'D', clientId: 'C', redirectUrl: 'R', scopes: []),
      token: const OAuthToken(accessToken: 'A'),
      patientId: 'P1',
      connectedAt: DateTime.now(),
    );
    when(() => mockCubit.state).thenReturn(EpsConnectionLoaded([connection]));
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(EpsConnectionLoaded([connection])));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<EpsConnectionCubit>.value(
            value: mockCubit,
            child: const EpsConnectButton(),
          ),
        ),
      ),
    );

    expect(find.text('Conectado con IHCE'), findsOneWidget);
    expect(find.text('ID Paciente: P1'), findsOneWidget);
    expect(find.text('Ver Detalles'), findsOneWidget);
  });

  testWidgets('EpsConnectButton shows disconnected state', (tester) async {
    when(() => mockCubit.state).thenReturn(const EpsConnectionLoaded([]));
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const EpsConnectionLoaded([])));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<EpsConnectionCubit>.value(
            value: mockCubit,
            child: const EpsConnectButton(),
          ),
        ),
      ),
    );

    expect(find.text('Conectar con mi EPS'), findsOneWidget);
  });
}
