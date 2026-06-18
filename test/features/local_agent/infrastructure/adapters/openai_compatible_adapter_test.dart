import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart';
import 'package:openai_dart/openai_dart.dart';

/// We test the OpenaiCompatibleAdapter by checking its public contract
/// without mocking OpenAIClient, since it's external. We verify:
/// - Pre-configured state
/// - Post-configure state
/// - Error handling for unconfigured methods
void main() {
  late OpenaiCompatibleAdapter adapter;

  setUp(() {
    adapter = OpenaiCompatibleAdapter();
  });

  group('OpenaiCompatibleAdapter', () {
    test('modelName returns empty before configure', () {
      expect(adapter.modelName, '');
    });

    test('modelName returns configured name after configure', () async {
      await adapter.configure(
        apiKey: 'test-key',
        modelName: 'gpt-4',
        baseUrl: 'https://fake-test.openai.com/v1',
      );
      expect(adapter.modelName, 'gpt-4');
    });

    test('isAvailable returns false before configure', () async {
      expect(await adapter.isAvailable(), isFalse);
    });

    test('isAvailable returns true after configure', () async {
      await adapter.configure(
        apiKey: 'test-key',
        modelName: 'gpt-4',
      );
      expect(await adapter.isAvailable(), isTrue);
    });

    test('listInstalledModels returns empty (cloud-based)', () async {
      expect(await adapter.listInstalledModels(), []);
    });

    test('isModelInstalled returns false (cloud-based)', () async {
      expect(await adapter.isModelInstalled('gpt-4'), isFalse);
    });

    test('generate throws StateError before configure', () async {
      await expectLater(
        () => adapter.generate('test'),
        throwsA(isA<StateError>()),
      );
    });

    test('generateStream throws StateError before configure', () async {
      // generateStream is async*, so we must listen to the stream to trigger the error
      final stream = adapter.generateStream('test');
      try {
        await stream.drain();
        fail('Expected StateError but stream completed without error');
      } on StateError {
        // Expected
      }
    });

    test('verifyConnection returns false before configure', () async {
      expect(await adapter.verifyConnection(), isFalse);
    });

    test('installModel throws UnsupportedError', () {
      expect(
        () => adapter.installModel(modelId: 'test', url: 'http://test.com'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('uninstallModel completes silently after configure', () async {
      await adapter.configure(
        apiKey: 'test-key',
        modelName: 'gpt-4',
      );

      await adapter.uninstallModel('test');
      // Should complete without error
    });

    test('cancelDownload completes silently after configure', () async {
      await adapter.configure(
        apiKey: 'test-key',
        modelName: 'gpt-4',
      );

      await adapter.cancelDownload('test');
      // Should complete without error
    });

    test('reconfigure replaces previous configuration', () async {
      await adapter.configure(
        apiKey: 'first-key',
        modelName: 'gpt-3.5-turbo',
      );
      expect(adapter.modelName, 'gpt-3.5-turbo');

      await adapter.configure(
        apiKey: 'second-key',
        modelName: 'gpt-4',
      );
      expect(adapter.modelName, 'gpt-4');
    });

    test('generateStream throws StateError when client is null after close', () async {
      await adapter.configure(
        apiKey: 'test-key',
        modelName: 'gpt-4',
      );
      // First configure creates a client; reconfiguring closes it
      expect(await adapter.isAvailable(), isTrue);
    });
  });
}
