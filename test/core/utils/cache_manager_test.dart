import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/utils/cache_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CacheManager', () {
    late CacheManager cacheManager;
    late Directory tempDir;

    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('cache_test');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'getTemporaryDirectory') {
            return tempDir.path;
          }
          return null;
        },
      );

      cacheManager = CacheManager();
      await cacheManager.initialize();
    });

    tearDown(() async {
      await cacheManager.clearCache();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('initialize creates subdirectories', () async {
      expect(await Directory('${tempDir.path}/images').exists(), isTrue);
      expect(await Directory('${tempDir.path}/data').exists(), isTrue);
      expect(await Directory('${tempDir.path}/audio').exists(), isTrue);
    });

    test('cacheData and getCachedData', () async {
      final data = Uint8List.fromList([1, 2, 3, 4]);
      const key = 'test_key';

      await cacheManager.cacheData(key, data, type: CacheType.data);

      final cached = await cacheManager.getCachedData(key, type: CacheType.data);
      expect(cached, equals(data));
    });

    test('isCached returns correct status', () async {
      const key = 'test_key';
      expect(await cacheManager.isCached(key), isFalse);

      await cacheManager.cacheData(key, Uint8List.fromList([1, 2, 3]));
      expect(await cacheManager.isCached(key), isTrue);
    });

    test('removeCachedData removes file', () async {
      const key = 'test_key';
      await cacheManager.cacheData(key, Uint8List.fromList([1]));

      await cacheManager.removeCachedData(key);
      expect(await cacheManager.isCached(key), isFalse);
    });

    test('clearCache removes all files for a type', () async {
      await cacheManager.cacheData('k1', Uint8List.fromList([1]), type: CacheType.image);
      await cacheManager.cacheData('k2', Uint8List.fromList([2]), type: CacheType.data);

      await cacheManager.clearCache(type: CacheType.image);

      expect(await cacheManager.isCached('k1', type: CacheType.image), isFalse);
      expect(await cacheManager.isCached('k2', type: CacheType.data), isTrue);
    });

    test('getCacheStats returns valid statistics', () async {
      await cacheManager.cacheData('k1', Uint8List.fromList(List.filled(1024, 1)), type: CacheType.data);

      final stats = await cacheManager.getCacheStats();
      expect(stats['dataCache']['files'], equals(1));
      expect(stats['dataCache']['size'], greaterThanOrEqualTo(1024));
    });

    test('memory cache is utilized', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      const key = 'mem_key';

      await cacheManager.cacheData(key, data);

      // Directly check if it's in memory by deleting the file and seeing if we still get it
      final file = File('${tempDir.path}/data/$key');
      await file.delete();

      final cached = await cacheManager.getCachedData(key);
      expect(cached, equals(data)); // Should come from memory
    });
  });
}
