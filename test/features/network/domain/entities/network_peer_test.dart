import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/domain/entities/network_peer.dart';

void main() {
  group('NetworkPeer', () {
    test('should create NetworkPeer with correct values', () {
      final lastSeen = DateTime.now();
      final peer = NetworkPeer(
        peerId: 'peer123',
        name: 'Node A',
        address: '192.168.1.1',
        port: 8080,
        status: PeerStatus.online,
        lastSeen: lastSeen,
        publicKey: 'pubkey',
      );

      expect(peer.peerId, 'peer123');
      expect(peer.name, 'Node A');
      expect(peer.address, '192.168.1.1');
      expect(peer.port, 8080);
      expect(peer.status, PeerStatus.online);
      expect(peer.lastSeen, lastSeen);
      expect(peer.publicKey, 'pubkey');
    });
  });
}
