import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/features/sync/presentation/pages/sync_page.dart';
import 'package:orionhealth_health/features/sync/application/sync_cubit.dart';
import 'package:orionhealth_health/features/sync/domain/services/sync_service.dart';
import 'package:orionhealth_health/features/sync/domain/services/node_discovery_service.dart';
import 'package:orionhealth_health/features/sync/domain/entities/sync_node.dart';
import 'utils/video_recorder.dart';

class MockSyncService extends Mock implements SyncService {}
class MockNodeDiscoveryService extends Mock implements NodeDiscoveryService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockSyncService mockSyncService;
  late MockNodeDiscoveryService mockDiscoveryService;

  setUp(() {
    mockSyncService = MockSyncService();
    mockDiscoveryService = MockNodeDiscoveryService();

    when(() => mockDiscoveryService.discoveredNodes).thenAnswer((_) => Stream.value([]));
    when(() => mockDiscoveryService.currentNodes).thenReturn([]);
    when(() => mockSyncService.getLastSyncTime()).thenAnswer((_) async => null);
  });

  Widget buildTestWidget(FhirSyncCubit cubit) {
    return MaterialApp(
      home: BlocProvider<FhirSyncCubit>.value(
        value: cubit,
        child: const SyncPage(),
      ),
      theme: ThemeData.dark(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
    );
  }

  group('E2E Offline Sync Flow', () {
    testWidgets('E2E Offline: Airplane mode fails gracefully and reconnects to sync successfully',
        (WidgetTester tester) async {
      // Step 1: Simulate Airplane Mode (Offline)
      when(() => mockSyncService.performFullSync())
          .thenThrow(const SocketException('Sin conexión a Internet (Modo Avión)'));

      final cubit = FhirSyncCubit(mockSyncService, mockDiscoveryService);

      await tester.pumpWidget(buildTestWidget(cubit));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'offline_sync', '01_offline_initial');

      expect(find.text('Sincronización'), findsWidgets);
      expect(find.text('SINCRONIZAR AHORA'), findsOneWidget);

      // Tap sync while offline
      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pump();
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'offline_sync', '02_offline_error');

      // Verify error message is displayed
      expect(find.textContaining('Sin conexión'), findsOneWidget);

      // Step 2: Reconnect (Online)
      final now = DateTime.now();
      when(() => mockSyncService.performFullSync()).thenAnswer((_) async {});
      when(() => mockSyncService.getLastSyncTime()).thenAnswer((_) async => now);

      // Tap sync after reconnecting
      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pump();
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'offline_sync', '03_online_success');

      // Verify success state in UI
      expect(find.textContaining('Éxito'), findsWidgets);

      cubit.close();
    });

    testWidgets('E2E Offline: Discovered P2P nodes appear during offline mesh networking',
        (WidgetTester tester) async {
      const offlinePeer = SyncNode(
        id: 'peer_mesh_1',
        name: 'Nodo Local P2P',
        host: '192.168.1.200',
        port: 9124,
      );

      when(() => mockDiscoveryService.discoveredNodes)
          .thenAnswer((_) => Stream.value([offlinePeer]));
      when(() => mockDiscoveryService.currentNodes).thenReturn([offlinePeer]);

      final cubit = FhirSyncCubit(mockSyncService, mockDiscoveryService);

      await tester.pumpWidget(buildTestWidget(cubit));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'offline_sync', '04_mesh_nodes');

      expect(find.text('Nodo Local P2P'), findsOneWidget);

      cubit.close();
    });
  });
}
