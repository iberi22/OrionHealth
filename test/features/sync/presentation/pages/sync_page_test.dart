import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/sync/presentation/pages/sync_page.dart';
import 'package:orionhealth_health/features/sync/application/sync_cubit.dart';
import 'package:orionhealth_health/features/sync/application/sync_state.dart';
import 'package:orionhealth_health/features/sync/domain/entities/sync_node.dart';
import '../../../../core/golden_test_utils.dart';

class MockFhirSyncCubit extends Mock implements FhirSyncCubit {}

void main() {
  late MockFhirSyncCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(const SyncState());
  });

  setUp(() {
    mockCubit = MockFhirSyncCubit();
    GetIt.I.registerSingleton<FhirSyncCubit>(mockCubit);

    when(() => mockCubit.state).thenReturn(const SyncState());
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const SyncState()));
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('SyncPage Golden Tests', () {
    testWidgets('Sync Page - Initial State', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(const SyncPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(SyncPage),
        matchesGoldenFile('goldens/sync_page_initial.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Sync Page - With Nodes', (tester) async {
      setupGoldenTest(tester);

      const mockNode = SyncNode(
        id: 'node-123',
        name: 'Test Node',
        host: '192.168.1.100',
        port: 8080,
      );

      final stateWithNodes = const SyncState(discoveredNodes: [mockNode]);
      when(() => mockCubit.state).thenReturn(stateWithNodes);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(stateWithNodes));

      await tester.pumpWidget(wrapWithMaterial(const SyncPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(SyncPage),
        matchesGoldenFile('goldens/sync_page_with_nodes.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Sync Page - Syncing State', (tester) async {
      setupGoldenTest(tester);

      final syncingState = SyncState(
        status: SyncStatus.loading,
        lastSyncTime: DateTime(2025, 1, 1, 10, 0),
      );
      when(() => mockCubit.state).thenReturn(syncingState);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(syncingState));

      await tester.pumpWidget(wrapWithMaterial(const SyncPage()));
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(SyncPage),
        matchesGoldenFile('goldens/sync_page_syncing.png'),
      );
      resetGoldenTest(tester);
    });
  });

  group('SyncPage Interactions', () {
    testWidgets('triggers performSync when button pressed', (tester) async {
      when(() => mockCubit.performSync()).thenAnswer((_) async {});

      await tester.pumpWidget(wrapWithMaterial(const SyncPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SINCRONIZAR AHORA'));
      verify(() => mockCubit.performSync()).called(1);
    });
  });
}
