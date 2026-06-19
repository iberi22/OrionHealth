import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/license_registry.dart';

void main() {
  group('LicenseRegistryLocal', () {
    test('should support instantiation', () {
      final registry = LicenseRegistryLocal(
        countryCode: 'US',
        hashes: ['hash1', 'hash2'],
      );

      expect(registry.countryCode, 'US');
      expect(registry.hashes, ['hash1', 'hash2']);
    });
  });
}
