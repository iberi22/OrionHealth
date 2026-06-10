import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/domain/sync_cubit.dart';
import 'package:orionhealth_health/features/sync/presentation/sync_status_widget.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'dart:async';

class MockFhirSyncCubit extends Mock implements FhirSyncCubit {
  final _stateController = StreamController<SyncState>.broadcast();

  @override
  Stream<SyncState> get stream => _stateController.stream;

  @override
  Future<void> close() => _stateController.close();

  void emit(SyncState state) => _stateController.add(state);
}

void main() {
  late MockFhirSyncCubit mockCubit;

  setUpAll(() {
    mockCubit = MockFhirSyncCubit();
    getIt.registerSingleton<FhirSyncCubit>(mockCubit);
  });

  setUp(() {
    reset(mockCubit);
    // Remove buggy stubs
    when(() => mockCubit.state).thenReturn(const SyncState());
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold(
        body: SyncStatusWidget(),
      ),
    );
  }

  testWidgets('renders initial state correctly', (tester) async {
    when(() => mockCubit.state).thenReturn(const SyncState());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Sincronización IHCE'), findsOneWidget);
    expect(find.text('Última sincronización: Nunca'), findsOneWidget);
    expect(find.byIcon(Icons.sync), findsOneWidget);
  });

  testWidgets('renders loading state', (tester) async {
    when(() => mockCubit.state).thenReturn(const SyncState(status: SyncStatus.loading));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.sync), findsNothing);
  });

  testWidgets('calls performSync when sync button is pressed', (tester) async {
    when(() => mockCubit.state).thenReturn(const SyncState());
    when(() => mockCubit.performSync()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.byIcon(Icons.sync));
    await tester.pump();

    verify(() => mockCubit.performSync()).called(1);
  });

  testWidgets('shows snackbar on success', (tester) async {
    when(() => mockCubit.state).thenReturn(const SyncState());

    await tester.pumpWidget(createWidgetUnderTest());

    mockCubit.emit(const SyncState(status: SyncStatus.loading));
    await tester.pump();
    mockCubit.emit(const SyncState(status: SyncStatus.success));
    await tester.pump();

    expect(find.text('Sincronización exitosa'), findsOneWidget);
  });

  testWidgets('shows snackbar on failure', (tester) async {
    when(() => mockCubit.state).thenReturn(const SyncState());

    await tester.pumpWidget(createWidgetUnderTest());

    mockCubit.emit(const SyncState(status: SyncStatus.loading));
    await tester.pump();
    mockCubit.emit(const SyncState(status: SyncStatus.failure, errorMessage: 'Network Error'));
    await tester.pump();

    expect(find.text('Error: Network Error'), findsOneWidget);
  });
}
