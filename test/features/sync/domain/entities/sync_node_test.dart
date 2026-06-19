import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/sync/domain/entities/sync_node.dart';

void main() {
  group('SyncNode', () {
    test('supports value equality', () {
      const node1 = SyncNode(
        id: '1',
        name: 'Node 1',
        host: 'localhost',
        port: 8080,
      );
      const node2 = SyncNode(
        id: '1',
        name: 'Node 1',
        host: 'localhost',
        port: 8080,
      );
      const node3 = SyncNode(
        id: '2',
        name: 'Node 2',
        host: '127.0.0.1',
        port: 9090,
      );

      expect(node1, equals(node2));
      expect(node1, isNot(equals(node3)));
    });

    test('props contains all fields', () {
      const node = SyncNode(
        id: '1',
        name: 'Node 1',
        host: 'localhost',
        port: 8080,
      );

      expect(node.props, containsAll(['1', 'Node 1', 'localhost', 8080]));
    });
  });
}
