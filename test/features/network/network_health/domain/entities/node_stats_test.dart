import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/node_stats.dart';

void main() {
  const stats1 = NodeStats(
    nodeId: '1',
    cpuUsage: 25.0,
    memoryUsage: 40.0,
    diskUsage: 15.0,
    uptime: Duration(hours: 10),
  );

  const stats2 = NodeStats(
    nodeId: '1',
    cpuUsage: 25.0,
    memoryUsage: 40.0,
    diskUsage: 15.0,
    uptime: Duration(hours: 10),
  );

  group('NodeStats', () {
    test('should support value equality', () {
      expect(stats1, stats2);
    });
  });
}
