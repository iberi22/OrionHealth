// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2026 SouthWest AI Labs

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every type the app resolves from GetIt must be registered in the generated
/// injection config (CI regenerates it with build_runner before the tests).
/// A missing registration only fails at runtime, on the device.
void main() {
  test('every getIt<T>() in lib/ has a registration', () {
    final config = File('lib/core/di/injection.config.dart').readAsStringSync();
    final registered = RegExp(
      r'gh\.\w+\s*<\s*_i\d+\.(\w+)',
    ).allMatches(config).map((m) => m.group(1)!).toSet();
    final requested = <String, String>{};
    final usage = RegExp(
      r'\b(?:getIt|sl|GetIt\.instance|GetIt\.I)\s*(?:\.get)?\s*<\s*([A-Z]\w*)',
    );
    for (final f in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart') || f.path.endsWith('injection.config.dart'))
        continue;
      for (final m in usage.allMatches(f.readAsStringSync())) {
        requested.putIfAbsent(m.group(1)!, () => f.path);
      }
    }
    final missing = {
      for (final e in requested.entries)
        if (!registered.contains(e.key)) e.key: e.value,
    };
    expect(
      missing,
      isEmpty,
      reason: 'resolved from GetIt but never registered',
    );
  });

  test('every dependency inside the generated graph has a registration', () {
    final config = File('lib/core/di/injection.config.dart').readAsStringSync();
    final registered = RegExp(
      r'gh\.\w+\s*<\s*_i\d+\.(\w+)',
    ).allMatches(config).map((m) => m.group(1)!).toSet();
    final deps = RegExp(
      r'gh<\s*_i\d+\.(\w+)\s*>',
    ).allMatches(config).map((m) => m.group(1)!).toSet();
    expect(
      deps.difference(registered),
      isEmpty,
      reason: 'a generated factory needs a type nobody registers',
    );
  });
}
