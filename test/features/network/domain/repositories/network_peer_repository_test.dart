import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/domain/entities/network_message.dart';
import 'package:orionhealth_health/features/network/domain/entities/network_peer.dart';
import 'package:orionhealth_health/features/network/domain/repositories/network_peer_repository.dart';

class MockNetworkPeerRepository extends Mock implements NetworkPeerRepository {}
class FakeNetworkPeer extends Fake implements NetworkPeer {}
class FakeNetworkMessage extends Fake implements NetworkMessage {}

void main() {
  late MockNetworkPeerRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeNetworkPeer());
    registerFallbackValue(FakeNetworkMessage());
  });

  setUp(() {
    mockRepository = MockNetworkPeerRepository();
  });

  group('NetworkPeerRepository Interface', () {
    test('can be mocked and called', () async {
      final tPeer = NetworkPeer(
        peerId: 'id',
        name: 'name',
        address: 'addr',
        port: 1,
        status: PeerStatus.online,
        lastSeen: DateTime.now(),
      );
      final tMessage = NetworkMessage(
        senderId: 's',
        receiverId: 'r',
        content: 'c',
        timestamp: DateTime.now(),
        type: MessageType.text,
      );

      when(() => mockRepository.getPeers()).thenAnswer((_) async => [tPeer]);
      when(() => mockRepository.getPeerById(any())).thenAnswer((_) async => tPeer);
      when(() => mockRepository.savePeer(any())).thenAnswer((_) async {});
      when(() => mockRepository.deletePeer(any())).thenAnswer((_) async {});
      when(() => mockRepository.getMessagesForPeer(any())).thenAnswer((_) async => [tMessage]);
      when(() => mockRepository.saveMessage(any())).thenAnswer((_) async {});

      final peers = await mockRepository.getPeers();
      final peer = await mockRepository.getPeerById('id');
      await mockRepository.savePeer(tPeer);
      await mockRepository.deletePeer('id');
      final messages = await mockRepository.getMessagesForPeer('id');
      await mockRepository.saveMessage(tMessage);

      expect(peers, [tPeer]);
      expect(peer, tPeer);
      expect(messages, [tMessage]);

      verify(() => mockRepository.getPeers()).called(1);
      verify(() => mockRepository.getPeerById('id')).called(1);
      verify(() => mockRepository.savePeer(tPeer)).called(1);
      verify(() => mockRepository.deletePeer('id')).called(1);
      verify(() => mockRepository.getMessagesForPeer('id')).called(1);
      verify(() => mockRepository.saveMessage(tMessage)).called(1);
    });
  });
}
