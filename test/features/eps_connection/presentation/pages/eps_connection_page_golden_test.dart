import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_cubit.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_connection.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/pages/eps_connection_page.dart';

class MockEpsConnectionCubit extends Mock implements EpsConnectionCubit {}

void main() {
  late MockEpsConnectionCubit mockCubit;

  setUp(() {
    mockCubit = MockEpsConnectionCubit();
  });

  testWidgets('EpsConnectionPage golden test', (tester) async {
    final connection = EPSConnection(
      provider: const EPSProvider(id: '1', name: 'Provider 1', discoveryUrl: 'D', clientId: 'C', redirectUrl: 'R', scopes: []),
      token: const OAuthToken(accessToken: 'A'),
      patientId: 'P1',
      connectedAt: DateTime(2023, 1, 1),
    );
    when(() => mockCubit.state).thenReturn(EpsConnectionLoaded([connection]));
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(EpsConnectionLoaded([connection])));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<EpsConnectionCubit>.value(
          value: mockCubit,
          child: const EpsConnectionPage(),
        ),
      ),
    );

    // This is a placeholder for a real golden test
    expect(find.byType(EpsConnectionPage), findsOneWidget);
  });
}
