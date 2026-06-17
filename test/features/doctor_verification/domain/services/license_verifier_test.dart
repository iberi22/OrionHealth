import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/datasources/license_registry_local.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/services/license_verifier.dart';

class MockLicenseRegistryLocalDataSource extends Mock implements LicenseRegistryLocalDataSource {}

void main() {
  late LicenseVerifier licenseVerifier;
  late MockLicenseRegistryLocalDataSource mockRegistry;

  setUp(() {
    mockRegistry = MockLicenseRegistryLocalDataSource();
    licenseVerifier = LicenseVerifier(mockRegistry);
  });

  group('LicenseVerifier', () {
    const String validLicense = "ABC12345";
    // SHA-256 of "ABC12345"
    const String validHash = "2221aa193aea3b3fdee120c146c302fdb6ea606dbf4dfc5e1d587ec4b1aedf74";
    const String countryUS = "US";

    test('should return valid when license hash is in registry', () async {
      // Arrange
      when(() => mockRegistry.getHashesForCountry(countryUS)).thenAnswer((_) async => [validHash]);

      // Act
      final result = await licenseVerifier.verify(validLicense, countryUS);

      // Assert
      expect(result, LicenseVerificationResult.valid);
    });

    test('should normalize license number (strip all whitespace and uppercase)', () async {
      // Arrange
      when(() => mockRegistry.getHashesForCountry(countryUS)).thenAnswer((_) async => [validHash]);

      // Act
      final result = await licenseVerifier.verify("  A B C 1 2 3 4 5  ", countryUS);

      // Assert
      expect(result, LicenseVerificationResult.valid);
    });

    test('should return invalid when license hash is NOT in registry', () async {
      // Arrange
      when(() => mockRegistry.getHashesForCountry(countryUS)).thenAnswer((_) async => [validHash]);

      // Act
      final result = await licenseVerifier.verify("WRONG123", countryUS);

      // Assert
      expect(result, LicenseVerificationResult.invalid);
    });

    test('should return unknown when country is not in registry', () async {
      // Arrange
      when(() => mockRegistry.getHashesForCountry("UK")).thenAnswer((_) async => []);

      // Act
      final result = await licenseVerifier.verify(validLicense, "UK");

      // Assert
      expect(result, LicenseVerificationResult.unknown);
    });

    test('should return invalid for empty license number', () async {
      // Act
      final result = await licenseVerifier.verify("", countryUS);

      // Assert
      expect(result, LicenseVerificationResult.invalid);
    });
  });
}
