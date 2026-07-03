import '../../domain/entities/shared_health_package.dart';

class EncryptedPayloadDto {
  final String encryptedData;
  final String iv;
  final String ephemeralPublicKey;
  final String authTag;

  const EncryptedPayloadDto({
    required this.encryptedData, required this.iv,
    required this.ephemeralPublicKey, this.authTag = '',
  });

  factory EncryptedPayloadDto.fromDomain(EncryptedPayload p) => EncryptedPayloadDto(
    encryptedData: p.encryptedData, iv: p.iv,
    ephemeralPublicKey: p.ephemeralPublicKey, authTag: p.authTag,
  );

  EncryptedPayload toDomain() => EncryptedPayload(
    encryptedData: encryptedData, iv: iv,
    ephemeralPublicKey: ephemeralPublicKey, authTag: authTag,
  );

  Map<String, dynamic> toJson() => {
    'encryptedData': encryptedData, 'iv': iv,
    'ephemeralPublicKey': ephemeralPublicKey, 'authTag': authTag,
  };

  factory EncryptedPayloadDto.fromJson(Map<String, dynamic> j) => EncryptedPayloadDto(
    encryptedData: j['encryptedData'] as String, iv: j['iv'] as String,
    ephemeralPublicKey: j['ephemeralPublicKey'] as String, authTag: j['authTag'] as String? ?? '',
  );
}

class PackageMetadataDto {
  final String packageType;
  final bool consentVerified;
  final Set<String> includedCategories;
  final String? pinHash;
  final String appVersion;

  const PackageMetadataDto({
    required this.packageType, required this.consentVerified,
    required this.includedCategories, this.pinHash, required this.appVersion,
  });

  factory PackageMetadataDto.fromDomain(PackageMetadata m) => PackageMetadataDto(
    packageType: m.packageType, consentVerified: m.consentVerified,
    includedCategories: m.includedCategories.map((c) => c.name).toSet(),
    pinHash: m.pinHash, appVersion: m.appVersion,
  );

  PackageMetadata toDomain() => PackageMetadata(
        packageType: packageType,
        consentVerified: consentVerified,
        includedCategories:
            includedCategories.map((name) => DataCategory.valueOf(name)).toSet(),
        pinHash: pinHash,
        appVersion: appVersion,
      );

  Map<String, dynamic> toJson() => {
    'packageType': packageType, 'consentVerified': consentVerified,
    'includedCategories': includedCategories.toList(),
    if (pinHash != null) 'pinHash': pinHash, 'appVersion': appVersion,
  };

  factory PackageMetadataDto.fromJson(Map<String, dynamic> j) => PackageMetadataDto(
    packageType: j['packageType'] as String, consentVerified: j['consentVerified'] as bool,
    includedCategories: (j['includedCategories'] as List).map((e) => e as String).toSet(),
    pinHash: j['pinHash'] as String?, appVersion: j['appVersion'] as String,
  );
}
