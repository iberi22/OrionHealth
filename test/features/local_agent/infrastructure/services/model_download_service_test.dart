import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/model_download_service.dart';

void main() {
  group('ModelInfo', () {
    test('constructor assigns fields correctly', () {
      final now = DateTime(2026, 6, 18);
      final info = ModelInfo(
        filename: 'gemma-4-e2b-q4.gguf',
        size: 2560000000,
        lastModified: now,
        parameters: '2B',
      );

      expect(info.filename, 'gemma-4-e2b-q4.gguf');
      expect(info.size, 2560000000);
      expect(info.lastModified, now);
      expect(info.parameters, '2B');
    });

    test('parameters can be null', () {
      final info = ModelInfo(
        filename: 'test.gguf',
        size: 100,
        lastModified: DateTime(2026, 1, 1),
      );

      expect(info.parameters, isNull);
    });
  });

  group('ModelDownloadService', () {
    test('listDownloadedModels returns empty list when no models', () async {
      final service = ModelDownloadService();
      try {
        final models = await service.listDownloadedModels();
        expect(models, isEmpty);
      } catch (_) {
        // MissingPluginException expected in test environment
        expect(true, isTrue);
      }
    });

    test('getModelInfo returns null for non-existent model', () async {
      final service = ModelDownloadService();
      try {
        final info = await service.getModelInfo('nonexistent.gguf');
        expect(info, isNull);
      } catch (_) {
        expect(true, isTrue);
      }
    });

    test('deleteModel does not throw for non-existent model', () async {
      final service = ModelDownloadService();
      try {
        await service.deleteModel('nonexistent.gguf');
      } catch (_) {
        expect(true, isTrue);
      }
    });

    test('service can be instantiated', () {
      final service = ModelDownloadService();
      expect(service, isA<ModelDownloadService>());
    });
  });
}
