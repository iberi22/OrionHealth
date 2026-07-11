// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

/// Smoke test: verifies dependency injection initializes without error
/// Run: flutter test test/smoke_init_test.dart --flavor prod

import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dependency injection initializes without error', () async {
    await configureDependencies();
    // If we get here without exception, DI succeeded
    expect(true, isTrue, reason: 'configureDependencies completed without error');
  }, timeout: const Timeout(Duration(seconds: 60)));
}
