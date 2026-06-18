import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';

/// Minimal concrete implementation for testing the abstract interface
class TestLlmAdapter implements LlmAdapter {
  @override
  String get modelName => 'test-model';

  @override
  Future<String> generate(String prompt) async => 'Generated: $prompt';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Stream<int> installModel({
    required String modelId,
    required String url,
  }) async* {
    yield 0;
    yield 50;
    yield 100;
  }

  @override
  Future<List<String>> listInstalledModels() async => ['test-model'];

  @override
  Future<void> uninstallModel(String modelId) async {
    // no-op for test
  }

  @override
  Future<void> cancelDownload(String modelId) async {
    // no-op for test
  }

  @override
  Future<bool> isModelInstalled(String modelId) async =>
      modelId == 'test-model';
}

void main() {
  late TestLlmAdapter adapter;

  setUp(() {
    adapter = TestLlmAdapter();
  });

  group('LlmAdapter interface', () {
    test('modelName returns correct identifier', () {
      expect(adapter.modelName, 'test-model');
    });

    test('generate produces correct output', () async {
      final result = await adapter.generate('Hello');
      expect(result, 'Generated: Hello');
    });

    test('isAvailable returns true by default', () async {
      expect(await adapter.isAvailable(), isTrue);
    });

    test('installModel streams progress from 0 to 100', () async {
      final progress = <int>[];
      await adapter
          .installModel(modelId: 'gemma-3-270m', url: 'http://test.com/model')
          .forEach(progress.add);

      expect(progress, [0, 50, 100]);
    });

    test('listInstalledModels returns available models', () async {
      final models = await adapter.listInstalledModels();
      expect(models, ['test-model']);
    });

    test('uninstallModel completes without error', () async {
      await adapter.uninstallModel('test-model');
      // Should complete without throwing
    });

    test('cancelDownload completes without error', () async {
      await adapter.cancelDownload('model-123');
      // Should complete without throwing
    });

    test('isModelInstalled returns true for installed model', () async {
      expect(await adapter.isModelInstalled('test-model'), isTrue);
    });

    test('isModelInstalled returns false for unknown model', () async {
      expect(await adapter.isModelInstalled('unknown-model'), isFalse);
    });
  });
}
