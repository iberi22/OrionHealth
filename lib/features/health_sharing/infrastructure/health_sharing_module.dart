// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@module
abstract class HealthSharingModule {
  @Named('nfcChannel')
  @lazySingleton
  MethodChannel get nfcChannel => const MethodChannel('orionhealth/nfc');
}
