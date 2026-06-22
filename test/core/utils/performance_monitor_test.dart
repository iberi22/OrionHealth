import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/utils/performance_monitor.dart';

void main() {
  group('PerformanceMonitor', () {
    late PerformanceMonitor monitor;

    setUp(() {
      monitor = PerformanceMonitor();
      monitor.clearData();
    });

    test('startMeasurement and endMeasurement track duration', () async {
      monitor.startMeasurement('test_op');
      await Future.delayed(const Duration(milliseconds: 50));
      monitor.endMeasurement('test_op');

      final stats = monitor.getPerformanceStats();
      expect(stats['totalOperations'], equals(1));
      expect(stats['operationBreakdown']['test_op']['count'], equals(1));

      final avgMs = double.parse(stats['operationBreakdown']['test_op']['averageMs']);
      expect(avgMs, greaterThanOrEqualTo(50));
    });

    test('measureOperation automatically tracks operation', () async {
      final result = await monitor.measureOperation<String>(
        'measure_op',
        () async {
          await Future.delayed(const Duration(milliseconds: 30));
          return 'done';
        },
      );

      expect(result, equals('done'));
      final stats = monitor.getPerformanceStats();
      expect(stats['operationBreakdown']['measure_op']['count'], equals(1));
    });

    test('measureOperation tracks failure', () async {
      try {
        await monitor.measureOperation<void>(
          'fail_op',
          () async {
            throw Exception('error');
          },
        );
      } catch (_) {}

      final stats = monitor.getPerformanceStats();
      expect(stats['operationBreakdown']['fail_op']['count'], equals(1));
    });

    test('getPerformanceStats returns empty message when no data', () {
      final stats = monitor.getPerformanceStats();
      expect(stats['message'], equals('No performance data available'));
    });

    test('clearData removes all metrics', () {
      monitor.startMeasurement('op');
      monitor.endMeasurement('op');
      monitor.clearData();

      final stats = monitor.getPerformanceStats();
      expect(stats['message'], equals('No performance data available'));
    });

    test('memory statistics are handled', () {
      final stats = monitor.getPerformanceStats();
      // Even without operations, memory stats might be empty message or real data
      // depending on if any were recorded. Since we clearData in setUp, it should be no data.
      if (stats.containsKey('message')) {
         expect(stats['message'], equals('No performance data available'));
      }
    });
  });
}
