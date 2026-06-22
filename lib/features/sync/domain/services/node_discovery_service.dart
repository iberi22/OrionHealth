import '../entities/sync_node.dart';

/// Interface for discovering OrionHealth nodes on the local network.
abstract class NodeDiscoveryService {
  /// Stream of discovered nodes.
  Stream<List<SyncNode>> get discoveredNodes;

  /// Returns the current list of discovered nodes.
  List<SyncNode> get currentNodes;

  /// Starts advertising this node and browsing for others.
  Future<void> start(String nodeId, int port);

  /// Stops advertising and discovery.
  Future<void> stop();
}
