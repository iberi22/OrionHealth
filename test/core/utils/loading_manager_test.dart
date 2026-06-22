import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/utils/loading_manager.dart';

void main() {
  group('LoadingManager', () {
    late LoadingManager loadingManager;

    setUp(() {
      loadingManager = LoadingManager();
      loadingManager.clearAll();
    });

    test('startLoading updates state and notifies listeners', () {
      bool notified = false;
      loadingManager.addListener(() {
        notified = true;
      });

      loadingManager.startLoading('test_op', message: 'Testing...');

      expect(loadingManager.isLoading('test_op'), isTrue);
      expect(loadingManager.getLoadingState('test_op')?.message, equals('Testing...'));
      expect(loadingManager.isAnyLoading, isTrue);
      expect(notified, isTrue);
    });

    test('stopLoading updates state correctly', () {
      loadingManager.startLoading('test_op');
      loadingManager.stopLoading('test_op');

      expect(loadingManager.isLoading('test_op'), isFalse);
      expect(loadingManager.getLoadingState('test_op')?.endTime, isNotNull);
    });

    test('updateLoadingMessage updates message for active operation', () {
      loadingManager.startLoading('test_op', message: 'Initial');
      loadingManager.updateLoadingMessage('test_op', 'Updated');

      expect(loadingManager.getLoadingState('test_op')?.message, equals('Updated'));
    });

    test('clearAll removes all states', () {
      loadingManager.startLoading('op1');
      loadingManager.startLoading('op2');
      loadingManager.clearAll();

      expect(loadingManager.loadingStates, isEmpty);
      expect(loadingManager.isAnyLoading, isFalse);
    });

    test('withLoading manages loading state automatically', () async {
      final result = await loadingManager.withLoading<String>(
        'test_op',
        () async {
          expect(loadingManager.isLoading('test_op'), isTrue);
          return 'done';
        },
      );

      expect(result, equals('done'));
      expect(loadingManager.isLoading('test_op'), isFalse);
    });

    test('withLoading rethrows error and stops loading', () async {
      try {
        await loadingManager.withLoading<void>(
          'test_op',
          () async {
            throw Exception('failed');
          },
        );
      } catch (e) {
        expect(e.toString(), contains('failed'));
      }

      expect(loadingManager.isLoading('test_op'), isFalse);
    });

    test('stateStream emits state changes', () async {
      final expectation = expectLater(
        loadingManager.stateStream,
        emits(predicate<Map<String, LoadingState>>((states) => states.containsKey('test_op'))),
      );

      loadingManager.startLoading('test_op');

      await expectation;
    });
  });
}
