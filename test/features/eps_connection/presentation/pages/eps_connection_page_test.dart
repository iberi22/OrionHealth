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
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_providers_catalog.dart';

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

  testWidgets('EpsConnectionPage shows catalog providers when state is EpsConnectionCatalog', (tester) async {
    // Use a small subset to speed up test
    final subset = EpsProvidersCatalog.activeProviders.take(5).toList();
    final catalog = EpsConnectionCatalog(
      availableProviders: subset,
      connections: const [],
      connectedProviderIds: const [],
    );
    when(() => mockCubit.state).thenReturn(catalog);
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(catalog));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Should show header "28 EPS disponibles"
    expect(find.text('28 EPS disponibles'), findsOneWidget);
    // Should show search bar
    expect(find.text('Buscar EPS por nombre...'), findsOneWidget);
    // Should show regime filters
    expect(find.text('Todas'), findsOneWidget);
  });

  testWidgets('EpsConnectionPage shows search bar', (tester) async {
    final subset = EpsProvidersCatalog.activeProviders.take(3).toList();
    final catalog = EpsConnectionCatalog(
      availableProviders: subset,
      connections: const [],
      connectedProviderIds: const [],
    );
    when(() => mockCubit.state).thenReturn(catalog);
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(catalog));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Buscar EPS por nombre...'), findsOneWidget);
  });

  testWidgets('EpsConnectionPage shows regime filters', (tester) async {
    final subset = EpsProvidersCatalog.activeProviders.take(2).toList();
    final catalog = EpsConnectionCatalog(
      availableProviders: subset,
      connections: const [],
      connectedProviderIds: const [],
    );
    when(() => mockCubit.state).thenReturn(catalog);
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(catalog));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Regime filter chips present
    expect(find.text('Todas'), findsOneWidget);
    expect(find.text('Contributivo'), findsOneWidget);
    expect(find.text('Subsidiado'), findsOneWidget);
  });

  testWidgets('EpsConnectionPage shows connections when present', (tester) async {
    final connection = EPSConnection(
      provider: const EPSProvider(id: 'EPS025', name: 'EPS SURA', discoveryUrl: 'D', clientId: 'C', redirectUrl: 'R', scopes: []),
      token: const OAuthToken(accessToken: 'A'),
      patientId: 'P1',
      connectedAt: DateTime.now(),
    );
    final catalog = EpsConnectionCatalog(
      availableProviders: EpsProvidersCatalog.activeProviders.take(5).toList(),
      connections: [connection],
      connectedProviderIds: ['EPS025'],
    );
    when(() => mockCubit.state).thenReturn(catalog);
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(catalog));
    when(() => mockCubit.disconnect(any())).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Disconnect button
    await tester.tap(find.byIcon(Icons.link_off));
    await tester.pump();

    verify(() => mockCubit.disconnect('EPS025')).called(1);
  });

  testWidgets('EpsConnectionPage handles error state gracefully', (tester) async {
    final errorState = EpsConnectionError('Failed to load');
    when(() => mockCubit.state).thenReturn(errorState);
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(errorState));

    // If cubit is provided via constructor, wrap happens in _buildBody
    await tester.pumpWidget(MaterialApp(
      home: EpsConnectionPage(cubit: mockCubit),
    ));
    await tester.pump();

    // Error state shows retry button
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Failed to load'), findsOneWidget);
  });
}
