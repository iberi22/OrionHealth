import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/presentation/widgets/peer_list_item.dart';
import 'package:orionhealth_health/features/network/domain/entities/network_peer.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('PeerListItem Golden Tests', () {
    testWidgets('PeerListItem - online peer', (tester) async {
      setupGoldenTest(tester);

      final peer = NetworkPeer(
        peerId: 'peer-1',
        name: 'Alice Node',
        address: '192.168.1.100',
        port: 8080,
        status: PeerStatus.online,
        lastSeen: DateTime(2026, 7, 8, 10, 30),
      );

      await tester.pumpWidget(wrapWithMaterial(
        Material(
          child: PeerListItem(peer: peer),
        ),
      ));
      await tester.pump();

      await expectLater(
        find.byType(PeerListItem),
        matchesGoldenFile('goldens/peer_list_item_online.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('PeerListItem - offline peer', (tester) async {
      setupGoldenTest(tester);

      final peer = NetworkPeer(
        peerId: 'peer-2',
        name: 'Bob Gateway',
        address: '192.168.1.101',
        port: 8081,
        status: PeerStatus.offline,
        lastSeen: DateTime(2026, 7, 7, 15, 0),
      );

      await tester.pumpWidget(wrapWithMaterial(
        Material(
          child: PeerListItem(peer: peer),
        ),
      ));
      await tester.pump();

      await expectLater(
        find.byType(PeerListItem),
        matchesGoldenFile('goldens/peer_list_item_offline.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('PeerListItem - blocked peer', (tester) async {
      setupGoldenTest(tester);

      final peer = NetworkPeer(
        peerId: 'peer-3',
        name: 'Eve Attacker',
        address: '10.0.0.50',
        port: 9090,
        status: PeerStatus.blocked,
        lastSeen: DateTime(2026, 7, 6, 8, 0),
      );

      await tester.pumpWidget(wrapWithMaterial(
        Material(
          child: PeerListItem(peer: peer),
        ),
      ));
      await tester.pump();

      await expectLater(
        find.byType(PeerListItem),
        matchesGoldenFile('goldens/peer_list_item_blocked.png'),
      );
      resetGoldenTest(tester);
    });
  });
}
