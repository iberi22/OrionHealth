// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

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
  await getIt.init(environment: AppEnvironment.current.name);
}
