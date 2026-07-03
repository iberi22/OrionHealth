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

    group('copyWith', () {
      test('should return a copy with the same values when no arguments are provided', () {
        final result = stats1.copyWith();
        expect(result, stats1);
      });

      test('should return a copy with the updated nodeId', () {
        final result = stats1.copyWith(nodeId: '2');
        expect(result.nodeId, '2');
        expect(result.cpuUsage, stats1.cpuUsage);
      });

      test('should return a copy with the updated cpuUsage', () {
        final result = stats1.copyWith(cpuUsage: 30.0);
        expect(result.cpuUsage, 30.0);
        expect(result.nodeId, stats1.nodeId);
      });

      test('should return a copy with the updated memoryUsage', () {
        final result = stats1.copyWith(memoryUsage: 50.0);
        expect(result.memoryUsage, 50.0);
        expect(result.nodeId, stats1.nodeId);
      });

      test('should return a copy with the updated diskUsage', () {
        final result = stats1.copyWith(diskUsage: 20.0);
        expect(result.diskUsage, 20.0);
        expect(result.nodeId, stats1.nodeId);
      });

      test('should return a copy with the updated uptime', () {
        final result = stats1.copyWith(uptime: Duration(hours: 12));
        expect(result.uptime, Duration(hours: 12));
        expect(result.nodeId, stats1.nodeId);
      });
    });
  });
}
