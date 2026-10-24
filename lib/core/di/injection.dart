// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:orionhealth_health/core/config/environment.dart';
import 'injection.config.dart';

export 'package:orionhealth_health/core/config/environment.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Registrations are scoped by build environment (development/staging/production)
  // and by platform (mobile/desktop); filtering by the build environment alone left
  // the platform-scoped ones (e.g. MedicalKnowledgeRepository) unregistered.
  await getIt.init(
    environmentFilter: NoEnvOrContainsAny({
      AppEnvironment.current.name,
      platformEnvironment(),
    }),
  );
}

/// Platform environment of the platform-scoped registrations.
String platformEnvironment() => switch (defaultTargetPlatform) {
  TargetPlatform.android || TargetPlatform.iOS => 'mobile',
  _ => 'desktop',
};
