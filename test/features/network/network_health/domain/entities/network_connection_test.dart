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

    group('copyWith', () {
      test('should return a copy with the same values when no arguments are provided', () {
        final result = connection1.copyWith();
        expect(result, connection1);
      });

      test('should return a copy with the updated id', () {
        final result = connection1.copyWith(id: '2');
        expect(result.id, '2');
        expect(result.sourceNodeId, connection1.sourceNodeId);
      });

      test('should return a copy with the updated sourceNodeId', () {
        final result = connection1.copyWith(sourceNodeId: 'node-c');
        expect(result.sourceNodeId, 'node-c');
        expect(result.id, connection1.id);
      });

      test('should return a copy with the updated targetNodeId', () {
        final result = connection1.copyWith(targetNodeId: 'node-d');
        expect(result.targetNodeId, 'node-d');
        expect(result.id, connection1.id);
      });

      test('should return a copy with the updated latency', () {
        final result = connection1.copyWith(latency: 20.0);
        expect(result.latency, 20.0);
        expect(result.id, connection1.id);
      });

      test('should return a copy with the updated bandwidth', () {
        final result = connection1.copyWith(bandwidth: 50.0);
        expect(result.bandwidth, 50.0);
        expect(result.id, connection1.id);
      });

      test('should return a copy with the updated isEncrypted', () {
        final result = connection1.copyWith(isEncrypted: false);
        expect(result.isEncrypted, false);
        expect(result.id, connection1.id);
      });
    });
  });
}
