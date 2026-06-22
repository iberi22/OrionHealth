import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/utils/isolate_manager.dart';

void main() {
  group('IsolateManager', () {
    late IsolateManager isolateManager;

    setUp(() {
      isolateManager = IsolateManager();
    });

    tearDown(() async {
      await isolateManager.terminateAll();
    });

    test('getWorker creates and initializes a worker', () async {
      final worker = await isolateManager.getWorker('test_task');
      expect(worker.isActive, isTrue);
      expect(worker.taskType, equals('test_task'));
    });

    test('getWorker reuses existing active worker', () async {
      final worker1 = await isolateManager.getWorker('test_task');
      final worker2 = await isolateManager.getWorker('test_task');

      expect(worker2, same(worker1));
    });

    test('terminateWorker removes worker', () async {
      await isolateManager.getWorker('test_task');
      await isolateManager.terminateWorker('test_task');

      final stats = isolateManager.getStats();
      expect(stats['totalWorkers'], equals(0));
    });

    test('LRU policy terminates oldest worker when max reached', () async {
      // Create 4 workers (maxWorkers is 4)
      await isolateManager.getWorker('w1');
      await isolateManager.getWorker('w2');
      await isolateManager.getWorker('w3');
      await isolateManager.getWorker('w4');

      final stats1 = isolateManager.getStats();
      expect(stats1['activeWorkers'], equals(4));

      // Create 5th worker, should terminate w1 (the oldest)
      await isolateManager.getWorker('w5');

      final stats2 = isolateManager.getStats();
      expect(stats2['activeWorkers'], equals(4));
      // In IsolateManager.getStats(), the 'workers' map is the internal _workers map
      // which contains entries for terminated workers too, until they are removed.
      // But getWorker only terminates it, it doesn't remove it from the map if it was just terminated.
      // Actually, terminate() just sets _isActive to false.
      expect(stats2['workers']['w1']['isActive'], isFalse);
      expect(stats2['workers']['w5']['isActive'], isTrue);
    });

    test('getStats returns correct information', () async {
      await isolateManager.getWorker('test_task');

      final stats = isolateManager.getStats();
      expect(stats['totalWorkers'], equals(1));
      expect(stats['workers']['test_task']['isActive'], isTrue);
    });

    // Note: executeTask is hard to test in unit tests because it requires
    // passing a top-level function or static method to Isolate.spawn.
    // The IsolateTasks class provides these.
  });

  group('IsolateTasks', () {
    test('processAIResponse trims response', () async {
      final result = await IsolateTasks.processAIResponse({'response': '  hello  '});
      expect(result, equals('hello'));
    });

    test('processAudioData normalizes bytes', () async {
      final result = await IsolateTasks.processAudioData([0, 255, 127]);
      expect(result[0], equals(0.0));
      expect(result[1], equals(1.0));
      expect(result[2], closeTo(0.5, 0.01));
    });

    test('processMemorySearch filters memories', () async {
      final memories = [
        {'content': 'apple pie'},
        {'content': 'banana bread'},
      ];
      final result = await IsolateTasks.processMemorySearch({
        'query': 'apple',
        'memories': memories,
      });
      expect(result.length, equals(1));
      expect(result[0]['content'], equals('apple pie'));
    });
  });
}
