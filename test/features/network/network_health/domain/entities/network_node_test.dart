import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_node.dart';

void main() {
  final lastSeen = DateTime(2023, 1, 1);
  final node1 = NetworkNode(
    id: '1',
    name: 'Node 1',
    address: '127.0.0.1',
    status: NodeStatus.online,
    lastSeen: lastSeen,
  );

  final node2 = NetworkNode(
    id: '1',
    name: 'Node 1',
    address: '127.0.0.1',
    status: NodeStatus.online,
    lastSeen: lastSeen,
  );

  final node3 = NetworkNode(
    id: '2',
    name: 'Node 2',
    address: '127.0.0.2',
    status: NodeStatus.offline,
    lastSeen: lastSeen,
  );

  group('NetworkNode', () {
    test('should support value equality', () {
      expect(node1, node2);
      expect(node1, isNot(node3));
    });

    test('copyWith should return a new object with updated values', () {
      final updated = node1.copyWith(status: NodeStatus.offline);
      expect(updated.status, NodeStatus.offline);
      expect(updated.id, node1.id);
    });
  });
}
