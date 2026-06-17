// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:io' show Platform;

/// Read from `--dart-define=flavor=dev|staging|prod` at build time.
///
/// The Gradle product flavour is mapped via
/// `--dart-define=flavor=\${flavor}` in launch configs and CI.
///
/// When not set (which is normal for `flutter run` without flavour),
/// we detect from build mode as a best-effort fallback.
class BuildConfig {
  BuildConfig._();

  static final String flavor =
      const String.fromEnvironment('flavor', defaultValue: 'dev');

  static bool get isDev => flavor == 'dev';
  static bool get isStaging => flavor == 'staging';
  static bool get isProd => flavor == 'prod';

  // For test detection at runtime, move to a separate check
  static bool get isTest => Platform.environment.containsKey('FLUTTER_TEST');
}
