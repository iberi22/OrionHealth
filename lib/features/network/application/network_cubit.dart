import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/network_message.dart';
import '../domain/entities/network_peer.dart';
import '../domain/repositories/network_peer_repository.dart';
import '../infrastructure/datasources/network_p2p_api.dart';
import 'network_state.dart';

@injectable
class NetworkCubit extends Cubit<NetworkState> {
  final NetworkPeerRepository _repository;
  final NetworkP2PApi _p2pApi;

  NetworkCubit(this._repository, this._p2pApi) : super(NetworkInitial());

  Future<void> loadNetworkData() async {
    emit(NetworkLoading());
    try {
      final peers = await _repository.getPeers();
      // For the overview, we might want to show recent messages or none
      // For now, let's just fetch all peers as before but maybe could fetch summary
      emit(NetworkLoaded(peers: peers, messages: const []));
    } catch (e) {
      emit(NetworkError(e.toString()));
    }
  }

  Future<void> discoverPeers() async {
    try {
      final discoveredPeers = await _p2pApi.discoverPeers();
      for (var peer in discoveredPeers) {
        await _repository.savePeer(peer);
      }
      await loadNetworkData();
    } catch (e) {
      emit(NetworkError(e.toString()));
    }
  }

  Future<void> sendMessage(NetworkPeer peer, String content) async {
    try {
      final message = NetworkMessage(
        senderId: 'me', // Local node ID
        receiverId: peer.peerId,
        content: content,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );
      await _p2pApi.sendMessage(peer, message);
      await _repository.saveMessage(message);
      await loadNetworkData();
    } catch (e) {
      emit(NetworkError(e.toString()));
    }
  }
}
