// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/foundation.dart';

/// Application environment (dev / staging / prod).
///
/// Determines which API endpoints, feature flags, and logging levels
/// are active at runtime. Automatically resolved from build mode.
enum AppEnvironment {
  development,
  staging,
  production;

  /// Auto-detect from [kReleaseMode].
  ///
  /// - Debug builds → [development]
  /// - Profile builds → [staging]
  /// - Release builds → [production]
  static AppEnvironment get current {
    if (kReleaseMode) return AppEnvironment.production;
    if (kProfileMode) return AppEnvironment.staging;
    return AppEnvironment.development;
  }

  /// Human-readable label (used in UI debug banners).
  String get label {
    switch (this) {
      case AppEnvironment.development:
        return 'DEV';
      case AppEnvironment.staging:
        return 'STAGING';
      case AppEnvironment.production:
        return 'PROD';
    }
  }

  /// Whether verbose logging should be enabled.
  bool get verboseLogging => this != AppEnvironment.production;

  /// Base URL for the FHIR backend.
  String get fhirBaseUrl {
    switch (this) {
      case AppEnvironment.development:
        return 'http://localhost:8080/fhir';
      case AppEnvironment.staging:
        return 'https://staging-api.orionhealth.app/fhir';
      case AppEnvironment.production:
        return 'https://api.orionhealth.app/fhir';
    }
  }

  /// Base URL for the AI inference endpoint.
  String get aiBaseUrl {
    switch (this) {
      case AppEnvironment.development:
        return 'http://localhost:8000';
      case AppEnvironment.staging:
        return 'https://staging-ai.orionhealth.app';
      case AppEnvironment.production:
        return 'https://ai.orionhealth.app';
    }
  }

  /// Base URL for the CMS content.
  String get cmsBaseUrl {
    switch (this) {
      case AppEnvironment.development:
        return 'http://localhost:3000';
      case AppEnvironment.staging:
        return 'https://staging-api.orionhealth.app';
      case AppEnvironment.production:
        return 'https://api.orionhealth.app';
    }
  }

  /// Enable crash reporting in this environment.
  bool get enableCrashReporting => this == AppEnvironment.production;

  /// Enable performance monitoring.
  bool get enablePerformanceMonitor => this != AppEnvironment.production;

  /// Show a debug banner overlay in debug/dev builds.
  bool get showDebugBanner => this == AppEnvironment.development;
}
