// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

/// Smoke test: verifies dependency injection initializes without error
/// Run: flutter test test/smoke_init_test.dart --flavor prod

import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';

import 'helpers/test_platform.dart';

void main() {
  setUpAll(() async {
    await setUpTestPlatform();
    await getIt.reset();
    await configureDependencies();
  });

  test(
    'dependency injection initializes without error',
    () async {
      // If we get here without exception, DI succeeded
      expect(
        true,
        isTrue,
        reason: 'configureDependencies completed without error',
      );
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );
}
