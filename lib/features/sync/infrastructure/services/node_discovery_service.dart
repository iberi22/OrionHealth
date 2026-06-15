import 'dart:async';
import 'package:bonsoir/bonsoir.dart';
import 'package:injectable/injectable.dart';

/// Service for discovering OrionHealth nodes on the local network using mDNS.
@lazySingleton
class NodeDiscoveryService {
  static const String _serviceType = '_orion-sync._tcp';

  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;

  final _discoveredNodesController = StreamController<List<BonsoirService>>.broadcast();
  final Map<String, BonsoirService> _nodes = {};

  Stream<List<BonsoirService>> get discoveredNodes => _discoveredNodesController.stream;
  List<BonsoirService> get currentNodes => _nodes.values.toList();

  /// Starts advertising this node and browsing for others.
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
        _nodes[event.service.name] = event.service;
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
  Future<void> stop() async {
    await _broadcast?.stop();
    await _discovery?.stop();
    _nodes.clear();
    _notify();
  }
}
