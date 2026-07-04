import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/eps_connect_button.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_cubit.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_connection.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';
import '../../../../core/golden_test_utils.dart';

class MockEpsConnectionCubit extends Mock implements EpsConnectionCubit {}

void main() {
  late MockEpsConnectionCubit mockCubit;

  setUp(() {
    mockCubit = MockEpsConnectionCubit();
    when(() => mockCubit.close()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EpsConnectionCubit>.value(value: mockCubit),
      ],
      child: wrapWithMaterial(child),
    );
  }

  group('EpsConnectButton Golden Tests', () {
    final connection = EPSConnection(
      provider: const EPSProvider(
        id: 'ihce-1',
        name: 'IHCE',
        discoveryUrl: 'https://example.com/auth',
        revocationUrl: 'https://example.com/revoke',
        clientId: 'client-id',
        redirectUrl: 'com.example.app://oauth',
        scopes: ['openid', 'profile'],
      ),
      token: const OAuthToken(accessToken: 'dummy-token'),
      patientId: 'PAT-12345',
      connectedAt: DateTime(2025, 1, 1),
    );

    testWidgets('EpsConnectButton - Connected', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(EpsConnectionLoaded([connection]));
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(EpsConnectionLoaded([connection])));

      await tester.pumpWidget(createWidgetUnderTest(const Scaffold(body: Center(child: EpsConnectButton()))));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(EpsConnectButton),
        matchesGoldenFile("../../../../golden/reference/eps_connect_button_connected.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('EpsConnectButton - Disconnected', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const EpsConnectionLoaded([]));
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const EpsConnectionLoaded([])));

      await tester.pumpWidget(createWidgetUnderTest(const Scaffold(body: Center(child: EpsConnectButton()))));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(EpsConnectButton),
        matchesGoldenFile("../../../../golden/reference/eps_connect_button_disconnected.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('EpsConnectButton - Loading', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const EpsConnectionLoading());
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const EpsConnectionLoading()));

      await tester.pumpWidget(createWidgetUnderTest(const Scaffold(body: Center(child: EpsConnectButton()))));
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(EpsConnectButton),
        matchesGoldenFile("../../../../golden/reference/eps_connect_button_loading.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
