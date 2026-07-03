import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_connection.dart';

void main() {
  const connection1 = NetworkConnection(
    id: '1',
    sourceNodeId: 'node-a',
    targetNodeId: 'node-b',
    latency: 10.5,
    bandwidth: 100.0,
    isEncrypted: true,
  );

  const connection2 = NetworkConnection(
    id: '1',
    sourceNodeId: 'node-a',
    targetNodeId: 'node-b',
    latency: 10.5,
    bandwidth: 100.0,
    isEncrypted: true,
  );

  group('NetworkConnection', () {
    test('should support value equality', () {
      expect(connection1, connection2);
    });
  });
}
