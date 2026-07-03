import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_health.dart';

void main() {
  const health1 = NetworkHealth(
    status: NetworkStatus.healthy,
    activeNodes: 5,
    totalNodes: 5,
    averageLatency: 20.0,
    uptimePercentage: 99.9,
  );

  const health2 = NetworkHealth(
    status: NetworkStatus.healthy,
    activeNodes: 5,
    totalNodes: 5,
    averageLatency: 20.0,
    uptimePercentage: 99.9,
  );

  group('NetworkHealth', () {
    test('should support value equality', () {
      expect(health1, health2);
    });

    group('copyWith', () {
      test('should return a copy with the same values when no arguments are provided', () {
        final result = health1.copyWith();
        expect(result, health1);
      });

      test('should return a copy with the updated status', () {
        final result = health1.copyWith(status: NetworkStatus.congested);
        expect(result.status, NetworkStatus.congested);
        expect(result.activeNodes, health1.activeNodes);
      });

      test('should return a copy with the updated activeNodes', () {
        final result = health1.copyWith(activeNodes: 4);
        expect(result.activeNodes, 4);
        expect(result.status, health1.status);
      });

      test('should return a copy with the updated totalNodes', () {
        final result = health1.copyWith(totalNodes: 6);
        expect(result.totalNodes, 6);
        expect(result.status, health1.status);
      });

      test('should return a copy with the updated averageLatency', () {
        final result = health1.copyWith(averageLatency: 25.0);
        expect(result.averageLatency, 25.0);
        expect(result.status, health1.status);
      });

      test('should return a copy with the updated uptimePercentage', () {
        final result = health1.copyWith(uptimePercentage: 98.0);
        expect(result.uptimePercentage, 98.0);
        expect(result.status, health1.status);
      });
    });
  });
}
