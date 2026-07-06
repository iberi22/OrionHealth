import 'package:injectable/injectable.dart';
import '../../domain/entities/network_message.dart';
import '../../domain/entities/network_peer.dart';

abstract class NetworkP2PApi {
  Future<void> sendMessage(NetworkPeer peer, NetworkMessage message);
  Stream<NetworkMessage> get messageStream;
  Future<List<NetworkPeer>> discoverPeers();
}

@LazySingleton(as: NetworkP2PApi)
class NetworkP2PApiImpl implements NetworkP2PApi {
  @override
  Future<List<NetworkPeer>> discoverPeers() async {
    // Basic implementation placeholder
    return [];
  }

  @override
  Stream<NetworkMessage> get messageStream => const Stream.empty();

  @override
  Future<void> sendMessage(NetworkPeer peer, NetworkMessage message) async {
    // Basic implementation placeholder
  }
}
