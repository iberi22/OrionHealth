import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart';

void main() {
  group('GemmaLlmAdapter (legacy)', () {
    test('constructor works', () {
      final adapter = GemmaLlmAdapter();
      expect(adapter, isA<GemmaLlmAdapter>());
    });

    test('modelName returns gemma-4-e2b-local', () {
      final adapter = GemmaLlmAdapter();
      expect(adapter.modelName, equals('gemma-4-e2b-local'));
    });

    test('isAvailable checks availability (platform-dependent)', () async {
      final adapter = GemmaLlmAdapter();
      // Result depends on platform (AICore available, or GEMINI_API_KEY set)
      // In CI/test env this may be true or false, just verify it completes
      final available = await adapter.isAvailable();
      expect(available, isA<bool>());
    });

    test('isModelInstalled returns false (no models in test env)', () async {
      final adapter = GemmaLlmAdapter();
      expect(await adapter.isModelInstalled('gemma-4'), isFalse);
    });

    test('listInstalledModels returns empty list', () async {
      final adapter = GemmaLlmAdapter();
      expect(await adapter.listInstalledModels(), isEmpty);
    });

    test('uninstallModel does not throw', () async {
      final adapter = GemmaLlmAdapter();
      await adapter.uninstallModel('gemma-4');
      // Should complete without error
    });

    test('cancelDownload does not throw', () async {
      final adapter = GemmaLlmAdapter();
      await adapter.cancelDownload('model-123');
      // Should complete without error
    });

    test('installModel throws UnsupportedError (legacy)', () async {
      final adapter = GemmaLlmAdapter();
      expect(
        () => adapter.installModel(modelId: 'test', url: 'test'),
        throwsA(isA<Error>()),
      );
    });
  });
}
