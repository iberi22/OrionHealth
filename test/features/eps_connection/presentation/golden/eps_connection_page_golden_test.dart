import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/pages/eps_connection_page.dart';
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
    // Default mock behavior
    when(() => mockCubit.close()).thenAnswer((_) async => {});
    when(() => mockCubit.disconnect(any())).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EpsConnectionCubit>.value(value: mockCubit),
      ],
      child: wrapWithMaterial(child),
    );
  }

  group('EpsConnectionPage Golden Tests', () {
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

    testWidgets('EpsConnectionPage - Loaded', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(EpsConnectionLoaded([connection]));
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(EpsConnectionLoaded([connection])));

      await tester.pumpWidget(createWidgetUnderTest(const EpsConnectionPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(EpsConnectionPage),
        matchesGoldenFile("goldens/eps_connection_page_loaded.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('EpsConnectionPage - Empty', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const EpsConnectionLoaded([]));
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const EpsConnectionLoaded([])));

      await tester.pumpWidget(createWidgetUnderTest(const EpsConnectionPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(EpsConnectionPage),
        matchesGoldenFile("goldens/eps_connection_page_empty.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('EpsConnectionPage - QR Scanner SnackBar', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const EpsConnectionLoaded([]));
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const EpsConnectionLoaded([])));

      await tester.pumpWidget(createWidgetUnderTest(const EpsConnectionPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Connect via QR Code'));
      // Wait for the SnackBar animation to complete to ensure a stable golden image
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(SnackBar),
        matchesGoldenFile("goldens/eps_connection_qr_snackbar.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
