import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/network/presentation/pages/network_overview_page.dart';
import 'package:orionhealth_health/features/network/application/network_cubit.dart';
import 'package:orionhealth_health/features/network/application/network_state.dart';
import 'package:orionhealth_health/features/network/domain/entities/network_peer.dart';
import '../../../../core/golden_test_utils.dart';

class MockNetworkCubit extends Mock implements NetworkCubit {}

void main() {
  late MockNetworkCubit mockNetworkCubit;

  setUp(() {
    mockNetworkCubit = MockNetworkCubit();
    when(() => mockNetworkCubit.loadNetworkData()).thenAnswer((_) async {});
    when(() => mockNetworkCubit.close()).thenAnswer((_) async {});
    when(() => mockNetworkCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  group('NetworkOverviewPage Golden Tests', () {
    testWidgets('NetworkOverviewPage - loading state', (tester) async {
      setupGoldenTest(tester);
      when(() => mockNetworkCubit.state).thenReturn(NetworkLoading());

      await tester.pumpWidget(
        BlocProvider<NetworkCubit>.value(
          value: mockNetworkCubit,
          child: const MaterialApp(home: NetworkOverviewPage()),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(NetworkOverviewPage),
        matchesGoldenFile('goldens/network_page_loading.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('NetworkOverviewPage - loaded state', (tester) async {
      setupGoldenTest(tester);
      final peers = [
        NetworkPeer(
          peerId: '1',
          name: 'Peer 1',
          address: '192.168.1.1',
          port: 8080,
          status: PeerStatus.online,
          lastSeen: DateTime(2026, 7, 8),
        ),
        NetworkPeer(
          peerId: '2',
          name: 'Peer 2',
          address: '192.168.1.2',
          port: 8081,
          status: PeerStatus.offline,
          lastSeen: DateTime(2026, 7, 7),
        ),
      ];

      when(() => mockNetworkCubit.state).thenReturn(NetworkLoaded(peers: peers, messages: const []));

      await tester.pumpWidget(
        BlocProvider<NetworkCubit>.value(
          value: mockNetworkCubit,
          child: const MaterialApp(home: NetworkOverviewPage()),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(NetworkOverviewPage),
        matchesGoldenFile('goldens/network_page_loaded.png'),
      );
      resetGoldenTest(tester);
    });
  });
}
