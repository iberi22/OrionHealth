import 'dart:async';
import 'package:bonsoir/bonsoir.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/sync_node.dart';
import '../../domain/services/node_discovery_service.dart' as domain;

/// Service for discovering OrionHealth nodes on the local network using mDNS.
@LazySingleton(as: domain.NodeDiscoveryService)
class NodeDiscoveryService implements domain.NodeDiscoveryService {
  static const String _serviceType = '_orion-sync._tcp';

  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;

  final _discoveredNodesController = StreamController<List<SyncNode>>.broadcast();
  final Map<String, SyncNode> _nodes = {};

  @override
  Stream<List<SyncNode>> get discoveredNodes => _discoveredNodesController.stream;

  @override
  List<SyncNode> get currentNodes => _nodes.values.toList();

  /// Starts advertising this node and browsing for others.
  @override
  Future<void> start(String nodeId, int port) async {
    // 1. Broadcast our presence
    final service = BonsoirService(
      name: 'OrionNode-$nodeId',
      type: _serviceType,
      port: port,
      attributes: {'nodeId': nodeId},
    );

    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast!.start();

    // 2. Discover others
    _discovery = BonsoirDiscovery(type: _serviceType);

    _discovery?.eventStream?.listen((event) {
      if (event is BonsoirDiscoveryServiceFoundEvent) {
        final resolver = _discovery?.serviceResolver;
        if (resolver != null) {
          event.service.resolve(resolver);
        }
      } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
        final syncNode = _mapToSyncNode(event.service);
        _nodes[event.service.name] = syncNode;
        _notify();
      } else if (event is BonsoirDiscoveryServiceLostEvent) {
        _nodes.remove(event.service.name);
        _notify();
      }
    });

    await _discovery!.start();
  }

  void _notify() {
    _discoveredNodesController.add(currentNodes);
  }

  /// Stops advertising and discovery.
  @override
  Future<void> stop() async {
    await _broadcast?.stop();
    await _discovery?.stop();
    _nodes.clear();
    _notify();
  }

  SyncNode _mapToSyncNode(BonsoirService node) {
    return SyncNode(
      id: node.attributes['nodeId'] ?? node.name,
      name: node.name,
      host: node.hostname ?? 'unknown',
      port: node.port,
    );
  }
}
