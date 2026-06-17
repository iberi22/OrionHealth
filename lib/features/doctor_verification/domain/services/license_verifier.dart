import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';
import '../../infrastructure/datasources/license_registry_local.dart';

enum LicenseVerificationResult {
  valid,
  invalid,
  unknown,
  expired,
}

@lazySingleton
class LicenseVerifier {
  final LicenseRegistryLocalDataSource _registry;

  LicenseVerifier(this._registry);

  Future<LicenseVerificationResult> verify(String licenseNumber, String countryCode) async {
    final normalized = licenseNumber.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    if (normalized.isEmpty) {
      return LicenseVerificationResult.invalid;
    }

    final bytes = utf8.encode(normalized);
    final hash = sha256.convert(bytes).toString();

    final countryHashes = await _registry.getHashesForCountry(countryCode);

    if (countryHashes.isEmpty) {
      return LicenseVerificationResult.unknown;
    }

    if (countryHashes.contains(hash)) {
      return LicenseVerificationResult.valid;
    }

    return LicenseVerificationResult.invalid;
  }
}
