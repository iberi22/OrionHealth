import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/network_message.dart';
import '../../domain/entities/network_peer.dart';
import '../../domain/repositories/network_peer_repository.dart';

@LazySingleton(as: NetworkPeerRepository)
class NetworkPeerRepositoryImpl implements NetworkPeerRepository {
  final Isar _isar;

  NetworkPeerRepositoryImpl(this._isar);

  @override
  Future<void> deletePeer(String peerId) async {
    await _isar.writeTxn(() async {
      await _isar.networkPeers.filter().peerIdEqualTo(peerId).deleteAll();
    });
  }

  @override
  Future<NetworkPeer?> getPeerById(String peerId) {
    return _isar.networkPeers.filter().peerIdEqualTo(peerId).findFirst();
  }

  @override
  Future<List<NetworkPeer>> getPeers() {
    return _isar.networkPeers.where().findAll();
  }

  @override
  Future<void> savePeer(NetworkPeer peer) async {
    await _isar.writeTxn(() async {
      await _isar.networkPeers.put(peer);
    });
  }

  @override
  Future<List<NetworkMessage>> getMessagesForPeer(String peerId) {
    return _isar.networkMessages
        .filter()
        .senderIdEqualTo(peerId)
        .or()
        .receiverIdEqualTo(peerId)
        .sortByTimestampDesc()
        .findAll();
  }

  @override
  Future<void> saveMessage(NetworkMessage message) async {
    await _isar.writeTxn(() async {
      await _isar.networkMessages.put(message);
    });
  }
}
