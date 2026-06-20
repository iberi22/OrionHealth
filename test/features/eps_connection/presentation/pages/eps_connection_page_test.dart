import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_cubit.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/pages/eps_connection_page.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_connection.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';

class MockEpsConnectionCubit extends Mock implements EpsConnectionCubit {}

void main() {
  late MockEpsConnectionCubit mockCubit;

  setUp(() {
    mockCubit = MockEpsConnectionCubit();
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EpsConnectionCubit>.value(value: mockCubit),
      ],
      child: const MaterialApp(
        home: EpsConnectionPage(),
      ),
    );
  }

  testWidgets('EpsConnectionPage shows loading indicator when state is Loading', (tester) async {
    when(() => mockCubit.state).thenReturn(const EpsConnectionLoading());
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const EpsConnectionLoading()));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('EpsConnectionPage shows empty message when no connections', (tester) async {
    when(() => mockCubit.state).thenReturn(const EpsConnectionLoaded([]));
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const EpsConnectionLoaded([])));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('No EPS providers connected'), findsOneWidget);
    expect(find.text('Connect via QR Code'), findsOneWidget);
  });

  testWidgets('EpsConnectionPage shows connections list and handles disconnect', (tester) async {
    final connection = EPSConnection(
      provider: const EPSProvider(id: '1', name: 'Provider 1', discoveryUrl: 'D', clientId: 'C', redirectUrl: 'R', scopes: []),
      token: const OAuthToken(accessToken: 'A'),
      patientId: 'P1',
      connectedAt: DateTime.now(),
    );
    when(() => mockCubit.state).thenReturn(EpsConnectionLoaded([connection]));
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(EpsConnectionLoaded([connection])));
    when(() => mockCubit.disconnect(any())).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Provider 1'), findsOneWidget);

    // Tap disconnect in the card
    await tester.tap(find.byIcon(Icons.link_off));
    await tester.pump();

    verify(() => mockCubit.disconnect('1')).called(1);
  });

  testWidgets('EpsConnectionPage shows error SnackBar', (tester) async {
    when(() => mockCubit.state).thenReturn(const EpsConnectionInitial());
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const EpsConnectionError('Failed to load')));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // trigger listener

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Failed to load'), findsOneWidget);
  });

  testWidgets('Connect via QR Code tap shows SnackBar', (tester) async {
    when(() => mockCubit.state).thenReturn(const EpsConnectionLoaded([]));
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const EpsConnectionLoaded([])));

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Connect via QR Code'));
    await tester.pump();

    expect(find.text('QR scanner coming soon'), findsOneWidget);
  });
}
