// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2026 SouthWest AI Labs

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('Android and iOS resolve the mobile registrations', () {
    for (final p in [TargetPlatform.android, TargetPlatform.iOS]) {
      debugDefaultTargetPlatformOverride = p;
      expect(platformEnvironment(), 'mobile');
    }
  });

  test('desktop platforms resolve the desktop registrations', () {
    for (final p in [
      TargetPlatform.linux,
      TargetPlatform.macOS,
      TargetPlatform.windows,
    ]) {
      debugDefaultTargetPlatformOverride = p;
      expect(platformEnvironment(), 'desktop');
    }
  });
}
