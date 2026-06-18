// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

/// Thin logging wrapper for OrionHealth.
///
/// - In debug/profile mode: logs via [AppLogger] itself with no external dependency.
/// - In release mode: fully silent (no I/O overhead).
///
/// Usage:
/// ```dart
/// AppLogger.d('MemoryGraph', 'Indexed 320 nodes in 42ms');
/// AppLogger.w('IsarVector', 'Node $id not found in index');
/// AppLogger.e('LlmAdapter', 'Generation failed', error: e);
/// ```
library;

import 'package:flutter/foundation.dart' show kReleaseMode;

class AppLogger {
  AppLogger._();

  /// Debug message. Silent in release mode.
  static void d(String tag, String message) {
    if (!kReleaseMode) {
      _log('[$tag] DEBUG: $message');
    }
  }

  /// Info message. Silent in release mode.
  static void i(String tag, String message) {
    if (!kReleaseMode) {
      _log('[$tag] INFO: $message');
    }
  }

  /// Warning message. Silent in release mode.
  static void w(String tag, String message) {
    if (!kReleaseMode) {
      _log('[$tag] WARN: $message');
    }
  }

  /// Error message with optional error object. Silent in release mode.
  static void e(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    if (!kReleaseMode) {
      _log('[$tag] ERROR: $message${error != null ? ' | $error' : ''}');
      if (stackTrace != null) {
        _log(stackTrace.toString());
      }
    }
  }

  /// Low-level logging primitive. Uses [print] so AppLogger has zero
  /// dependency on [debugPrint] while still being silent in release mode.
  static void _log(String message) {
    // ignore: avoid_print
    print(message);
  }
}
