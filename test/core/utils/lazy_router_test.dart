import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/utils/lazy_router.dart';

void main() {
  group('LazyWidget', () {
    test('initializes and loads only once', () {
      int factoryCalls = 0;
      final lazy = LazyWidget<Container>(() {
        factoryCalls++;
        return Container();
      });

      expect(lazy.isLoaded, isFalse);

      final first = lazy.instance;
      expect(lazy.isLoaded, isTrue);
      expect(factoryCalls, equals(1));

      final second = lazy.call();
      expect(second, same(first));
      expect(factoryCalls, equals(1));
    });
  });

  group('LazyModuleLoader', () {
    late LazyModuleLoader loader;

    setUp(() {
      loader = LazyModuleLoader();
    });

    test('register and preload module', () async {
      bool loaded = false;
      loader.register(
        name: 'test',
        loader: () async {
          loaded = true;
        },
        factory: () => 'result',
      );

      expect(loader.isLoaded('test'), isFalse);

      await loader.preload('test');

      expect(loader.isLoaded('test'), isTrue);
      expect(loaded, isTrue);
    });

    test('get preloads and returns cached instance', () async {
      int factoryCalls = 0;
      loader.register(
        name: 'test',
        loader: () async {},
        factory: () {
          factoryCalls++;
          return 'result';
        },
      );

      final result1 = await loader.get<String>('test');
      expect(result1, equals('result'));
      expect(factoryCalls, equals(1));

      final result2 = await loader.get<String>('test');
      expect(result2, equals('result'));
      expect(factoryCalls, equals(1));
    });

    test('dispose and disposeAll', () async {
      loader.register(name: 't1', loader: () async {}, factory: () => 'r1');
      loader.register(name: 't2', loader: () async {}, factory: () => 'r2');

      await loader.get('t1');
      await loader.get('t2');

      expect(loader.isLoaded('t1'), isTrue);
      expect(loader.isLoaded('t2'), isTrue);

      loader.dispose('t1');
      expect(loader.isLoaded('t1'), isFalse);
      expect(loader.isLoaded('t2'), isTrue);

      loader.disposeAll();
      expect(loader.isLoaded('t2'), isFalse);
    });

    test('preloadAll loads multiple modules', () async {
      int loadCount = 0;
      loader.register(name: 'm1', loader: () async => loadCount++, factory: () => null);
      loader.register(name: 'm2', loader: () async => loadCount++, factory: () => null);

      await loader.preloadAll(['m1', 'm2']);

      expect(loadCount, equals(2));
      expect(loader.isLoaded('m1'), isTrue);
      expect(loader.isLoaded('m2'), isTrue);
    });
  });
}
