import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/features/home/presentation/pages/home_page.dart';

class MockHomeCubit extends Mock implements HomeCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;
  late StreamController<HomeState> stateController;

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    stateController = StreamController<HomeState>.broadcast();

    when(() => mockHomeCubit.state).thenReturn(const HomeState());
    when(() => mockHomeCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockHomeCubit.close()).thenAnswer((_) async => stateController.close());
  });

  tearDown(() {
    stateController.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: Scaffold(
        body: BlocProvider<HomeCubit>.value(
          value: mockHomeCubit,
          child: const IndexingStatusBanner(),
        ),
      ),
    );
  }

  testWidgets('IndexingStatusBanner shows "Sincronizando..." when indexing is true', (WidgetTester tester) async {
    when(() => mockHomeCubit.state).thenReturn(const HomeState(isIndexing: true));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Sincronizando estándares médicos...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('IndexingStatusBanner shows success message when indexing finishes', (WidgetTester tester) async {
    // Start with indexing
    when(() => mockHomeCubit.state).thenReturn(const HomeState(isIndexing: true));

    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Sincronizando estándares médicos...'), findsOneWidget);

    // Emit state where indexing is false
    when(() => mockHomeCubit.state).thenReturn(const HomeState(isIndexing: false));
    stateController.add(const HomeState(isIndexing: false));

    await tester.pump(); // Start animation/rebuild

    expect(find.text('Estándares médicos actualizados'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    // Drain timer to avoid pending timer error
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('IndexingStatusBanner hides after success message duration', (WidgetTester tester) async {
    // Start with indexing
    when(() => mockHomeCubit.state).thenReturn(const HomeState(isIndexing: true));

    await tester.pumpWidget(createWidgetUnderTest());

    // Finish indexing
    when(() => mockHomeCubit.state).thenReturn(const HomeState(isIndexing: false));
    stateController.add(const HomeState(isIndexing: false));

    await tester.pump();
    expect(find.text('Estándares médicos actualizados'), findsOneWidget);

    // Wait for 3 seconds + some buffer
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Estándares médicos actualizados'), findsNothing);
    expect(find.byType(Container), findsNothing); // Should be SizedBox.shrink()
  });

  testWidgets('IndexingStatusBanner shows error message and retry button when indexingError is true', (WidgetTester tester) async {
    when(() => mockHomeCubit.state).thenReturn(const HomeState(indexingError: true));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Error al sincronizar estándares médicos'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('Retry button calls HomeCubit.retryIndexing', (WidgetTester tester) async {
    when(() => mockHomeCubit.state).thenReturn(const HomeState(indexingError: true));
    when(() => mockHomeCubit.retryIndexing()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Reintentar'));
    verify(() => mockHomeCubit.retryIndexing()).called(1);
  });
}
