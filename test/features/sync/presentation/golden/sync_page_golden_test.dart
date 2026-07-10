import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/features/sync/presentation/pages/sync_page.dart';
import 'package:orionhealth_health/features/sync/application/sync_cubit.dart';
import 'package:orionhealth_health/features/sync/application/sync_state.dart';
import 'package:orionhealth_health/features/sync/domain/entities/sync_node.dart';
import '../../../../core/golden_test_utils.dart';

class MockSyncCubit extends Mock implements FhirSyncCubit {}

void main() {
  late MockSyncCubit mockCubit;

  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  setUp(() async {
    mockCubit = MockSyncCubit();
    await GetIt.I.reset();
    GetIt.I.registerSingleton<FhirSyncCubit>(mockCubit);

    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Sync Page Golden Tests', () {
    testWidgets('Sync Page - Initial with Nodes', (tester) async {
      setupGoldenTest(tester);

      final state = SyncState(
        status: SyncStatus.initial,
        lastSyncTime: DateTime(2026, 6, 14, 15, 30),
        discoveredNodes: const [
          SyncNode(id: '1', name: 'Nodo Sala Principal', host: '192.168.1.15', port: 8080),
          SyncNode(id: '2', name: 'Orion Hub Cocina', host: '192.168.1.22', port: 8080),
        ],
      );

      when(() => mockCubit.state).thenReturn(state);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));

      await tester.pumpWidget(wrapWithMaterial(const SyncPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(SyncPage),
        matchesGoldenFile("../../../../../golden/reference/sync_page_initial.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Sync Page - Loading State', (tester) async {
      setupGoldenTest(tester);

      final state = SyncState(
        status: SyncStatus.loading,
        lastSyncTime: DateTime(2026, 6, 14, 15, 30),
      );

      when(() => mockCubit.state).thenReturn(state);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));

      await tester.pumpWidget(wrapWithMaterial(const SyncPage()));
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(SyncPage),
        matchesGoldenFile("../../../../../golden/reference/sync_page_loading.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
