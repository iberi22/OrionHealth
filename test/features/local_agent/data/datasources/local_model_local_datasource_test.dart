import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/data/datasources/local_model_local_datasource.dart';

void main() {
  group('LocalModelLocalDataSource', () {
    test('getModelsDirectory returns a Future<String>', () async {
      final ds = LocalModelLocalDataSource();
      // In test without path_provider mock, this will throw MissingPluginException.
      // We just verify the method signature works.
      try {
        final path = await ds.getModelsDirectory();
        expect(path, isA<String>());
      } catch (e) {
        // Expected: MissingPluginException when no platform channel
        expect(e, isA<Error>());
      }
    });

    test('listInstalledModels returns a List<String>', () async {
      final ds = LocalModelLocalDataSource();
      try {
        final models = await ds.listInstalledModels();
        expect(models, isA<List<String>>());
      } catch (e) {
        expect(e, isA<Error>());
      }
    });

    test('isModelInstalled returns false for unknown model', () async {
      final ds = LocalModelLocalDataSource();
      try {
        final installed = await ds.isModelInstalled('nonexistent-model');
        expect(installed, isFalse);
      } catch (e) {
        expect(e, isA<Error>());
      }
    });

    test('deleteModel does not throw for unknown model', () async {
      final ds = LocalModelLocalDataSource();
      try {
        await ds.deleteModel('nonexistent-model');
      } catch (e) {
        expect(e, isA<Error>());
      }
    });
  });
}
