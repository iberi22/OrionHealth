// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:orionhealth_health/core/services/app_logger.dart';

/// Lazy-load a page/widget using a factory, deferring initialization
/// until the first time it is needed.
///
/// Usage:
/// ```dart
/// final homePage = LazyWidget(() => const MainNavigationPage());
/// // ... later in a build method:
/// homePage.build(context);
/// ```
class LazyWidget<T extends Widget> {
  final T Function() _factory;
  T? _instance;

  LazyWidget(this._factory);

  T get instance => _instance ??= _factory();
  T call() => instance;
  bool get isLoaded => _instance != null;
}

/// Deferred module loader — imports features on demand.
///
/// Splits the app into named chunks so unused features don't increase
/// the initial download size, and initialization is spread across idle
/// frames instead of blocking startup.
class LazyModuleLoader {
  final Map<String, Future<void> Function()> _loaders = {};
  final Map<String, bool> _loaded = {};
  final Map<String, dynamic Function()> _factories = {};
  final Map<String, dynamic> _cache = {};

  /// Register a module with a loader callback and a factory.
  void register({
    required String name,
    required Future<void> Function() loader,
    required dynamic Function() factory,
  }) {
    _loaders[name] = loader;
    _factories[name] = factory;
    _loaded[name] = false;
  }

  /// Whether a module has finished loading.
  bool isLoaded(String name) => _loaded[name] ?? false;

  /// Preload a module in the background (returns a Future that completes
  /// when loading finishes). Safe to call multiple times — subsequent calls
  /// are no-ops once loaded.
  Future<void> preload(String name) async {
    if (isLoaded(name)) return;
    AppLogger.d('LazyModule', 'Preloading module: $name');
    try {
      await _loaders[name]?.call();
      _loaded[name] = true;
      AppLogger.i('LazyModule', 'Module loaded: $name');
    } catch (e, stack) {
      AppLogger.e('LazyModule', 'Failed to load module: $name', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Preload multiple modules in parallel.
  Future<void> preloadAll(List<String> names, {int concurrency = 3}) async {
    final batches = <List<String>>[];
    for (var i = 0; i < names.length; i += concurrency) {
      batches.add(names.sublist(i, (i + concurrency).clamp(0, names.length)));
    }
    for (final batch in batches) {
      await Future.wait(batch.map(preload));
    }
  }

  /// Get a cached instance of a module. Loads it first if not loaded.
  Future<T> get<T>(String name) async {
    if (!isLoaded(name)) {
      await preload(name);
    }
    if (!_cache.containsKey(name)) {
      _cache[name] = _factories[name]?.call();
    }
    return _cache[name] as T;
  }

  /// Spread initialization across idle frames using [WidgetsBinding.addPostFrameCallback].
  Future<void> warmUp(List<String> names, {int perFrame = 1}) async {
    for (var i = 0; i < names.length; i += perFrame) {
      final batch = names.sublist(i, (i + perFrame).clamp(0, names.length));
      await Future.wait(batch.map(preload));
      // Yield to the next frame for a smooth startup
      await Future<void>.delayed(Duration.zero);
    }
  }

  void dispose(String name) {
    _cache.remove(name);
    _loaded[name] = false;
  }

  void disposeAll() {
    _cache.clear();
    _loaded.updateAll((_, __) => false);
  }
}

/// Global singleton for app-wide lazy module management.
final lazyModuleLoader = LazyModuleLoader();
