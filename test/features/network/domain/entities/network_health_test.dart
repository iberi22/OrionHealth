import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/domain/entities/network_health.dart';

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
  });
}
