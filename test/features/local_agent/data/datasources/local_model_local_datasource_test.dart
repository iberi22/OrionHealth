import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/data/datasources/local_model_local_datasource.dart';

void main() {
  group('LocalModelLocalDataSource', () {
    test('getModelsDirectory returns a non-empty path', () async {
      final ds = LocalModelLocalDataSource();
      final path = await ds.getModelsDirectory();
      expect(path, isA<String>());
      expect(path.isNotEmpty, isTrue);
    });

    test('listInstalledModels returns empty list when no models', () async {
      final ds = LocalModelLocalDataSource();
      final models = await ds.listInstalledModels();
      expect(models, isA<List<String>>());
    });

    test('isModelInstalled returns false for unknown model', () async {
      final ds = LocalModelLocalDataSource();
      final installed = await ds.isModelInstalled('nonexistent-model');
      expect(installed, isFalse);
    });

    test('deleteModel does not throw for unknown model', () async {
      final ds = LocalModelLocalDataSource();
      await ds.deleteModel('nonexistent-model');
      // Should complete without error
    });
  });
}
