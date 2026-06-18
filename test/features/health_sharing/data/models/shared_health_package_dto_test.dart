import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/data/models/shared_health_package_dto.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';

void main() {
  group('EncryptedPayloadDto', () {
    const payload = EncryptedPayload(
      encryptedData: 'enc123',
      iv: 'iv456',
      ephemeralPublicKey: 'key789',
      authTag: 'tagABC',
    );

    test('fromDomain creates correctly', () {
      final dto = EncryptedPayloadDto.fromDomain(payload);
      expect(dto.encryptedData, 'enc123');
      expect(dto.iv, 'iv456');
      expect(dto.ephemeralPublicKey, 'key789');
      expect(dto.authTag, 'tagABC');
    });

    test('toDomain recreates original', () {
      final dto = EncryptedPayloadDto.fromDomain(payload);
      final domain = dto.toDomain();
      expect(domain, equals(payload));
    });

    test('toJson produces correct map', () {
      final dto = EncryptedPayloadDto.fromDomain(payload);
      final json = dto.toJson();
      expect(json['encryptedData'], 'enc123');
      expect(json['iv'], 'iv456');
      expect(json['ephemeralPublicKey'], 'key789');
      expect(json['authTag'], 'tagABC');
    });

    test('fromJson roundtrip', () {
      final json = {
        'encryptedData': 'enc123',
        'iv': 'iv456',
        'ephemeralPublicKey': 'key789',
        'authTag': 'tagABC',
      };
      final dto = EncryptedPayloadDto.fromJson(json);
      expect(dto.toJson(), json);
    });

    test('fromJson with empty authTag', () {
      final json = {
        'encryptedData': 'enc',
        'iv': 'iv',
        'ephemeralPublicKey': 'key',
        'authTag': null,
      };
      final dto = EncryptedPayloadDto.fromJson(json);
      expect(dto.authTag, '');
    });
  });

  group('PackageMetadataDto', () {
    final metadata = PackageMetadata(
      packageType: 'standard',
      consentVerified: true,
      includedCategories: {DataCategory.medications, DataCategory.labResults},
      pinHash: '1234',
      appVersion: '1.0.0',
    );

    test('fromDomain creates correctly', () {
      final dto = PackageMetadataDto.fromDomain(metadata);
      expect(dto.packageType, 'standard');
      expect(dto.consentVerified, isTrue);
      expect(
        dto.includedCategories,
        containsAll(['medications', 'labResults']),
      );
      expect(dto.pinHash, '1234');
      expect(dto.appVersion, '1.0.0');
    });

    test('fromDomain preserves domain fields', () {
      final dto = PackageMetadataDto.fromDomain(metadata);
      expect(dto.packageType, metadata.packageType);
      expect(dto.consentVerified, metadata.consentVerified);
      expect(
        dto.includedCategories,
        metadata.includedCategories.map((c) => c.name),
      );
      expect(dto.appVersion, metadata.appVersion);
    });

    test('toJson includes pinHash when present', () {
      final dto = PackageMetadataDto.fromDomain(metadata);
      final json = dto.toJson();
      expect(json['pinHash'], '1234');
    });

    test('toJson omits pinHash when null', () {
      final m = PackageMetadata(
        packageType: 'standard',
        consentVerified: true,
        includedCategories: {},
        appVersion: '1.0.0',
      );
      final dto = PackageMetadataDto.fromDomain(m);
      final json = dto.toJson();
      expect(json.containsKey('pinHash'), isFalse);
    });

    test('fromJson roundtrip', () {
      final json = {
        'packageType': 'limited',
        'consentVerified': false,
        'includedCategories': ['medications'],
        'appVersion': '2.0.0',
      };
      final dto = PackageMetadataDto.fromJson(json);
      expect(dto.packageType, 'limited');
      expect(dto.consentVerified, isFalse);
      expect(dto.includedCategories, {'medications'});
    });
  });
}
