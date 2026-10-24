// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2026 SouthWest AI Labs

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every Isar @collection of the app must be opened by DatabaseModule; a missing
/// schema only fails at runtime ("Missing TypeSchema in Isar.open").
void main() {
  test('Isar.open includes every @collection schema of lib/', () {
    final module = File('lib/core/di/database_module.dart').readAsStringSync();
    final collection = RegExp(
      r'@(?:collection|Collection\([^)]*\))\s*(?:@\w+(?:\([^)]*\))?\s*)*class\s+(\w+)',
    );
    final missing = <String>[];
    for (final f in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart') || f.path.endsWith('.g.dart')) {
        continue;
      }
      for (final m in collection.allMatches(f.readAsStringSync())) {
        final schema = '${m.group(1)}Schema';
        if (!RegExp('\\b$schema\\b').hasMatch(module))
          missing.add('$schema (${f.path})');
      }
    }
    expect(
      missing,
      isEmpty,
      reason: 'collections not opened by DatabaseModule',
    );
  });
}
