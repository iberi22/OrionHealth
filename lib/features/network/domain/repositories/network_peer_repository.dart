import '../entities/network_peer.dart';
import '../entities/network_message.dart';

abstract class NetworkPeerRepository {
  Future<List<NetworkPeer>> getPeers();
  Future<NetworkPeer?> getPeerById(String peerId);
  Future<void> savePeer(NetworkPeer peer);
  Future<void> deletePeer(String peerId);

  Future<List<NetworkMessage>> getMessagesForPeer(String peerId);
  Future<void> saveMessage(NetworkMessage message);
}
