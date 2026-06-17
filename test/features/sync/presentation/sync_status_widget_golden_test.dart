import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/domain/sync_cubit.dart';
import 'package:orionhealth_health/features/sync/presentation/sync_status_widget.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'dart:async';
import '../../../../core/golden_test_utils.dart';

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

  setUpAll(() async {
    await getIt.reset();
    mockCubit = MockFhirSyncCubit();
    getIt.registerSingleton<FhirSyncCubit>(mockCubit);
  });

  setUp(() {
    reset(mockCubit);
    when(() => mockCubit.state).thenReturn(const SyncState());
  });

  testWidgets('Sync Status Widget - Initial State', (tester) async {
    setupGoldenTest(tester);
    when(() => mockCubit.state).thenReturn(const SyncState());

    await tester.pumpWidget(wrapWithMaterial(
      const Scaffold(body: SyncStatusWidget()),
    ));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(SyncStatusWidget),
      matchesGoldenFile("../../../../golden/reference/sync_status_initial.png"),
    );
    resetGoldenTest(tester);
  });

  testWidgets('Sync Status Widget - Loading State', (tester) async {
    setupGoldenTest(tester);
    when(() => mockCubit.state).thenReturn(
      const SyncState(status: SyncStatus.loading),
    );

    await tester.pumpWidget(wrapWithMaterial(
      const Scaffold(body: SyncStatusWidget()),
    ));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(SyncStatusWidget),
      matchesGoldenFile("../../../../golden/reference/sync_status_loading.png"),
    );
    resetGoldenTest(tester);
  });
}
